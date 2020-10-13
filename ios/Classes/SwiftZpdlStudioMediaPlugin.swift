import Flutter
import UIKit

public class SwiftZpdlStudioMediaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: ZpdlStudioMediaPluginConfig.CHANNEL_NAME, binaryMessenger: registrar.messenger())
    let instance = SwiftZpdlStudioMediaPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = ZpdlStudioMediaPluginConfig.methodToIOS(method: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        switch method {
        case .GET_IMAGE_FOLDER:
            var sortOrder: PluginSortOrder? = nil
            if let arguments = call.arguments as? [String:Any] {
                sortOrder = PluginSortOrder.init(rawValue: getString(arguments, "sortOrder") ?? "")
            }
            getImageFolder(sortOrder, result)
        case .GET_IMAGE_FOLDER_COUNT:
            getImageFolderCount(call.arguments as? String, result)
        case .GET_IMAGE_FILES:
            var id: String? = nil
            var sortOrder: PluginSortOrder? = nil
            var limit: Int? = nil
            if let arguments = call.arguments as? [String:Any] {
                id = getString(arguments, "id")
                sortOrder = PluginSortOrder.init(rawValue: getString(arguments, "sortOrder") ?? "")
                limit = getInt(arguments, "limit")
            }
            getImages(id, sortOrder, limit, result)
        case .GET_IMAGE_THUMBNAIL:
            var _id: String? = nil
            var width: Int? = nil
            var height: Int? = nil
            if let arguments = call.arguments as? [String:Any] {
                _id = getString(arguments, "id")
                width = getInt(arguments, "width")
                height = getInt(arguments, "height")
            }
            if let id = _id {
                ZpdlStudioImageQuery.shared.getImageThumbnail(id, width ?? 256, height ?? 256) { (bitmap: PluginBitmap?) in
                    result(bitmap?.pluginToMap())
                }
            } else {
                result(nil)
            }
        case .READ_IMAGE_DATA:
            if let id = call.arguments as? String {
                ZpdlStudioImageQuery.shared.getImageReadBytes(id) { (data: Data?) in
                    result(data)
                }
            } else {
                result(nil)
            }
        case .CHECK_UPDATE:
            if let timeMs = call.arguments as? Int {
                result(ZpdlStudioImageQuery.shared.checkUpdate(timeMs))
            } else {
                result(true)
            }
        }
    }
    
    func getImageFolder(_ sortOrder: PluginSortOrder?, _ result: @escaping FlutterResult) {
        ZpdlStudioImageQuery.shared.getImageFolder(sortOrder) { (f: [PluginFolder]?, permission: Bool) in
            if let folders = f, permission {
                var list = [[String:Any]]()
                for folder in folders {
                    list.append(folder.pluginToMap())
                }
                result([
                    "timeMs": Int(Date().timeIntervalSince1970 * 1000),
                    "permission": true,
                    "list": list
                ])
            } else {
                result([
                    "timeMs": Int(Date().timeIntervalSince1970 * 1000),
                    "permission": permission
                ])
            }
        }
    }
    
    func getImageFolderCount(_ id: String?, _ result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let count = ZpdlStudioImageQuery.shared.getImageFolderCount(id)
            DispatchQueue.main.async {
                result(count)
            }
        }
    }
    
    func getImages(_ id: String?, _ sortOrder: PluginSortOrder?, _ limit: Int?, _ result: @escaping FlutterResult) {
        ZpdlStudioImageQuery.shared.getImages(id, sortOrder, limit, { (images: [PluginImage], permission: Bool) in
            var list = [[String:Any]]()
            for image in images {
                list.append(image.pluginToMap())
            }
            
            result([
                "permission": permission,
                "list": list
            ])
        })
    }

}

func getInt(_ dict: Dictionary<String, Any>?, _ key: String) -> Int? {
    if let value = dict?[key] as? NSNumber {
        return Int(truncating: value)
    } else if let value = dict?[key] as? String {
        return Int(value)
    }
    return nil
}

func getString(_ dict: Dictionary<String, Any>?, _ key: String) -> String? {
    if let value = dict?[key] as? String {
        return value
    } else if let value = dict?[key] as? NSNumber {
        return value.stringValue
    }
    return nil
}
