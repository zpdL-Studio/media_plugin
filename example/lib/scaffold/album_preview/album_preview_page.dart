import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/widget/stream_builder_to_widget.dart';
import 'package:zpdl_studio_bloc/widget/text_field_focus_widget.dart';
import 'package:zpdl_studio_bloc/widget/touch_well.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_Image_widget.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_image_provider.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';
import 'package:intl/intl.dart';

class AlbumPreviewPageBLoC extends BLoCChild with BLoCLifeCycle, BLoCKeyboardState {

  AlbumPreviewPageBLoC(this.pluginImage) {

  }

  final PluginImage pluginImage;

  final _imageInfo = BehaviorSubject<PluginImageInfo>();
  Stream<PluginImageInfo> get getImageInfoStream => _imageInfo.stream;

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
    if(!launched) {
      launched = true;
      ZpdlStudioMediaPlugin.getImageInfo(pluginImage.id).then((value) =>
          _imageInfo.sink.add(value));
    }
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
                print("KKH AlbumPreviewPage ${bloc.pluginImage.id}");
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
            builder: (BuildContext context, PluginImageInfo data) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      data.path,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  SizedBox(width: 12,),
                  TouchWell(
                    onTap: () {
                      _showDialogInfo(context, data);
                    },
                    circleBoard: true,
                    touchWellIsTop: true,
                    child: SizedBox(width: 24, height: 24, child: Icon(Icons.info, color: Colors.white),),
                  )
                ],
              );
            },
          ),
        )
      ],
    );
  }

  void _showDialogInfo(BuildContext context, PluginImageInfo data) {
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text((data.displayName.isNotEmpty
              ? data.displayName
              : data.id) ?? "",
            style: TextStyle(fontSize: 14),),
          contentPadding: EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfo("Path", data.path),
              _buildInfo("MimeType", data.mimeType),
              _buildInfo("Orientation", data.orientation.toString()),
              _buildInfo("size", "${data.width}x${data.height}"),
              _buildInfo("ModifyTimeMs", DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(data.modifyTimeMs))),
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