import 'package:flutter/material.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';

import 'plugin_image_provider.dart';

typedef PluginImageBuilder = Widget Function(
    BuildContext context,
    ImageProvider imageProvider,
    );

class PluginImageWidget extends StatefulWidget {

  final PluginImage image;
  final PluginImageBuilder builder;

  const PluginImageWidget({
    Key key,
    @required this.image,
    @required this.builder,
  })  : assert(image != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginImageState();
}

class _PluginImageState extends State<PluginImageWidget> {

  PluginImageProvider _pluginImageProvider;
  String _pluginImageId;

  @override
  Widget build(BuildContext context) {
    if(_pluginImageProvider == null || _pluginImageId != widget.image.id) {
      _pluginImageId = widget.image.id;
      _pluginImageProvider?.evict();
      _pluginImageProvider = PluginImageProvider(_pluginImageId);
    }

    return widget.builder(context, _pluginImageProvider);
  }

  @override
  void dispose() {
    // _pluginImageProvider?.evict();
    _pluginImageProvider = null;
    _pluginImageId = null;
    super.dispose();
  }
}
