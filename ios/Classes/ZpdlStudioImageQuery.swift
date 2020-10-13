//
//  ZpdlStudioImageQuery.swift
//  zpdl_studio_media_plugin
//
//  Created by 김경환 on 2020/10/12.
//

import MobileCoreServices
import Photos

class ZpdlStudioImageQuery: NSObject, PHPhotoLibraryChangeObserver {
    
    static let shared = ZpdlStudioImageQuery()

    private var modifyTimeMs: TimeInterval = 0.0
    private let imageManager = PHCachingImageManager()

    override private init() {
        super.init()
        updateModifyTimeMs()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func updateModifyTimeMs() {
        modifyTimeMs = Date().timeIntervalSince1970
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        updateModifyTimeMs()
    }
    
    func photoLibraryAuthorizationStatus(_ request: Bool, _ completion: @escaping (Bool) -> Void) {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            if request {
                PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
                    if status == PHAuthorizationStatus.authorized {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        case .authorized:
            completion(true)
        default:
            completion(false)
        }
    }

    private func sortOrderQuery(_ sortOrder: PluginSortOrder?) -> [NSSortDescriptor]? {
        let pluginSortOrder = sortOrder ?? PluginSortOrder.DATE_DESC

        switch pluginSortOrder {
        case .DATE_DESC:
            return [NSSortDescriptor(key: "creationDate", ascending: false)]
        case .DATE_ARC:
            return [NSSortDescriptor(key: "creationDate", ascending: true)]
        }
    }

    private func fetchPHAssetCollection(_ localIdentifier: String) -> PHAssetCollection? {
        let phAssetCollections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil)
        return phAssetCollections.firstObject
    }
    
    private func fetchPHAsset(_ localIdentifier: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
    }

    func getImageFolderCount(_ id: String?) -> Int {
        if let localIdentifier = id, !localIdentifier.isEmpty {
            if let phAssetCollection = fetchPHAssetCollection(localIdentifier) {
                return PHAsset.fetchAssets(in: phAssetCollection, options: nil).count
            } else {
                return 0
            }
        } else {
            return PHAsset.fetchAssets(with: nil).count
        }
    }

    func getImageFolder(_ sortOrder: PluginSortOrder?, _ completion: @escaping ([PluginFolder]?, _ authorized: Bool) -> Void) {
        photoLibraryAuthorizationStatus(true) { authorization in
            if(authorization) {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fetchImageFolder(sortOrder) { folders in
                        DispatchQueue.main.async {
                            completion(folders, true)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, false)
                }
            }
        }
    }

    func fetchImageFolder(_ sortOrder: PluginSortOrder?, _ completion: @escaping ([PluginFolder]) -> Void) {
        let fetchOPtions = PHFetchOptions()
        if let sortDescriptors = self.sortOrderQuery(sortOrder) {
            fetchOPtions.sortDescriptors = sortDescriptors
        }
        
        var folders = [PluginFolder]()
        let userCollections: PHFetchResult<PHCollection> = PHAssetCollection.fetchTopLevelUserCollections(with: fetchOPtions)
        userCollections.enumerateObjects { (phCollection: PHCollection, count, _) in
            if let phAssetCollection = phCollection as? PHAssetCollection {
                folders.append(PluginFolder(
                    id: phAssetCollection.localIdentifier,
                    displayName: phAssetCollection.localizedTitle ?? "",
                    count: phAssetCollection.estimatedAssetCount
                ))
            }
        }
        
        completion(folders)
    }
    
    func getImages(_ id: String?, _ sortOrder: PluginSortOrder?, _ limit: Int?, _ completion: @escaping ([PluginImage], Bool) -> Void) {
        photoLibraryAuthorizationStatus(false) { authorization in
            if(authorization) {
                DispatchQueue.global(qos: .userInitiated).async {
                    var phAssetCollection: PHAssetCollection? = nil
                    if let localIdentifier = id, !localIdentifier.isEmpty {
                        if let collection = self.fetchPHAssetCollection(localIdentifier) {
                            phAssetCollection = collection
                        } else {
                            DispatchQueue.main.async {
                                completion([], true)
                            }
                            return
                        }
                    }
                    
                    var results = [PluginImage]()
                    self.fetchImages(phAssetCollection, sortOrder, limit).enumerateObjects { (phAsset, int, _) in
                        results.append(PluginImage(
                                        id: phAsset.localIdentifier,
                                        width: phAsset.pixelWidth,
                                        height: phAsset.pixelHeight,
                                        modifyTimeMs: phAsset.modificationDate?.timeIntervalSince1970 ?? 0))
                    }

                    DispatchQueue.main.async {
                        completion(results, true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion([], false)
                }
            }
        }
    }
    
    func fetchImages(_ collection: PHAssetCollection?, _ sortOrder: PluginSortOrder?, _ limit: Int?) -> PHFetchResult<PHAsset> {
        let fetchOPtions = PHFetchOptions()
        if let sortDescriptors = self.sortOrderQuery(sortOrder) {
            fetchOPtions.sortDescriptors = sortDescriptors
        }
        if let fetchLimit = limit {
            fetchOPtions.fetchLimit = fetchLimit
        }

        if let phAssetCollection = collection {
            return PHAsset.fetchAssets(in: phAssetCollection, options: fetchOPtions)
        } else {
            return PHAsset.fetchAssets(with: fetchOPtions)
        }
    }
    
    func getImageThumbnail(_ id: String, _ width: Int, _ height: Int, _ completion: @escaping (PluginBitmap?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let phAsset = self.fetchPHAsset(id) {
                let option = PHImageRequestOptions()
                option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                self.imageManager.requestImage(
                    for: phAsset,
                    targetSize: CGSize(width: width, height: height),
                    contentMode: .aspectFit,
                    options: option,
                    resultHandler: { (image: UIImage?, info) in
                        let pluginBitmap = PluginBitmap.init(image)
                        DispatchQueue.main.async {
                            completion(pluginBitmap)
                        }
                    })
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func getImageReadBytes(_ id: String, _ completion: @escaping (Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let phAsset = self.fetchPHAsset(id) {
                phAsset.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, dictInfo) in
                    PHImageManager.default().requestImageData(for: phAsset, options: nil) { (data: Data?, _, _, _) in
                        if let uniformTypeIdentifier = contentEditingInput?.uniformTypeIdentifier, uniformTypeIdentifier == kUTTypeJPEG as String || uniformTypeIdentifier == kUTTypePNG as String {
                            print("KKH getImageReadBytes JPG id \(id) \(contentEditingInput?.uniformTypeIdentifier ?? "")")
                            DispatchQueue.main.async {
                                completion(data)
                            }
                        } else if let imageData = data {
                            print("KKH getImageReadBytes \(contentEditingInput?.uniformTypeIdentifier ?? "")")
                            let uiImage = UIImage(data: imageData)
                            let jpgData = uiImage?.jpegData(compressionQuality: 1.0)
                            DispatchQueue.main.async {
                                completion(jpgData)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(data)
                            }
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func checkUpdate(_ timeMs: Int) -> Bool {
        return timeMs < Int(modifyTimeMs * 1000)
    }
}
