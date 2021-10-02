import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/screens/HomeScreen.dart';
import 'package:photo_editor_pro/utils/Colors.dart';
import 'package:share/share.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimVideoScreen extends StatefulWidget {
  static String tag = '/TrimVideoScreen';
  final File file;

  TrimVideoScreen({required this.file});

  @override
  _TrimVideoScreenState createState() => _TrimVideoScreenState();
}

class _TrimVideoScreenState extends State<TrimVideoScreen> {
  File? originalFile;
  File? trimmedFile;
  final Trimmer trimmer = Trimmer();

  double startValue = 0.0;
  double endValue = 0.0;

  bool isPlaying = false;
  bool progressVisibility = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    originalFile = widget.file;

    await trimmer.loadVideo(videoFile: widget.file);

    setState(() {});
  }

  Future<void> saveVideo() async {
    progressVisibility = true;
    setState(() {});
    await trimmer.saveTrimmedVideo(startValue: startValue, endValue: endValue).then((path) async {
      progressVisibility = false;

      log('Path: $path');
      Share.shareFiles([path]);

      await 2.seconds.delay;
      HomeScreen().launch(context, isNewTask: true);

      setState(() {});
    }).catchError((e) {
      log(e);
      progressVisibility = false;
      setState(() {});
      toast('error: ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        'Trim Video',
        actions: [
          TextButton(
            onPressed: () => saveVideo(),
            child: Text('Save', style: boldTextStyle(color: colorPrimary, size: 18)).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            backgroundColor: itemGradient2,
            valueColor: AlwaysStoppedAnimation<Color>(itemGradient1),
          ).visible(progressVisibility),
          8.height,
          Stack(
            alignment: Alignment.center,
            children: [
              VideoViewer(trimmer: trimmer),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  child: isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 60.0,
                        ).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2]))
                      : Icon(
                          Icons.play_arrow,
                          size: 60.0,
                        ).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
                  onPressed: () async {
                    bool playbackState = await trimmer.videPlaybackControl(
                      startValue: startValue,
                      endValue: endValue,
                    );
                    setState(() {
                      isPlaying = playbackState;
                    });
                  },
                ),
              ),
            ],
          ).expand(),
          8.height,
          TrimEditor(
            showDuration: true,
            durationTextStyle: primaryTextStyle(color: Colors.grey),
            trimmer: trimmer,
            viewerHeight: 50.0,
            viewerWidth: context.width() - 8,
            circlePaintColor: colorPrimary,
            maxVideoLength: Duration(hours: 1),
            borderPaintColor: colorPrimary,
            onChangeStart: (value) {
              startValue = value;
            },
            onChangeEnd: (value) {
              endValue = value;
            },
            onChangePlaybackState: (value) {
              setState(() {
                isPlaying = value;
              });
            },
          ).paddingOnly(bottom: 16),
        ],
      ),
    );
  }
}
