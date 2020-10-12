import 'dart:typed_data';

import 'map_ext.dart';

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

class PluginImageFolder {
  final String id;
  final String displayName;
  final int count;
  final int modifyTimeMs;

  PluginImageFolder(this.id, this.displayName, this.count, this.modifyTimeMs);

  factory PluginImageFolder.map(Map map) => PluginImageFolder(
        map.get("id"),
        map.get("displayName") ?? "",
        map.get("count") ?? 0,
        map.get("modifyTimeMs") ?? 0,
      );

  @override
  String toString() {
    return 'PluginImageFolder{id: $id, displayName: $displayName, count: $count, modifyTimeMs: $modifyTimeMs}';
  }
}

class PluginImageFile {
  final String id;
  final String displayName;
  final int orientation;
  final int width;
  final int height;
  final int modifyTimeMs;

  PluginImageFile(this.id, this.displayName, this.orientation, this.width, this.height, this.modifyTimeMs);

  factory PluginImageFile.map(Map map) => PluginImageFile(
        map.get("id"),
        map.get("displayName") ?? "",
        map.get("orientation") ?? 0,
        map.get("width") ?? 0,
        map.get("height") ?? 0,
        map.get("modifyTimeMs") ?? 0,
      );

  @override
  String toString() {
    return 'PluginImageFile{id: $id, displayName: $displayName, orientation: $orientation, width: $width, height: $height, modifyTimeMs: $modifyTimeMs}';
  }
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