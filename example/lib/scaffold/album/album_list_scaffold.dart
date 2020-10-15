import 'package:flutter/material.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_bloc/widget/stream_builder_to_widget.dart';
import 'package:zpdl_studio_bloc/widget/touch_well.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/widget/plugin_thumbnail_widget.dart';

import 'album_list_bloc.dart';

class AlbumListScaffold extends BLoCScaffoldProvider<AlbumListBloc> {

  AlbumListScaffold({Key key}): super(key: key);

  @override
  AlbumListBloc createBLoC() => AlbumListBloc();

  @override
  PreferredSizeWidget appBar(BuildContext context, AlbumListBloc bloc) => AppBar(
        title: const Text('Album'),
      );

  @override
  Widget body(BuildContext context, AlbumListBloc bloc) {
    return SafeArea(
      child: Column(
        children: [
          StreamBuilderToWidget(
            stream: bloc.getFoldersStream,
            builder: (BuildContext context, List<AlbumFolder> data) {
              return Card(
                child: Container(
                  height: (bloc.itemWidth + 16).toDouble(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return _buildFolder(data[index], bloc.itemWidth.toDouble(), () {
                        bloc.changeFolder(data[index]);
                      });
                    },
                    itemCount: data.length,
                  ),
                ),
              );
            },
          ),
          Expanded(
            flex: 1,
            child: StreamBuilderToWidget(
              stream: bloc.getImagesStream,
              builder: (BuildContext context, List<PluginImage> data) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: bloc.itemRowCount,
                      childAspectRatio: 1,
                      mainAxisSpacing: bloc.itemSpace.toDouble(),
                      crossAxisSpacing: bloc.itemSpace.toDouble(),
                    ),
                    itemBuilder: (context, index) {
                      return TouchWell(
                        touchWellIsTop: true,
                        onTap: () {
                          bloc.onTapImage(data[index]);
                        },
                        child: PluginThumbnailWidget(
                          width: double.infinity,
                          height: double.infinity,
                          image: data[index],
                          boxFit: BoxFit.contain,
                          errorBuilder: (BuildContext context, Exception e) {
                            return Center(child: Text(e.toString()),);
                          },
                        ),
                      );
                    },
                    itemCount: data.length,
                  ),
                );
              },
            ),)
        ],
      ),
    );
  }

  Widget _buildFolder(AlbumFolder folder, double size, GestureTapCallback onTap) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        clipBehavior: Clip.hardEdge,
        child: TouchWell(
          onTap: onTap,
          touchWellIsTop: true,
          child: Stack(
            children: [
              PluginFolderThumbnailWidget(
                folder: folder.folder,
                width: size,
                height: size,
                boxFit: BoxFit.cover,
                loadingBuilder: (BuildContext context, PluginFolder folder) {
                  return Center(child: Text("Loading"),);
                },
                emptyBuilder: (BuildContext context, PluginFolder folder) {
                  return Center(child: Text(folder.displayName),);
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
                    Expanded(
                      flex: 1,
                      child: Text(
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
                    ),
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
