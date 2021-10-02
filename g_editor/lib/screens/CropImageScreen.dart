import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/main.dart';
import 'package:photo_editor_pro/services/FileService.dart';
import 'package:photo_editor_pro/utils/Colors.dart';
import 'package:photo_editor_pro/utils/Common.dart';
import 'package:photo_editor_pro/utils/Constants.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class CropImageScreen extends StatefulWidget {
  static String tag = '/CompressImageScreen';
  final File? file;

  CropImageScreen({this.file});

  @override
  CropImageScreenState createState() => CropImageScreenState();
}

class CropImageScreenState extends State<CropImageScreen> {
  bool mIsImageSaved = false;

  AppState state = AppState.picked;

  File? imageFile;
  File? originalFile;

  String title = "";

  @override
  void initState() {
    super.initState();
    originalFile = widget.file;

    init();
  }

  Future<void> init() async {
    cropImage(originalFile!, onDone: (file) {
      imageFile = file;

      state = AppState.cropped;

      saveToDirectory(imageFile);

      if (myInterstitial != null) showInterstitialAd(context);

      setState(() {});
    }).catchError(log);

    if (!disableAdMob) {
      createInterstitialAd();
    }
  }


  void changeTitleText() {
    if (state == AppState.free) {
      title = 'Pick Image';
    } else if (state == AppState.picked) {
      title = 'Crop';
    } else if (state == AppState.cropped) {
      title = 'Clear';
    } else {
      title = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    myInterstitial!.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    changeTitleText();

    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget('Crop Image'),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  originalFile != null ? Text("Original File", style: boldTextStyle()) : SizedBox(),
                  8.height,
                  originalFile != null ? Image.file(originalFile!, height: (context.height() / 2) - 100) : SizedBox(),
                  8.height,
                  imageFile != null ? Text("Cropped File", style: boldTextStyle()) : SizedBox(),
                  8.height,
                  imageFile != null ? Image.file(imageFile!) : SizedBox(),
                ],
              ),
            ).expand(),
            8.height,
            AppButton(
              text: title,
              color: colorPrimary,
              textStyle: boldTextStyle(color: Colors.white),
              width: context.width(),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
              onTap: () {
                if (state == AppState.free) {
                  pickImage().then((value) {
                    state = AppState.picked;

                    imageFile = null;
                    originalFile = value;

                    init();

                    setState(() {});
                  }).catchError((e) {
                    toast(e.toString());
                  });
                } else if (state == AppState.picked)
                  cropImage(originalFile!, onDone: (i) {
                    state = AppState.cropped;

                    imageFile = i;

                    saveToDirectory(imageFile);

                    mIsImageSaved = true;

                    setState(() {});
                  }).catchError(log);
                else if (state == AppState.cropped) {
                  imageFile = null;
                  originalFile = null;

                  state = AppState.free;

                  setState(() {});
                }
              },
            ).paddingSymmetric(horizontal: 16),
            8.height,
          ],
        ),
      ),
    );
  }
}
