import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_child.dart';
import 'package:zpdl_studio_bloc/widget/stream_builder_to_widget.dart';
import 'package:zpdl_studio_bloc/widget/touch_well.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_Image_widget.dart';

class AlbumPreviewPageBLoC extends BLoCChild with BLoCLifeCycle, BLoCChildKeyboardState, BLoCChildLoading {

  AlbumPreviewPageBLoC(this.pluginImage) {

  }

  final PluginImage pluginImage;

  final _imageInfo = BehaviorSubject<PluginImage>();
  Stream<PluginImage> get getImageInfoStream => _imageInfo.stream;

  @override
  void dispose() {
    _imageInfo.close();
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

  bool launched = false;
  @override
  void onLifeCycleResume() {
    print("KKH AlbumPreviewPageBLoC onLifeCycleResume ${pluginImage.id}");
    print("KKH AlbumPreviewPageBLoC onLifeCycleResume onBLoCChildKeyboardState ${childKeyboardState != null ? childKeyboardState() : false}");
    if(!launched) {
      launched = true;
      if(pluginImage.info == null) {
        pluginImage
            .getImageInfo()
            .then((value) => _imageInfo.sink.add(pluginImage));
      } else {
        _imageInfo.sink.add(pluginImage);
      }
    }
  }

  @override
  void onBLoCChildKeyboardState(bool show) {
    print("KKH AlbumPreviewPageBLoC onBLoCChildKeyboardState ${pluginImage.id} $show");
  }

  void showLoading() {
    showBLoCChildLoading();
    Future.delayed(Duration(seconds: 5)).then((value) => hideBLoCChildLoading());
  }
}

class AlbumPreviewPage extends BLoCChildProvider<AlbumPreviewPageBLoC> {

  final AlbumPreviewPageBLoC bloc;

  AlbumPreviewPage(this.bloc);

  @override
  AlbumPreviewPageBLoC createChildBLoC() => bloc;

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
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilderToWidget(
            stream: bloc.getImageInfoStream,
            builder: (BuildContext context, PluginImage data) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      data.info?.fullPath ?? "",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  SizedBox(width: 12,),
                  TouchWell(
                    onTap: () {
                      _showDialogInfo(context, data);
                      // bloc.showLoading();
                    },
                    circleBoard: true,
                    touchWellIsTop: true,
                    child: SizedBox(width: 36, height: 36, child: Icon(Icons.info, color: Colors.white),),
                  )
                ],
              );
            },
          ),
        ),
        // Container(
        //   height: 44,
        //   child: TextFieldFocusWidget(
        //     onBuildTextField: (context, focusNode) {
        //       return TextField(
        //         focusNode: focusNode,
        //       );
        //     },
        //     onHasFocusNode: bloc.childKeyboardStateHasFocusNode,
        //   ),
        // ),
      ],
    );
  }

  void _showDialogInfo(BuildContext context, PluginImage image) {
    if(image.info == null) {
      return;
    }

    showDialog(
        context: context,
        child: AlertDialog(
          title: Text(image.info.displayName.isNotEmpty
              ? image.info.displayName
              : image.id,
            style: TextStyle(fontSize: 14),),
          contentPadding: EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfo("Path", image.info.fullPath),
              _buildInfo("MimeType", image.info.mimeType),
              _buildInfo("size", "${image.width}x${image.height}"),
              _buildInfo("ModifyTimeMs", DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(image.modifyTimeMs))),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
          ],
        ));
  }

  Widget _buildInfo(String subject, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoSubject(subject),
      _buildInfoText(text)
    ],
  );

  Text _buildInfoSubject(String text) => Text(
        "$text : ",
        style: TextStyle(fontSize: 12),
      );

  Widget _buildInfoText(String text) => Expanded(
    flex: 1,
    child: Text(
      text ?? "",
      style: TextStyle(fontSize: 12),
    ),
  );
}