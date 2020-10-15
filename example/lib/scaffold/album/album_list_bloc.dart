import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';
import 'package:zpdl_studio_media_plugin_example/scaffold/album_preview/album_preview_scaffold.dart';

class AlbumListBloc extends BLoCScaffold with BLoCLifeCycle {
  bool _init = false;

  int itemRowCount = 4;
  int itemWidth = 80;
  final int itemSpace = 4;

  String currentFolderId;
  int updateTimeMs = 0;

  final _folders = BehaviorSubject<List<AlbumFolder>>();
  Stream<List<AlbumFolder>> get getFoldersStream => _folders.stream;

  final _images = BehaviorSubject<List<PluginImage>>();
  Stream<List<PluginImage>> get getImagesStream => _images.stream;

  @override
  void dispose() {
    _folders.close();
    _images.close();
  }

  @override
  void onLifeCycleResume() async {
    BuildContext context = buildContext;
    if(context == null) {
      return;
    }

    if(!_init) {
      _init = true;
      double width = MediaQuery.of(context)?.size?.width ?? 360;
      itemRowCount = width ~/ itemWidth;
      itemWidth = (width - 32 - itemSpace * (itemRowCount - 1)) ~/ itemRowCount;

      refresh();
    } else if(await ZpdlStudioMediaPlugin.checkUpdate(updateTimeMs)) {
      refresh();
    }
  }

  @override
  void onLifeCyclePause() {

  }

  void refresh() {
    scaffoldSubscription<PluginDataSet<PluginFolder>>(
        stream: Stream.fromFuture(ZpdlStudioMediaPlugin.getImageFolder()),
        onData: (data) async {
          updateTimeMs = data.timeMs;
          bool foundCurrentFolder = false;

          for(final folder in data.list) {
            if(!foundCurrentFolder && folder.id == currentFolderId) {
              foundCurrentFolder = true;
              break;
            }
          }

          if(!foundCurrentFolder) {
            currentFolderId = null;
          }

          final List<AlbumFolder> list = List();
          list.add(AlbumFolder(PluginFolder(
            null, "All", await ZpdlStudioMediaPlugin.getImageFolderCount(null)
          ), selected: this.currentFolderId == null));
          for(final folder in data.list) {
            list.add(AlbumFolder(folder, selected: currentFolderId == folder.id));
          }

          // _folders.sink.add([list.first]);
          _folders.sink.add(list);
          refreshFiles(currentFolderId);
        });
  }

  StreamSubscription filesStreamSubscription;

  void refreshFiles(String folderId) {
    filesStreamSubscription?.cancel();
    filesStreamSubscription = scaffoldSubscription<PluginDataSet<PluginImage>>(
        stream: Stream.fromFuture(ZpdlStudioMediaPlugin.getImages(folderId)),
        onData: (data) {
          _images.sink.add(data.list);
        },
        onDone: (bool success) {
          filesStreamSubscription = null;
        }
        );
  }

  void changeFolder(AlbumFolder folder) async {
    if(currentFolderId != folder.folder.id) {
      currentFolderId = folder.folder.id;

      final folders = await _folders.first;
      for(final folder in folders) {
        folder.selected = currentFolderId == folder.folder.id;
      }

      _folders.sink.add(folders);
      refreshFiles(currentFolderId);
    }
  }

  void onTapImage(PluginImage image) async {
    BuildContext context = buildContext;
    if(context != null) {
      String folderName = "";
      final folders = await _folders.first;
      for(final folder in folders) {
        if(folder.selected) {
          folderName = folder.folder.displayName;
          break;
        }
      }
      final images = await _images.first;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AlbumPreviewScaffold(folderName, image.id, images)));
    }
  }
}

class AlbumFolder {
  final PluginFolder folder;
  bool selected;

  AlbumFolder(this.folder, {bool selected}): this.selected = selected ?? false;
}
