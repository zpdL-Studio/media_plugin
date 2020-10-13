//
//  ZpdlStudioMediaPluginConfig.swift
//  zpdl_studio_media_plugin
//
//  Created by 김경환 on 2020/10/12.
//

import Foundation

class ZpdlStudioMediaPluginConfig {
    static let CHANNEL_NAME = "zpdl_studio_media_plugin"
   
    class func methodToIOS(method: String) -> PlatformMethod? {
        let split = method.split(separator: "/")
        if split.count >= 2 {
            return PlatformMethod(rawValue: String(split[1]))
        }
        return nil
    }
}

enum PlatformMethod: String {
    case GET_IMAGE_FOLDER = "GET_IMAGE_FOLDER"
    case GET_IMAGE_FOLDER_COUNT = "GET_IMAGE_FOLDER_COUNT"
    case GET_IMAGE_FILES = "GET_IMAGE_FILES"
    case GET_IMAGE_THUMBNAIL = "GET_IMAGE_THUMBNAIL"
    case READ_IMAGE_DATA = "READ_IMAGE_DATA"
    case CHECK_UPDATE = "CHECK_UPDATE"
}
