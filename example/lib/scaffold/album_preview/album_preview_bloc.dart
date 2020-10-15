import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';

class AlbumPreviewBLoC extends BLoCScaffold with BLoCParent {
  String currentId;

  AlbumPreviewBLoC(
      this.folderName, String currentId, List<PluginImage> list) {
    _images.sink.add(list);
    int initPosition = 0;
    for(int i = 0; i < list.length; i++) {
      if(list[i].id == currentId) {
        initPosition = i;
      }
    }
    if(initPosition < list.length) {
      _image.sink.add(list[initPosition]);
    }
  }

  final String folderName;

  final _images = BehaviorSubject<List<PluginImage>>();
  Stream<List<PluginImage>> get getImagesStream => _images.stream;

  final _image = BehaviorSubject<PluginImage>();
  Stream<PluginImage> get getImageStream => _image.stream;

  @override
  void dispose() {
    _images.close();
    _image.close();
  }
}
