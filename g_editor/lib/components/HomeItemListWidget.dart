import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/screens/CollegeMakerScreen.dart';
import 'package:photo_editor_pro/screens/CompressImageScreen.dart';
import 'package:photo_editor_pro/screens/CropImageScreen.dart';
import 'package:photo_editor_pro/screens/PhotoEditScreen.dart';
import 'package:photo_editor_pro/screens/RemoveBackgroundScreen.dart';
import 'package:photo_editor_pro/screens/ResizeImageScreen.dart';
import 'package:photo_editor_pro/screens/TrimVideoScreen.dart';
import 'package:photo_editor_pro/services/FileService.dart';
import 'package:photo_editor_pro/utils/Colors.dart';

import '../main.dart';
import 'HomeItemWidget.dart';

class HomeItemListWidget extends StatefulWidget {
  static String tag = '/HomeItemListWidget';

  @override
  _HomeItemListWidgetState createState() => _HomeItemListWidgetState();
}

class _HomeItemListWidgetState extends State<HomeItemListWidget> {
  void pickImageSource(ImageSource imageSource) {
    pickImage(imageSource: imageSource).then((value) {
      PhotoEditScreen(file: value).launch(context, isNewTask: true);
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      children: [

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.perm_media_outlined, color: Colors.green),
                padding: EdgeInsets.all(16),
              ),
              16.height,
              Text('Pick Image', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            showInDialog(context, contentPadding: EdgeInsets.zero, builder: (context) {
              return Container(
                width: context.width(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Gallery', style: boldTextStyle()).paddingAll(16).onTap(() {
                      finish(context);

                      pickImageSource(ImageSource.gallery);
                    }),
                    Text('Camera', style: boldTextStyle()).paddingAll(16).onTap(() {
                      finish(context);

                      pickImageSource(ImageSource.camera);
                      //var image = ImageSource.camera;
                    }),
                  ],
                ),
              );
            });
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.crop, color: Colors.pink),
                padding: EdgeInsets.all(16),
              ),
              16.height,
              Text('Crop & Rotate', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            pickImage().then((value) => CropImageScreen(file: value).launch(context)).catchError(log);
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.aspect_ratio_sharp, color: Colors.blue),
                padding: EdgeInsets.all(16),
              ),
              16.height,
              Text('Resize', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            pickImage().then((value) => ResizeImageScreen(file: value).launch(context));
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.compress, color: Colors.orange),
                padding: EdgeInsets.all(16),
              ),
              8.height,
              Text('Compress', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            pickImage().then((value) => CompressImageScreen(file: value).launch(context));
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.blur_on_sharp, size: 50, color: Colors.white),
              8.height,
              Text('Remove Background', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            pickImage().then((value) => RemoveBackgroundScreen(file: value).launch(context));
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.dashboard, color: Colors.cyan),
                padding: EdgeInsets.all(16),
              ),
              8.height,
              Text('College Maker', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () async {
            bool? isConfirm = await showConfirmDialog(
              context,
              'ALERT\nChoose at least 2 and maximum 9 images',
              positiveText: 'Choose',
              negativeText: 'Cancel',
              buttonColor: itemGradient1,
            );
            if (isConfirm ?? false) {
              pickMultipleImage().then((value) async {
                if (value.length >= 2 && value.length <= 9) {
                  appStore.clearCollegeImageList();

                  ///compress all image before making college photo
                  await Future.forEach(value, (File? e) async {
                    await FlutterNativeImage.compressImage(e!.path, quality: 70).then((File? f) {
                      if (f != null) {
                        appStore.addCollegeImages(f);
                      }
                    });
                  });
                  await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.all(8),
                          titlePadding: EdgeInsets.all(8),
                          title: Container(
                            width: context.width(),
                            child: Row(
                              children: [
                                Image.asset('images/dialog_human.png', height: 130).paddingOnly(top: 8, bottom: 8, right: 8),
                                Column(
                                  children: [
                                    Text('Which type of', style: boldTextStyle()),
                                    Text('College Maker', style: boldTextStyle(size: 22)).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
                                    Text('You want to create?', style: boldTextStyle()),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  CollegeMakerScreen(isAutomatic: true).launch(context);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius))),
                                ),
                                child: Text('AI Based', style: boldTextStyle()).paddingAll(4),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  CollegeMakerScreen(isAutomatic: false).launch(context);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius))),
                                ),
                                child: Text('Manual', style: boldTextStyle()).paddingAll(4),
                              ),
                            ],
                          ),
                        );
                      });
                } else {
                  toast('Choose at least 2 and maximum 9 images');
                }
              }).catchError((error) {
                log(error.toString());
              });
            }
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.video_library_sharp, color: Colors.redAccent),
                padding: EdgeInsets.all(16),
              ),
              8.height,
              Text('Trim Video', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            pickVideo().then((value) => TrimVideoScreen(file: value).launch(context)).catchError((error) => toast(error.toString()));
          },
        ),

        HomeItemWidget(
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.upcoming_sharp, color: Colors.green),
                padding: EdgeInsets.all(16),
              ),
              8.height,
              Text('More Soon', style: boldTextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            //pickVideo().then((value) => TrimVideoScreen(file: value).launch(context)).catchError((error) => toast(error.toString()));
          },
        ),


      ],
    ).paddingAll(8).center();
  }
}
