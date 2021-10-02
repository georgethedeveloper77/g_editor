import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/components/CollegeMakerLayoutWidget.dart';
import 'package:photo_editor_pro/components/ColorSelectorBottomSheet.dart';
import 'package:photo_editor_pro/main.dart';
import 'package:photo_editor_pro/models/CollegeMakerModel.dart';
import 'package:photo_editor_pro/screens/HomeScreen.dart';
import 'package:photo_editor_pro/services/FileService.dart';
import 'package:photo_editor_pro/utils/Colors.dart';
import 'package:photo_editor_pro/utils/Common.dart';
import 'package:photo_editor_pro/utils/Constants.dart';
import 'package:photo_editor_pro/utils/DataProvider.dart';
import 'package:screenshot/screenshot.dart';

class CollegeMakerScreen extends StatefulWidget {
  static String tag = '/CollegeMakerScreen';
  final bool? isAutomatic;

  CollegeMakerScreen({this.isAutomatic});

  @override
  CollegeMakerScreenState createState() => CollegeMakerScreenState();
}

class CollegeMakerScreenState extends State<CollegeMakerScreen> {
  ScrollController scrollController = ScrollController();
  List<CollegeMakerModel> list = getCollegeMakerList();

  int collegeItemIndex = 0;
  int layoutIndex = 0;

  bool mIsImageSaved = false;

  /// Used to save edited image on storage
  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey screenshotKey = GlobalKey();

  /// spacing
  double imageSpacing = 0;
  double minSpacing = 0.0, maxSpacing = 10.0;

  /// border radius
  double borderRadius = 0;
  double minBorderRadius = 0.0, maxBorderRadius = 50.0;

  /// border width
  double borderWidth = 0;
  double minWidth = 0.0, maxWidth = 10.0;

  /// border color list item index
  int borderColorIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    list.forEach((e) {
      if (e.itemCount == appStore.collegeMakerImageList.length) {
        collegeItemIndex = list.indexOf(e);
        setState(() {});
      }
    });
  }

  gotoHomeDialog() {
    showConfirmDialog(context, 'You edited image will be lost', buttonColor: colorPrimary).then((value) {
      if (value ?? false) {
        appStore.clearCollegeImageList();
        HomeScreen().launch(context, isNewTask: true);
      }
    });
  }

  Widget borderWidget(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Border width', style: boldTextStyle()).paddingOnly(left: 16, top: 8, right: 16, bottom: 16),
          Slider(
            value: borderWidth,
            min: minWidth,
            max: maxWidth,
            onChangeEnd: (v) {
              borderWidth = v;
              setState(() {});
            },
            onChanged: (v) {
              borderWidth = v;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget radiusWidget(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Border radius', style: boldTextStyle()).paddingOnly(left: 16, top: 8, right: 16, bottom: 16),
          Slider(
            value: borderRadius,
            min: minBorderRadius,
            max: maxBorderRadius,
            onChangeEnd: (v) {
              borderRadius = v;
              setState(() {});
            },
            onChanged: (v) {
              borderRadius = v;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget spacingWidget(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spacing', style: boldTextStyle()).paddingOnly(left: 16, top: 8, right: 16, bottom: 16),
          Slider(
            value: imageSpacing,
            min: minSpacing,
            max: maxSpacing,
            onChangeEnd: (v) {
              imageSpacing = v;
              setState(() {});
            },
            onChanged: (v) {
              imageSpacing = v;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> saveImage() async {
    await screenshotController.captureAndSave(await getFileSavePath(), delay: 1.seconds).then((value) async {
      toast('Saved');
      log('Saved : $value');

      mIsImageSaved = true;

      if (myInterstitial != null) {
        myInterstitial!.show().then((value) {
          myInterstitial?.dispose();
        });
      } else {
        showInterstitialAd(context);
      }
    }).catchError((e) {
      log(e);
      e.toString().toastString();
    });

    appStore.clearCollegeImageList();

    HomeScreen().launch(context, isNewTask: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool mISClose = await gotoHomeDialog();
        if (mISClose) {
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        appBar: appBarWidget(
          'College Maker',
          showBack: true,
          backWidget: CloseButton(
            onPressed: gotoHomeDialog,
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveImage();
              },
              child: Text('Save', style: boldTextStyle(size: 20)).withShaderMaskGradient(
                LinearGradient(colors: [itemGradient1, itemGradient2]),
              ),
            ),
          ],
        ),
        body: Container(
          width: context.width(),
          height: context.height(),
          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                key: screenshotKey,
                child: widget.isAutomatic!
                    ? CollegeMakerLayoutWidget(
                        columnCountList: getCollegeMakerList()[collegeItemIndex].listCount![Random().nextInt(getCollegeMakerList()[collegeItemIndex].listCount!.length)],
                        borderWidth: itemWidth.toDouble(),
                        borderRadius: itemRadius.toDouble(),
                        spacing: itemSpacing.toDouble(),
                        borderColor: backgroundColors[Random().nextInt(backgroundColors.length)],
                      ).paddingAll(4)
                    : CollegeMakerLayoutWidget(
                        columnCountList: getCollegeMakerList()[collegeItemIndex].listCount![layoutIndex],
                        borderWidth: borderWidth,
                        borderRadius: borderRadius,
                        spacing: imageSpacing,
                        borderColor: backgroundColors[borderColorIndex],
                      ).paddingAll(4),
              ).expand(),
              DefaultTabController(
                length: 5,
                initialIndex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(child: Text('Layout')),
                        Tab(child: Text('Border Width')),
                        Tab(child: Text('Border Color')),
                        Tab(child: Text('Border Radius')),
                        Tab(child: Text('Image Spacing')),
                      ],
                    ),
                    Container(
                      height: context.height() * 0.15,
                      child: TabBarView(
                        children: [
                          Container(
                            width: context.width(),
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: getCollegeMakerList()[collegeItemIndex].listCount!.length,
                              itemBuilder: (context, index) {
                                String image = getCollegeMakerList()[collegeItemIndex].thumbnails![index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: layoutIndex == index ? itemGradient1 : Colors.grey.shade300),
                                  ),
                                  child: Image.asset(
                                    'images/collegeMaker/$image',
                                    height: 50,
                                    width: 50,
                                    color: layoutIndex == index ? itemGradient1 : Colors.grey.shade400,
                                  ),
                                )
                                    .onTap(() {
                                      layoutIndex = index;
                                      setState(() {});
                                    }, borderRadius: BorderRadius.circular(4))
                                    .center()
                                    .paddingAll(8);
                              },
                            ),
                          ),
                          borderWidget(context),
                          ColorSelectorBottomSheet(
                            list: backgroundColors,
                            selectedColor: backgroundColors[borderColorIndex],
                            onColorSelected: (c) {
                              borderColorIndex = backgroundColors.indexOf(c);
                              setState(() {});
                            },
                          ),
                          radiusWidget(context),
                          spacingWidget(context),
                        ],
                      ),
                    )
                  ],
                ),
              ).visible(!widget.isAutomatic!),
            ],
          ),
        ),
      ),
    );
  }
}
