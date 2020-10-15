import 'dart:typed_data';

import 'map_ext.dart';
import 'zpdl_studio_media_plugin.dart';

class PluginDataSet<T> {
  final int timeMs;
  final bool permission;
  final List<T> list;

  PluginDataSet(this.timeMs, this.permission, this.list);

  @override
  String toString() {
    return 'PluginDataSet{timeMs: $timeMs, permission: $permission, list: $list}';
  }
}

enum PluginSortOrder {
  DATE_DESC,
  DATE_ARC,
}

extension PluginSortOrderExtension on PluginSortOrder {
  String get sortOrder {
    String result = "";
    switch(this) {
      case PluginSortOrder.DATE_DESC:
        result = "DATE_DESC";
        break;
      case PluginSortOrder.DATE_ARC:
        result = "DATE_ARC";
        break;
    }

    return result;
  }
}

class PluginFolder {
  final String id;
  final String displayName;
  final int count;

  PluginFolder(this.id, this.displayName, this.count);

  factory PluginFolder.map(Map map) => PluginFolder(
        map.get("id"),
        map.get("displayName") ?? "",
        map.get("count") ?? 0,
      );

  @override
  String toString() {
    return 'PluginFolder{id: $id, displayName: $displayName, count: $count}';
  }
}

class PluginImage {
  final String id;
  final int width;
  final int height;
  final int modifyTimeMs;

  PluginImage(this.id, this.width, this.height, this.modifyTimeMs);

  factory PluginImage.map(Map map) => PluginImage(
        map.get("id"),
        map.get("width") ?? 0,
        map.get("height") ?? 0,
        map.get("modifyTimeMs") ?? 0,
      );

  @override
  String toString() {
    return 'PluginImage{id: $id, width: $width, height: $height, modifyTimeMs: $modifyTimeMs}';
  }

  Future<Uint8List> readImageData() => ZpdlStudioMediaPlugin.readImageData(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginImage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          width == other.width &&
          height == other.height &&
          modifyTimeMs == other.modifyTimeMs;

  @override
  int get hashCode =>
      id.hashCode ^ width.hashCode ^ height.hashCode ^ modifyTimeMs.hashCode;
}

class PluginBitmap {
  final int width;
  final int height;
  final Uint8List buffer;

  PluginBitmap(this.width, this.height, this.buffer);

  factory PluginBitmap.map(Map map) {
    int width = map.get("width");
    int height = map.get("height");
    Uint8List buffer = map.get("buffer");

    if(width > 0 && height > 0 && buffer != null) {
      return PluginBitmap(width, height, buffer);
    }
    return null;
  }
}