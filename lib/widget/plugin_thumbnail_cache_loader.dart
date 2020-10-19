import 'dart:async';
import 'dart:ui' as ui;

import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';

typedef PluginThumbnailLoaderCallback = void Function(ThumbnailCacheImage image, Exception e);

abstract class PluginThumbnailLoader {
  ThumbnailCacheImage loadAsync(String id, int width, int height, PluginThumbnailLoaderCallback callback);
  
  void cancelAsync(PluginThumbnailLoaderCallback callback);
}

class PluginThumbnailCacheLoader extends PluginThumbnailLoader{

  static final PluginThumbnailCacheLoader _instance = PluginThumbnailCacheLoader._();

  factory PluginThumbnailCacheLoader() => _instance;

  PluginThumbnailCacheLoader._();

  int maximumSize = 256;
  int coincident = 8;

  int _loadingCount = 0;

  final Map<_LoadKey, ThumbnailCacheImage> _cache = Map();
  final List<_LoadKey> _cacheKeys = List();
  final List<_LoadItem> _pending = List();

  @override
  ThumbnailCacheImage loadAsync(String id, int width, int height, PluginThumbnailLoaderCallback callback) {
    // print("KKH loadAsync id : $id");
    final key = _LoadKey(id, width, height);

    ThumbnailCacheImage thumbnailCacheImage = _cache[key];
    if (thumbnailCacheImage != null) {
      // print("KKH loadAsync cache : $id");
      _cacheKeys.remove(key);
      _cacheKeys.add(key);
      return thumbnailCacheImage.._ref();
    }

    if (_loadingCount < coincident) {
      _loadAsync(
        key,
        callback,
      );
    } else {
      _pending.add(_LoadItem(
        key,
        callback,
      ));
    }
    return null;
  }
  
  void _loadAsync(_LoadKey key, PluginThumbnailLoaderCallback callback) async {
    _loadingCount++;
    try {
      PluginBitmap pluginBitmap = await ZpdlStudioMediaPlugin.getImageThumbnail(key.id, width: key.width, height: key.height);
      if(pluginBitmap != null) {
        ui.Image uiImage = await decodeImageFromPixels(pluginBitmap);
        if(uiImage != null) {
          final thumbnailCacheImage = ThumbnailCacheImage(uiImage);
          if(_cacheKeys.length >= maximumSize) {
            _LoadKey _key = _cacheKeys.removeAt(0);
            _cache.remove(_key)?.dispose();
          }
          _cacheKeys.add(key);
          _cache[key] = thumbnailCacheImage;

          _loadingCount--;
          callback(thumbnailCacheImage.._ref(), null);
          loadPending();
          return;
        }
      }
      throw Exception("PluginThumbnailCacheLoader Thumbnail load failed");
    } catch(e) {
      _loadingCount--;
      callback(null, e);
      loadPending();
    }
  }

  void loadPending() {
    if(_pending.length > 0 && _loadingCount < coincident) {
      _LoadItem loadItem = _pending.removeLast();

      ThumbnailCacheImage image = _cache[loadItem.key];
      if(image != null) {
        _cacheKeys.remove(loadItem.key);
        _cacheKeys.add(loadItem.key);
        loadItem.callback(image.._ref(), null);
      } else {
        _loadAsync(loadItem.key, loadItem.callback, );
      }
    }
  }

  Future<ui.Image> decodeImageFromPixels(PluginBitmap pluginBitmap) {
    Completer<ui.Image> c = Completer();
    ui.decodeImageFromPixels(pluginBitmap.buffer, pluginBitmap.width,
        pluginBitmap.height, ui.PixelFormat.rgba8888, (results) {
      c.complete(results);
    });
    return c.future;
  }

  @override
  void cancelAsync(PluginThumbnailLoaderCallback callback) {
    Iterator<_LoadItem> iterator = _pending.iterator;
    while(iterator.moveNext()) {
      if(iterator.current.callback == callback) {
        _pending.remove(iterator.current);
        break;
      }
    }
  }
}

class ThumbnailCacheImage {
  final ui.Image image;
  int _referenceCount = 1;

  ThumbnailCacheImage(this.image);

  void _ref() => _referenceCount++;

  void dispose() {
    _referenceCount--;
    if(_referenceCount <= 0) {
      image.dispose();
    }
  }
}

class _LoadKey {
  final String id;
  final int width;
  final int height;

  _LoadKey(this.id, this.width, this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LoadKey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => id.hashCode ^ width.hashCode ^ height.hashCode;
}

class _LoadItem {
  final _LoadKey key;
  final PluginThumbnailLoaderCallback callback;

  _LoadItem(this.key, this.callback);
}