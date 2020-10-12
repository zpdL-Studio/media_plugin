import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';

typedef PluginImageLoadingWidgetBuilder = Widget Function(
    BuildContext context,
    PluginImageFile image,
    );

typedef PluginImageFolderLoadingWidgetBuilder = Widget Function(
    BuildContext context,
    PluginImageFolder folder,
    );

typedef PluginImageLoadedWidgetBuilder = Widget Function(
    BuildContext context,
    ui.Image image,
    );

typedef PluginImageErrorWidgetBuilder = Widget Function(
    BuildContext context,
    Exception error,
    );

enum _LoadState {
  LOADING,
  LOADED,
  ERROR
}

class PluginThumbnailWidget extends StatefulWidget {

  final PluginImageFile image;
  final int thumbnailWidthPx;
  final int thumbnailHeightPx;

  final double width;
  final double height;
  final BoxFit boxFit;
  final PluginImageLoadingWidgetBuilder loadingBuilder;
  final PluginImageLoadedWidgetBuilder loadedBuilder;
  final PluginImageErrorWidgetBuilder errorBuilder;

  const PluginThumbnailWidget({
    Key key,
    @required this.image,
    this.thumbnailWidthPx,
    this.thumbnailHeightPx,
    this.width,
    this.height,
    this.boxFit,
    this.loadingBuilder,
    this.loadedBuilder,
    this.errorBuilder})
      : assert(image != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginThumbnailState();
}

class _PluginThumbnailState extends State<PluginThumbnailWidget> {
  _LoadState _loadState;
  PluginImageFile _image;
  ui.Image _uiImage;
  Exception _exception;

  @override
  Widget build(BuildContext context) {
    if(_loadState == null || (_image != null && _image.id != widget.image.id)) {
      _loadState = _LoadState.LOADING;
      _image = widget.image;
      _uiImage?.dispose();
      _uiImage = null;
      _exception = null;
      _loadAsync(_image);
    }

    switch(_loadState) {
      case _LoadState.LOADING:
        return _buildLoading(context, widget.image);
      case _LoadState.LOADED:
        return _buildLoaded(context, _uiImage);
      case _LoadState.ERROR:
        return _buildError(context, _exception);
    }

    return Container(
      width: widget.width,
      height: widget.height,
    );
  }

  @override
  void dispose() {
    _uiImage?.dispose();
    _uiImage = null;
    _image = null;
    _exception = null;
    _loadState = null;
    super.dispose();
  }

  Widget _buildLoading(BuildContext context, PluginImageFile image,) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: widget.loadingBuilder != null ? widget.loadingBuilder(context, image) : null,
    );
  }

  Widget _buildLoaded(BuildContext context, ui.Image uiImage,) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: widget.loadedBuilder != null
          ? widget.loadedBuilder(context, uiImage)
          : RawImage(
              width: widget.width,
              height: widget.height,
              fit: widget.boxFit,
              image: uiImage,
            ),
    );
  }

  Widget _buildError(BuildContext context, Exception e,) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: widget.errorBuilder != null ? widget.errorBuilder(context, e) : null,
    );
  }

  Future<void> _loadAsync(PluginImageFile image) async {
    try {
      PluginBitmap pluginBitmap = await ZpdlStudioMediaPlugin.getImageThumbnail(image.id, width: widget.thumbnailWidthPx, height: widget.thumbnailHeightPx);
      if(pluginBitmap != null) {
        ui.Image uiImage = await decodeImageFromPixels(pluginBitmap);
        if(uiImage != null) {
          if(mounted) {
            setState(() {
              this._loadState = _LoadState.LOADED;
              this._uiImage = uiImage;
            });
          }
          return;
        }
      }
      throw Exception("Plugin Image Thumbnail load failed");
    } catch(e) {
      if(mounted) {
        setState(() {
          this._loadState = _LoadState.ERROR;
          this._exception = e;
        });
      }
    }
  }

  Future<ui.Image> decodeImageFromPixels(PluginBitmap pluginBitmap) {
    Completer<ui.Image> c = new Completer();
    ui.decodeImageFromPixels(
        pluginBitmap.buffer,
        pluginBitmap.width,
        pluginBitmap.height,
        ui.PixelFormat.rgba8888,
            (results) {
          c.complete(results);
        });
    return c.future;
  }
}

class PluginFolderThumbnailWidget extends StatefulWidget {
  final PluginImageFolder folder;
  final int thumbnailWidthPx;
  final int thumbnailHeightPx;
  final double width;
  final double height;
  final BoxFit boxFit;
  final PluginImageFolderLoadingWidgetBuilder loadingBuilder;
  final PluginImageLoadedWidgetBuilder loadedBuilder;
  final PluginImageErrorWidgetBuilder errorBuilder;

  const PluginFolderThumbnailWidget({Key key, this.folder, this.thumbnailWidthPx, this.thumbnailHeightPx, this.width, this.height, this.boxFit, this.loadingBuilder, this.loadedBuilder, this.errorBuilder}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginFolderThumbnailState();

}

class _PluginFolderThumbnailState extends State<PluginFolderThumbnailWidget> {
  _LoadState _loadState;
  PluginImageFolder _folder;
  PluginImageFile _file;
  Exception _exception;

  @override
  Widget build(BuildContext context) {
    if(_loadState == null || (_getFolderId(_folder) != _getFolderId(widget.folder))) {
      _loadState = _LoadState.LOADING;
      _folder = widget.folder;
      _file = null;
      _loadAsync(_folder);
    }

    switch(_loadState) {
      case _LoadState.LOADING:
        return _buildLoading(context, widget.folder);
      case _LoadState.LOADED:
        return _buildLoaded(context, _folder, _file);
      case _LoadState.ERROR:
        return _buildError(context, _exception);
    }

    return Container(
      width: widget.width,
      height: widget.height,
    );
  }

  @override
  void dispose() {
    _folder = null;
    _file = null;
    _loadState = null;
    super.dispose();
  }

  String _getFolderId(PluginImageFolder folder) => folder?.id ?? "";

  Widget _buildLoading(BuildContext context, PluginImageFolder folder,) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: widget.loadingBuilder != null ? widget.loadingBuilder(context, folder) : null,
    );
  }

  Widget _buildLoaded(BuildContext context, PluginImageFolder folder, PluginImageFile image,) {
    return image != null
        ? PluginThumbnailWidget(
      image: image,
      thumbnailWidthPx: widget.thumbnailWidthPx,
      thumbnailHeightPx: widget.thumbnailHeightPx,
      width: widget.width,
      height: widget.height,
      boxFit: widget.boxFit,
      loadingBuilder: widget.loadingBuilder != null ? (BuildContext context, PluginImageFile image) {
        return widget.loadingBuilder(context, folder);
      } : null,
      loadedBuilder: widget.loadedBuilder,
      errorBuilder: widget.errorBuilder,
    ) : Container(
      width: widget.width,
      height: widget.height,
    );
  }

  Widget _buildError(BuildContext context, Exception e,) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: widget.errorBuilder != null ? widget.errorBuilder(context, e) : null,
    );
  }

  Future<void> _loadAsync(PluginImageFolder folder) async {
    try {
      List<PluginImageFile> list = await ZpdlStudioMediaPlugin.getImageFiles(_getFolderId(folder), limit: 1);
      if(list != null && list.isNotEmpty) {
        if(mounted) {
          setState(() {
            this._loadState = _LoadState.LOADED;
            this._file = list.first;
          });
        }
      } else {
        throw Exception("Plugin Folder image files load failed");
      }
    } catch(e) {
      if(mounted) {
        setState(() {
          this._loadState = _LoadState.ERROR;
          this._exception = e;
        });
      }
    }
  }
}