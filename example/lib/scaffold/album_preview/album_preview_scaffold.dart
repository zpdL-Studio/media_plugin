import 'package:flutter/material.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_bloc/widget/stream_builder_to_widget.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_image_provider.dart';
import 'package:zpdl_studio_media_plugin_example/scaffold/album_preview/album_preview_bloc.dart';

import 'album_preview_page.dart';

class AlbumPreviewScaffold extends BLoCScaffoldProvider<AlbumPreviewBLoC> {
  final String folderName;
  final String currentId;
  final List<PluginImage> list;

  AlbumPreviewScaffold(this.folderName, this.currentId, this.list, {Key key}): super(key: key, bodyColor: Colors.black);

  @override
  AlbumPreviewBLoC createBLoC() => AlbumPreviewBLoC(folderName, currentId, list);

  @override
  PreferredSizeWidget appBar(BuildContext context, AlbumPreviewBLoC bloc) => AppBar(
        title: Text(bloc.folderName ?? ""),
      );

  @override
  Widget body(BuildContext context, AlbumPreviewBLoC bloc) {
    return SafeArea(
      child: StreamBuilderToWidget(
        stream: bloc.getPageBLoCStream,
        builder: (BuildContext context, List<AlbumPreviewPageBLoC> data) {
          return PageView.builder(
            controller: bloc.pageController,
            itemBuilder: (context, index) {
              return AlbumPreviewPage(data[index]);
            },
            itemCount: data.length,
            // physics: NeverScrollableScrollPhysics(),
          );
        },
      ),
    );
    // return SafeArea(
    //   child: Column(
    //     children: [
    //       Expanded(
    //         flex: 1,
    //         child: StreamBuilderToWidget(
    //           stream: bloc.getImageStream,
    //           builder: (BuildContext context, PluginImage data) {
    //             return Container(
    //               color: Colors.black,
    //               alignment: AlignmentDirectional.center,
    //               child: Image(
    //                 image: PluginImageProvider(data.id),
    //                 fit: BoxFit.contain,
    //                 errorBuilder: (context, error, stackTrace) {
    //                   return Center(
    //                     child: Text(error.toString(), style: TextStyle(color: Colors.red),),
    //                   );
    //                 },
    //               ),
    //             );
    //           },
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
