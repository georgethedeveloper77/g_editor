import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/services/FileService.dart';
import 'package:photo_editor_pro/utils/Colors.dart';

import '../main.dart';

class ResizeImageScreen extends StatefulWidget {
  static String tag = '/ResizeImageScreen';
  final File? file;

  ResizeImageScreen({this.file});

  @override
  ResizeImageScreenState createState() => ResizeImageScreenState();
}

class ResizeImageScreenState extends State<ResizeImageScreen> {
  File? originalFile;
  double sliderValue = 0;

  int? originalWidth = 0;
  int? originalHeight = 0;
  int? resizeHeight = 0;
  int? resizeWidth = 0;
  int originalData = 0;
  int resizeKbData = 0;

  bool isResize = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    originalFile = widget.file;

    FlutterNativeImage.getImageProperties(originalFile!.path).then((properties) {
      originalWidth = properties.width;
      originalHeight = properties.height;

      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget('Resize Image'),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: originalFile != null ? Image.file(originalFile!, height: (context.height() / 2) - 60, fit: BoxFit.cover) : SizedBox()),
                    16.height,
                    Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      label: '${sliderValue.round()}',
                      onChanged: (double value) {
                        sliderValue = value;

                        setState(() {});
                      },
                    ).visible(!isResize),
                    16.height.visible(!isResize),
                    Text('Make image ${sliderValue.toInt()}% smaller', style: boldTextStyle(size: 20)).visible(!isResize),
                    16.height,
                    Text('Original image resolution: $originalWidth * $originalHeight', style: primaryTextStyle()),
                    8.height,
                    resizeHeight! > 0 && resizeHeight! > 0 ? Text("Resized image resolution: $resizeWidth * $resizeHeight", style: boldTextStyle()) : SizedBox(),
                    16.height,
                    Text('Original image size: $originalData kb', style: primaryTextStyle()).visible(originalData != 0),
                    8.height,
                    Text('Resized image size: $resizeKbData kb', style: boldTextStyle()).visible(resizeKbData != 0),
                  ],
                ),
              ],
            ),
            AppButton(
              color: colorPrimary,
              child: Text('Resize', style: boldTextStyle(color: Colors.white)),
              width: context.width(),
              onTap: () async {
                if (sliderValue.validate() >= 1) {
                  appStore.setLoading(true);

                  getResizeFile(originalFile, sliderValue, onDone: (height, width, resizeKb, originalKb) {
                    appStore.setLoading(false);

                    resizeHeight = height;
                    resizeWidth = width;
                    originalData = originalKb;
                    resizeKbData = resizeKb;

                    isResize = true;

                    setState(() {});
                  }).catchError((e) {
                    appStore.setLoading(false);

                    toast(errorSomethingWentWrong);
                  });
                } else {
                  toast('');
                }
              },
            ).paddingAll(16).visible(!isResize == true),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
