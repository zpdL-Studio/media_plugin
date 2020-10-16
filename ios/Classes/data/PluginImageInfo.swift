//
//  PluginImageInfo.swift
//  zpdl_studio_media_plugin
//
//  Created by 김경환 on 2020/10/15.
//

struct PluginImageInfo: PluginToMap {
    let id: String
    let path: String
    let mimeType: String
    let orientation: Int
    let width: Int
    let height: Int
    let modifyTimeMs: TimeInterval

    func pluginToMap() -> [String : Any] {
        return [
            "id": id,
            "path": path,
            "mimeType": mimeType,
            "orientation": orientation,
            "width": width,
            "height": height,
            "modifyTimeMs": modifyTimeMs
        ]
    }
}
