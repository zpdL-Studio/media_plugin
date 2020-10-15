import 'package:flutter/material.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/widget/text_field_focus_widget.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_Image_widget.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_image_provider.dart';


class AlbumPreviewPageBLoC extends BLoCChild with BLoCLifeCycle, BLoCKeyboardState {

  final PluginImage pluginImage;

  AlbumPreviewPageBLoC(this.pluginImage);

  @override
  void dispose() {
    // print("KKH AlbumPreviewPageBLoC dispose ${pluginImage.id}");
    super.dispose();
  }
  @override
  void disposeChild() {
    // print("KKH AlbumPreviewPageBLoC disposeChild ${pluginImage.id}");
  }

  @override
  void onLifeCyclePause() {
    print("KKH AlbumPreviewPageBLoC onLifeCyclePause ${pluginImage.id}");
  }

  @override
  void onLifeCycleResume() {
    print("KKH AlbumPreviewPageBLoC onLifeCycleResume ${pluginImage.id}");
  }

  @override
  void onKeyboardState(bool show) {
    print("KKH onKeyboardState $show ${pluginImage.id}");
  }
}

class AlbumPreviewPage extends BLoCProvider<AlbumPreviewPageBLoC> {

  final AlbumPreviewPageBLoC bloc;

  AlbumPreviewPage(this.bloc);

  @override
  AlbumPreviewPageBLoC createBLoC() => bloc;

  @override
  Widget build(BuildContext context, AlbumPreviewPageBLoC bloc) {
    // Image.network(src)
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: AlignmentDirectional.center,
            child: PluginImageWidget(
              image: bloc.pluginImage,
              builder: (BuildContext context, ImageProvider<dynamic> imageProvider) {
                return Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if(loadingProgress == null) {
                      return child;
                    }
                    return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                        alignment: AlignmentDirectional.center,
                        child: Container(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator()));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        error.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Container(
          height: 44,
          color: Colors.white,
          child: TextFieldFocusWidget(
            onBuildTextField: (FocusNode focusNode) {
              return TextField(

              );
            },

          ),
        )
      ],
    );
  }
}