import 'package:flutter/material.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_child.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/plugin_image_provider.dart';

class AlbumPreviewPageBLoC extends BLoCChild {

  final PluginImage pluginImage;

  AlbumPreviewPageBLoC(this.pluginImage);

  @override
  void disposeChild() {

  }
}

class AlbumPreviewPage extends BLoCChildProvider<PluginImage, AlbumPreviewPageBLoC> {

  AlbumPreviewPage(PluginImage identifier, onBLoCChildCreate) : super(identifier, onBLoCChildCreate);

  @override
  Widget build(BuildContext context, AlbumPreviewPageBLoC bloc) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: AlignmentDirectional.center,
            child: Image(
              image: PluginImageProvider(bloc.pluginImage.id),
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                    alignment: AlignmentDirectional.center,
                    child: Container(
                        width: 40, height: 40, child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    error.toString(),
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}