import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';

import 'plugin_thumbnail_cache_loader.dart';

typedef PluginThumbnailLoadingWidgetBuilder = Widget Function(
    BuildContext context,
    PluginImage image,
    );

typedef PluginFolderThumbnailLoadingWidgetBuilder = Widget Function(
    BuildContext context,
    PluginFolder folder,
    );

typedef PluginFolderThumbnailEmptyWidgetBuilder = Widget Function(
    BuildContext context,
    PluginFolder folder,
    );

typedef PluginThumbnailLoadedWidgetBuilder = Widget Function(
    BuildContext context,
    ui.Image image,
    );

typedef PluginThumbnailErrorWidgetBuilder = Widget Function(
    BuildContext context,
    Object? error,
    );

enum _LoadState {
  LOADING,
  LOADED,
  ERROR
}

class PluginThumbnailWidget extends StatefulWidget {

  final PluginImage image;
  final int? thumbnailWidthPx;
  final int? thumbnailHeightPx;

  final double? width;
  final double? height;
  final BoxFit? boxFit;
  final PluginThumbnailLoader loader;
  final PluginThumbnailLoadingWidgetBuilder? loadingBuilder;
  final PluginThumbnailLoadedWidgetBuilder? loadedBuilder;
  final PluginThumbnailErrorWidgetBuilder? errorBuilder;

  PluginThumbnailWidget({
    Key? key,
    required this.image,
    this.thumbnailWidthPx,
    this.thumbnailHeightPx,
    this.width,
    this.height,
    this.boxFit,
    PluginThumbnailLoader? loader,
    this.loadingBuilder,
    this.loadedBuilder,
    this.errorBuilder})
      : loader = loader ?? PluginThumbnailCacheLoader(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginThumbnailState();
}

class _PluginThumbnailState extends State<PluginThumbnailWidget> {
  _LoadState? _loadState;
  PluginImage? _image;
  ThumbnailCacheImage? _thumbnailCacheImage;
  Object? _exception;

  @override
  Widget build(BuildContext context) {
    if(_loadState == null || (_image != null && _image?.id != widget.image.id)) {
      _loadState = _LoadState.LOADING;
      _image = widget.image;
      _thumbnailCacheImage?.dispose();
      _thumbnailCacheImage = null;
      _exception = null;

      _thumbnailCacheImage = widget.loader.loadAsync(widget.image.id, null, null, _pluginThumbnailLoaderCallback);
      if(_thumbnailCacheImage != null) {
        _loadState = _LoadState.LOADED;
      }
    }

    switch(_loadState) {
      case _LoadState.LOADING:
        return _buildLoading(context, widget.image);
      case _LoadState.LOADED:
        var _thumbnailCacheImage = this._thumbnailCacheImage;
        if(_thumbnailCacheImage != null) {
          return _buildLoaded(context, _thumbnailCacheImage);
        } else {
          return Container();
        }
      case _LoadState.ERROR:
        return _buildError(context, _exception);
      case null:
        return Container(
          width: widget.width,
          height: widget.height,
        );
    }
  }

  void _pluginThumbnailLoaderCallback(ThumbnailCacheImage? image, Object? e) {
    if (mounted) {
      if(image != null) {
        setState(() {
          _loadState = _LoadState.LOADED;
          _thumbnailCacheImage = image;
          _exception = null;
        });
      } else {
        setState(() {
          _loadState = _LoadState.ERROR;
          _thumbnailCacheImage = null;
          _exception = e;
        });
      }
    }
  }

  @override
  void dispose() {
    if(_thumbnailCacheImage == null) {
      widget.loader.cancelAsync(_pluginThumbnailLoaderCallback);
    }
    _thumbnailCacheImage?.dispose();
    _thumbnailCacheImage = null;
    _image = null;
    _exception = null;
    _loadState = null;
    super.dispose();
  }

  Widget _buildLoading(BuildContext context, PluginImage image,) {
    var loadingBuilder = widget.loadingBuilder;
    return Container(
      width: widget.width,
      height: widget.height,
      child: loadingBuilder != null ? loadingBuilder(context, image) : null,
    );
  }

  Widget _buildLoaded(BuildContext context, ThumbnailCacheImage thumbnail,) {
    var loadedBuilder = widget.loadedBuilder;
    return Container(
      width: widget.width,
      height: widget.height,
      child: loadedBuilder != null
          ? loadedBuilder(context, thumbnail.image)
          : RawImage(
              width: widget.width,
              height: widget.height,
              fit: widget.boxFit,
              image: thumbnail.image,
            ),
    );
  }

  Widget _buildError(BuildContext context, Object? e,) {
    var errorBuilder = widget.errorBuilder;
    return Container(
      width: widget.width,
      height: widget.height,
      child: errorBuilder != null ? errorBuilder(context, e) : null,
    );
  }
}

class PluginFolderThumbnailWidget extends StatefulWidget {
  final PluginFolder folder;
  final int? thumbnailWidthPx;
  final int? thumbnailHeightPx;
  final double? width;
  final double? height;
  final BoxFit? boxFit;
  final PluginFolderThumbnailLoadingWidgetBuilder? loadingBuilder;
  final PluginThumbnailLoadedWidgetBuilder? loadedBuilder;
  final PluginFolderThumbnailEmptyWidgetBuilder? emptyBuilder;
  final PluginThumbnailErrorWidgetBuilder? errorBuilder;

  const PluginFolderThumbnailWidget({Key? key, required this.folder, this.thumbnailWidthPx, this.thumbnailHeightPx, this.width, this.height, this.boxFit, this.loadingBuilder, this.loadedBuilder, this.emptyBuilder, this.errorBuilder}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginFolderThumbnailState();

}

class _PluginFolderThumbnailState extends State<PluginFolderThumbnailWidget> {
  _LoadState? _loadState;
  PluginFolder? _folder;
  PluginImage? _file;
  Object? _exception;

  @override
  Widget build(BuildContext context) {
    if(_loadState == null || (_getFolderId(_folder) != _getFolderId(widget.folder))) {
      _loadState = _LoadState.LOADING;
      _folder = widget.folder;
      _file = null;
      _loadAsync(widget.folder);
    }

    switch(_loadState) {
      case _LoadState.LOADING:
        return _buildLoading(context, widget.folder);
      case _LoadState.LOADED:
        var file = _file;
        if(file == null) {
          return _buildEmpty(context, widget.folder);
        }
        return _buildLoaded(context, widget.folder, file);
      case _LoadState.ERROR:
        return _buildError(context, _exception);
      case null:
        return Container(
          width: widget.width,
          height: widget.height,
        );
    }
  }

  @override
  void dispose() {
    _folder = null;
    _file = null;
    _loadState = null;
    super.dispose();
  }

  String _getFolderId(PluginFolder? folder) => folder?.id ?? '';

  Widget _buildLoading(BuildContext context, PluginFolder folder,) {
    var loadingBuilder = widget.loadingBuilder;
    return Container(
      width: widget.width,
      height: widget.height,
      child: loadingBuilder != null ? loadingBuilder(context, folder) : null,
    );
  }

  Widget _buildLoaded(BuildContext context, PluginFolder folder, PluginImage image,) {
    var loadingBuilder = widget.loadingBuilder;
    return PluginThumbnailWidget(
      image: image,
      thumbnailWidthPx: widget.thumbnailWidthPx,
      thumbnailHeightPx: widget.thumbnailHeightPx,
      width: widget.width,
      height: widget.height,
      boxFit: widget.boxFit,
      loadingBuilder: loadingBuilder != null ? (BuildContext context, PluginImage image) {
        return loadingBuilder(context, folder);
      } : null,
      loadedBuilder: widget.loadedBuilder,
      errorBuilder: widget.errorBuilder,
    );
  }

  Widget _buildEmpty(BuildContext context, PluginFolder folder,) {
    var emptyBuilder = widget.emptyBuilder;
    return Container(
      width: widget.width,
      height: widget.height,
      child: emptyBuilder != null ? emptyBuilder(context, folder) : null,
    );
  }

  Widget _buildError(BuildContext context, Object? e,) {
    var errorBuilder = widget.errorBuilder;
    return Container(
      width: widget.width,
      height: widget.height,
      child: errorBuilder != null ? errorBuilder(context, e) : null,
    );
  }

  Future<void> _loadAsync(PluginFolder folder) async {
    try {
      var dataSet = await ZpdlStudioMediaPlugin.getImages(_getFolderId(folder), limit: 1);
      if(dataSet != null) {
        if(mounted) {
          setState(() {
            _loadState = _LoadState.LOADED;
            _file = dataSet.list.isNotEmpty ? dataSet.list.first : null;
          });
        }
      } else {
        throw Exception('Plugin Folder image files load failed');
      }
    } catch(e) {
      if(mounted) {
        setState(() {
          _loadState = _LoadState.ERROR;
          _exception = e;
        });
      }
    }
  }
}