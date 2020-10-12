import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';

class AlbumBloc extends BLoCScaffold with BLoCLoading, BLoCLifeCycle, BLoCStreamSubscription {
  bool _init = false;

  int itemRowCount = 4;
  int itemWidth = 80;
  final int itemSpace = 4;

  String currentFolderId;
  int updateTimeMs = 0;

  final _folder = BehaviorSubject<List<AlbumFolder>>();
  Stream<List<AlbumFolder>> get getFolderStream => _folder.stream;

  final _files = BehaviorSubject<List<PluginImageFile>>();
  Stream<List<PluginImageFile>> get getFilesStream => _files.stream;

  @override
  void dispose() {
    _folder.close();
    _files.close();
  }

  @override
  void onLifeCycleResume(BuildContext context) async {
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
  void onLifeCyclePause(BuildContext context) {

  }

  void refresh() {
    streamSubscription<PluginDataSet<PluginImageFolder>>(
        stream: Stream.fromFuture(ZpdlStudioMediaPlugin.getImageFolder()),
        onData: (data) {
          updateTimeMs = data.timeMs;
          bool foundCurrentFolder = false;
          int count = 0;

          for(final folder in data.list) {
            count += folder.count;
            if(!foundCurrentFolder && folder.id == currentFolderId) {
              foundCurrentFolder = true;
            }
          }

          if(!foundCurrentFolder) {
            currentFolderId = null;
          }

          final List<AlbumFolder> list = List();
          list.add(AlbumFolder(PluginImageFolder(
            null, "All", count, updateTimeMs
          ), selected: this.currentFolderId == null));
          for(final folder in data.list) {
            list.add(AlbumFolder(folder, selected: currentFolderId == folder.id));
          }

          _folder.sink.add(list);
          refreshFiles(currentFolderId);
        });
  }

  StreamSubscription filesStreamSubscription;

  void refreshFiles(String folderId) {
    filesStreamSubscription?.cancel();
    filesStreamSubscription = streamSubscription<List<PluginImageFile>>(
        stream: Stream.fromFuture(ZpdlStudioMediaPlugin.getImageFiles(folderId)),
        onData: (data) {
          _files.sink.add(data);
        },
        onDone: (bool success) {
          filesStreamSubscription = null;
        }
        );
  }

  void changeFolder(AlbumFolder folder) async {
    if(currentFolderId != folder.folder.id) {
      currentFolderId = folder.folder.id;

      final folders = await _folder.first;
      for(final item in folders) {
        item.selected = currentFolderId == item.folder.id;
      }

      _folder.sink.add(folders);
      refreshFiles(currentFolderId);
    }
  }
}

class AlbumFolder {
  final PluginImageFolder folder;
  bool selected;

  AlbumFolder(this.folder, {bool selected}): this.selected = selected ?? false;
}
