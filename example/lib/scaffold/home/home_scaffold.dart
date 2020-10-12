import 'package:flutter/material.dart';
import 'package:zpdl_studio_bloc/bloc/bloc.dart';
import 'package:zpdl_studio_bloc/bloc/bloc_scaffold.dart';
import 'package:zpdl_studio_media_plugin_example/scaffold/album/album_list_scaffold.dart';

class _Bloc extends BLoCScaffold with BLoCLoading {

  @override
  void dispose() {

  }

  void showLoading() {

  }
}

class HomeScaffold extends BLoCScaffoldProvider<_Bloc> {

  HomeScaffold({Key key}): super(key: key);

  @override
  _Bloc createBLoC() => _Bloc();

  @override
  PreferredSizeWidget appBar(BuildContext context, _Bloc bloc) => AppBar(
        title: const Text('Home'),
      );

  @override
  Widget body(BuildContext context, _Bloc bloc) {
    return SafeArea(
      child: ListView(
        children: [
          ListTile(
            title: Text('Image Album'),
            subtitle: Text('Plugin Image Album'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlbumListScaffold()));
            },
          )
        ],
      ),
    );
  }
}
