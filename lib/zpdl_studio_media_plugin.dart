import 'map_ext.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zpdl_studio_media_plugin/plugin_config.dart';

import 'plugin_data.dart';

class ZpdlStudioMediaPlugin {
  static const MethodChannel _channel =
      const MethodChannel('zpdl_studio_media_plugin');

  static Future<PluginDataSet<PluginImageFolder>> getImageFolder() async {
    final result = await _channel.invokeMethod(PlatformMethod.GET_IMAGE_FOLDER.method);
    if(result is Map) {
      return PluginDataSet(
        result.get("timeMs") ?? 0,
        result.get("permission") ?? false,
        result.getList("list", (map) {
          return PluginImageFolder.map(map);
        })
      );
    }
    return null;
  }

  static Future<List<PluginImageFile>> getImageFiles(String id, {PluginSortOrder sortOrder, int limit}) async {
    final results = await _channel.invokeMethod(PlatformMethod.GET_IMAGE_FILES.method, {
      if(id != null) "id": id,
      if(sortOrder != null) "sortOrder": sortOrder.sortOrder,
      if(limit != null) "limit": limit
    });

    List<PluginImageFile> list = List();
    if(results is List) {
      for(final result in results) {
        if(result is Map) {
          list.add(PluginImageFile.map(result));
        }
      }
    }
    return list;
  }

  static Future<PluginBitmap> getImageThumbnail(int id, {int width, int height}) async {
    final results = await _channel.invokeMethod(PlatformMethod.GET_IMAGE_THUMBNAIL.method, {
      "id": id,
      if(width != null) "width": width,
      if(height != null) "height": height,
    });

    if(results is Map) {
      return PluginBitmap.map(results);
    }
    return null;
  }
}