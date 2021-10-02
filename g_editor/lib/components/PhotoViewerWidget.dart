import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/screens/PhotoEditScreen.dart';
import 'package:photo_editor_pro/utils/Colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';

class PhotoViewerWidget extends StatefulWidget {
  static String tag = '/PhotoViewerWidget';
  final FileSystemEntity fileSystemEntity;

  PhotoViewerWidget(this.fileSystemEntity);

  @override
  _PhotoViewerWidgetState createState() => _PhotoViewerWidgetState();
}

class _PhotoViewerWidgetState extends State<PhotoViewerWidget> {
  ImageProvider? imageProvider;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    imageProvider = Image.file(File(widget.fileSystemEntity.path)).image;
    hideStatusBar();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    showStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(
          '',
          color: scaffoldColorDark,
          textColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                PhotoEditScreen(file: File(widget.fileSystemEntity.path)).launch(context, isNewTask: true);
              },
            ),
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {
                Share.shareFiles([widget.fileSystemEntity.path]);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                showConfirmDialog(context, 'Do you want to delete this picture?', buttonColor: colorPrimary).then((value) {
                  if (value ?? false) {
                    File(widget.fileSystemEntity.path).deleteSync();

                    finish(context);
                  }
                });
              },
            ),
          ],
        ),
        body: PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: 1.0,
        ),
      ),
    );
  }
}
