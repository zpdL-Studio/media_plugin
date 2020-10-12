import 'package:flutter/material.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_bloc/widget/stream_builder_to_widget.dart';
import 'package:zpdl_studio_bloc/widget/touch_well.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/plugin_thumbnail_widget.dart';

import 'album_bloc.dart';

class AlbumScaffold extends BLoCScaffoldProvider<AlbumBloc> {

  AlbumScaffold({Key key}): super(key: key);

  @override
  AlbumBloc createBLoC() => AlbumBloc();

  @override
  PreferredSizeWidget appBar(BuildContext context, AlbumBloc bloc) => AppBar(
        title: const Text('Album'),
      );

  @override
  Widget body(BuildContext context, AlbumBloc bloc) {
    return SafeArea(
      child: Column(
        children: [
          StreamBuilderToWidget(
            stream: bloc.getFolderStream,
            builder: (BuildContext context, List<AlbumFolder> data) {
              return Card(
                child: Container(
                  height: (bloc.itemWidth + 16).toDouble(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return _buildFolder(data[index], bloc.itemWidth.toDouble());
                    },
                    itemCount: data.length,
                  ),
                ),
              );
            },
          ),
          Expanded(flex: 1, child: Container(),)
        ],
      ),
    );
  }

  Widget _buildFolder(AlbumFolder folder, double size) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        clipBehavior: Clip.hardEdge,
        child: TouchWell(
          onTap: () {

          },
          touchWellIsTop: true,
          child: Stack(
            children: [
              PluginFolderThumbnailWidget(
                folder: folder.folder,
                width: size,
                height: size,
                boxFit: BoxFit.cover,
                loadingBuilder: (BuildContext context, PluginImageFolder folder) {
                  return Center(child: Text("Loading"),);
                },
                errorBuilder: (BuildContext context, Exception e) {
                  return Center(child: Text(e.toString()),);
                },
              ),
              Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(8),
                color: folder.selected ? Colors.black.withAlpha(32) : Colors.black.withAlpha(128),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.folder.displayName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: folder.selected
                          ? TextStyle(
                          fontSize: 14,
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold)
                          : TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                    Spacer(flex: 1,),
                    Row(
                      children: [
                        Spacer(flex: 1,),
                        Text(
                          folder.folder.count.toString(),
                          softWrap: false,
                          style: folder.selected
                              ? TextStyle(
                              fontSize: 14,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold)
                              : TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
