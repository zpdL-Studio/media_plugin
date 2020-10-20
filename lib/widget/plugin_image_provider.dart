import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';

import '../plugin_data.dart';

class PluginImageProvider extends ImageProvider<PluginImageProvider> {

  final String imageId;

  const PluginImageProvider(this.imageId) : assert(imageId != null);

  @override
  Future<PluginImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PluginImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(PluginImageProvider key, decode) {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      scale: 1.0,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('imageId: $imageId');
      },
    );
  }

  Future<ui.Codec> _loadAsync(PluginImageProvider key, StreamController<ImageChunkEvent> chunkEvents, DecoderCallback decode) async {
    try {
      assert(key == this);
      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: 0,
        expectedTotalBytes: 100,
      ));

      final Uint8List bytes = await ZpdlStudioMediaPlugin.readImageData(
          imageId);

      if (bytes == null || bytes.lengthInBytes == 0) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError('$imageId is empty and cannot be loaded as an image.');
      }

      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: 100,
        expectedTotalBytes: 100,
      ));

      return await decode(bytes);
    } catch(e) {
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }
}

class PluginBitmapProvider extends ImageProvider<PluginBitmapProvider> {

  final PluginBitmap pluginBitmap;

  const PluginBitmapProvider(this.pluginBitmap) : assert(pluginBitmap != null);

  @override
  Future<PluginBitmapProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PluginBitmapProvider>(this);
  }

  @override
  ImageStreamCompleter load(PluginBitmapProvider key, decode) {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      scale: 1.0,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('pluginBitmap: error');
      },
    );
  }

  Future<ui.Codec> _loadAsync(PluginBitmapProvider key, StreamController<ImageChunkEvent> chunkEvents, DecoderCallback decode) async {
    try {
      assert(key == this);
      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: 0,
        expectedTotalBytes: 100,
      ));

      if (key.pluginBitmap.buffer == null || key.pluginBitmap.buffer.length == 0) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError('Bitmap is empty and cannot be loaded as an image.');
      }

      ui.Codec codec = await decodeImageFromPixels(key.pluginBitmap);
      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: 100,
        expectedTotalBytes: 100,
      ));

      return codec;
    } catch(e) {
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  Future<ui.Codec> decodeImageFromPixels(PluginBitmap pluginBitmap) {
    Completer<ui.Codec> c = Completer();
    ui.ImmutableBuffer.fromUint8List(pluginBitmap.buffer)
        .then((ui.ImmutableBuffer buffer) async {
      final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: pluginBitmap.width,
        height: pluginBitmap.height,
        pixelFormat: ui.PixelFormat.rgba8888,
      );

      descriptor
          .instantiateCodec(
            targetWidth: pluginBitmap.width,
            targetHeight: pluginBitmap.height,
          )
          .then((ui.Codec codec) => c.complete(codec));
    });

    return c.future;
  }
}