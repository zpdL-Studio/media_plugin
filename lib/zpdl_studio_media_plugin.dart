import 'dart:typed_data';

import 'map_ext.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zpdl_studio_media_plugin/plugin_config.dart';

import 'plugin_data.dart';

class ZpdlStudioMediaPlugin {
  static const MethodChannel _channel =
      const MethodChannel('zpdl_studio_media_plugin');

  static Future<PluginDataSet<PluginFolder>> getImageFolder() async {
    final result = await _channel.invokeMethod(PlatformMethod.GET_IMAGE_FOLDER.method);
    if(result is Map) {
      return PluginDataSet(
        result.get("timeMs") ?? 0,
        result.get("permission") ?? false,
        result.getList("list", (map) {
          return PluginFolder.map(map);
        })
      );
    }
    return null;
  }

  static Future<List<PluginImage>> getImageFiles(String id, {PluginSortOrder sortOrder, int limit}) async {
    final results = await _channel.invokeMethod(PlatformMethod.GET_IMAGE_FILES.method, {
      if(id != null) "id": id,
      if(sortOrder != null) "sortOrder": sortOrder.sortOrder,
      if(limit != null) "limit": limit
    });

    List<PluginImage> list = List();
    if(results is List) {
      for(final result in results) {
        if(result is Map) {
          list.add(PluginImage.map(result));
        }
      }
    }
    return list;
  }

  static Future<PluginBitmap> getImageThumbnail(String id, {int width, int height}) async {
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

  static Future<Uint8List> readImageData(String id) async {
    final results = await _channel.invokeMethod(PlatformMethod.READ_IMAGE_DATA.method,id);

    if(results is Uint8List) {
      return results;
    }
    return null;
  }

  static Future<bool> checkUpdate(int timeMs) async {
    final results = await _channel.invokeMethod(PlatformMethod.CHECK_UPDATE.method, timeMs);
    if(results is bool) {
      return results;
    }
    return true;
  }
}