import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_child.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_media_plugin/plugin_data.dart';

import 'album_preview_page.dart';

class AlbumPreviewBLoC extends BLoCScaffold with BLoCParent, BLoCKeyboardState {
  String currentId;
  PageController pageController;

  AlbumPreviewBLoC(
      this.folderName, String currentId, List<PluginImage> list) {
    List<AlbumPreviewPageBLoC> page = List();
    int initPosition = 0;
    for(int i = 0; i < list.length; i++) {
      if(list[i].id == currentId) {
        initPosition = i;
      }
      final pageBLoC = AlbumPreviewPageBLoC(list[i]);
      page.add(pageBLoC);
      addChild(pageBLoC);
    }
    _pageBLoC.sink.add(page);
    pageController = PageController(initialPage: initPosition);
  }

  final String folderName;

  final _pageBLoC = BehaviorSubject<List<AlbumPreviewPageBLoC>>();
  Stream<List<AlbumPreviewPageBLoC>> get getPageBLoCStream => _pageBLoC.stream;

  @override
  void dispose() {
    _pageBLoC.close();
  }

  @override
  void onKeyboardState(bool show) {
    super.onKeyboardState(show);
    print("KKH onKeyboardState AlbumPreviewBLoC $show");
  }
}
