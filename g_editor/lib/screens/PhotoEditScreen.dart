import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/components/BlurSelectorBottomSheet.dart';
import 'package:photo_editor_pro/components/BottomBarItemWidget.dart';
import 'package:photo_editor_pro/components/ColorSelectorBottomSheet.dart';
import 'package:photo_editor_pro/components/EmojiPickerBottomSheet.dart';
import 'package:photo_editor_pro/components/FilterSelectionWidget.dart';
import 'package:photo_editor_pro/components/FrameSelectionWidget.dart';
import 'package:photo_editor_pro/components/ImageFilterWidget.dart';
import 'package:photo_editor_pro/components/SignatureWidget.dart';
import 'package:photo_editor_pro/components/StackedWidgetComponent.dart';
import 'package:photo_editor_pro/components/StickerPickerBottomSheet.dart';
import 'package:photo_editor_pro/components/TextEditorDialog.dart';
import 'package:photo_editor_pro/models/ColorFilterModel.dart';
import 'package:photo_editor_pro/models/StackedWidgetModel.dart';
import 'package:photo_editor_pro/screens/HomeScreen.dart';
import 'package:photo_editor_pro/services/FileService.dart';
import 'package:photo_editor_pro/utils/Colors.dart';
import 'package:photo_editor_pro/utils/Common.dart';
import 'package:photo_editor_pro/utils/Constants.dart';
import 'package:photo_editor_pro/utils/SignatureLibWidget.dart';
import 'package:screenshot/screenshot.dart';

import '../main.dart';

class PhotoEditScreen extends StatefulWidget {
  static String tag = '/PhotoEditScreen';
  final File? file;

  PhotoEditScreen({this.file});

  @override
  PhotoEditScreenState createState() => PhotoEditScreenState();
}

class PhotoEditScreenState extends State<PhotoEditScreen> {
  final GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey key = GlobalKey<PhotoEditScreenState>();
  final ScrollController scrollController = ScrollController();

  DateTime? currentBackPressTime;

  /// Google Ads
  RewardedAd? rewardedAd;
  InterstitialAd? myInterstitial;
  bool mIsImageSaved = false;

  /// Used to save edited image on storage
  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey screenshotKey = GlobalKey();
  final GlobalKey imageKey = GlobalKey();

  /// Used to draw on image
  SignatureController signatureController = SignatureController(penStrokeWidth: 5, penColor: Colors.green);
  List<Offset> points = [];

  /// Texts on image
  List<StackedWidgetModel> mStackedWidgetList = [];

  /// Image file picked from previous screen
  File? originalFile;
  File? croppedFile;

  double topWidgetHeight = 80, bottomWidgetHeight = 80, blur = 0;

  /// Variables used to show or hide bottom widgets
  bool mIsPenColorVisible = false, mIsFilterViewVisible = false, mIsBlurVisible = false, mIsFrameVisible = false;
  bool mIsBrightnessSliderVisible = false, mIsSaturationSliderVisible = false, mIsHueSliderVisible = false, mIsContrastSliderVisible = false;
  bool mIsMoreConfigWidgetVisible = true;
  bool mIsPenEnabled = false;
  bool mShowBeforeImage = false;

  /// Selected color filter
  ColorFilterModel? filter;

  double brightness = 0.0, saturation = 0.0, hue = 0.0, contrast = 0.0;

  /// Selected frame
  String? frame;

  double? imageHeight;
  double? imageWidth;

  @override
  void initState() {
    //saveToDirectory(originalFile);
    WidgetsBinding.instance!.addPostFrameCallback((_) => getImageSize());
    setState(() {});

    super.initState();
    init();

    setStatusBarColor(white);
  }

  Future<void> getImageSize() async {
    await 2.seconds.delay;
    imageHeight = imageKey.currentContext!.size!.height;
    imageWidth = imageKey.currentContext!.size!.width;
    log(imageHeight);
    log(imageWidth);
    if (imageHeight.validate().toInt() == 0) {
      imageHeight = context.height();
    }
    if (imageWidth.validate().toInt() == 0) {
      imageWidth = context.width();
    }
    setState(() {});
  }

  Future<void> init() async {
    originalFile = widget.file;
    croppedFile = widget.file;

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        mIsMoreConfigWidgetVisible = false;
      } else {
        mIsMoreConfigWidgetVisible = true;
      }

      setState(() {});
    });

    if (!disableAdMob) {
      createInterstitialAd();
    }
  }

  Future<void> capture() async {
    appStore.setLoading(true);

    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    setState(() {});

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

    appStore.setLoading(false);

    HomeScreen().launch(context, isNewTask: true);
  }

  void onEraserClick() {
    showConfirmDialog(context, 'Do you want to clear?', buttonColor: colorPrimary).then((value) {
      if (value ?? false) {
        mIsBlurVisible = false;
        mIsFilterViewVisible = false;
        mIsFrameVisible = false;
        mIsPenColorVisible = false;
        mIsBrightnessSliderVisible = false;
        mIsSaturationSliderVisible = false;
        mIsHueSliderVisible = false;
        mIsContrastSliderVisible = false;

        /// Clear signature
        signatureController.clear();
        points.clear();

        /// Clear stacked widgets
        mStackedWidgetList.clear();

        /// Clear filter
        filter = null;

        /// Clear blur effect
        blur = 0;

        /// Clear frame
        frame = null;

        /// Clear brightness, contrast, saturation, hue
        brightness = 0.0;
        saturation = 0.0;
        hue = 0.0;
        contrast = 0.0;

        setState(() {});
      }
    }).catchError(log);
  }

  Future<void> onTextClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    setState(() {});

    String? text = await showInDialog(context, builder: (_) => TextEditorDialog());

    if (text.validate().isNotEmpty) {
      var stackedWidgetModel = StackedWidgetModel(
        value: text,
        widgetType: WidgetTypeText,
        offset: Offset(100, 100),
        size: 20,
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
      );
      mStackedWidgetList.add(
        stackedWidgetModel,
      );

      setState(() {});
    }
  }

  Future<void> onNeonLightClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    setState(() {});

    String? text = await showInDialog(context, builder: (_) => TextEditorDialog());

    if (text.validate().isNotEmpty) {
      mStackedWidgetList.add(
        StackedWidgetModel(
          value: text,
          widgetType: WidgetTypeNeon,
          offset: Offset(100, 100),
          size: 40,
          backgroundColor: Colors.transparent,
          textColor: getColorFromHex('#FF7B00AB'),
        ),
      );

      setState(() {});
    }
  }

  Future<void> onEmojiClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    setState(() {});

    appStore.setLoading(true);
    await 300.milliseconds.delay;

    String? emoji = await showModalBottomSheet(context: context, builder: (_) => EmojiPickerBottomSheet());

    if (emoji.validate().isNotEmpty) {
      mStackedWidgetList.add(
        StackedWidgetModel(
          value: emoji,
          widgetType: WidgetTypeEmoji,
          offset: Offset(100, 100),
          size: 50,
        ),
      );

      setState(() {});
    }
  }

  Future<void> onStickerClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    setState(() {});

    appStore.setLoading(true);
    await 300.milliseconds.delay;

    String? sticker = await showModalBottomSheet(context: context, builder: (_) => StickerPickerBottomSheet());

    if (sticker.validate().isNotEmpty) {
      mStackedWidgetList.add(
        StackedWidgetModel(
          value: sticker,
          widgetType: WidgetTypeSticker,
          offset: Offset(100, 100),
          size: 100,
        ),
      );

      setState(() {});
    }
  }

  void onPenClick() {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsPenColorVisible = !mIsPenColorVisible;

    setState(() {});
  }

  void onBlurClick() {
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBlurVisible = !mIsBlurVisible;

    setState(() {});
  }

  Future<void> onFilterClick() async {
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsFilterViewVisible = !mIsFilterViewVisible;

    setState(() {});
  }

  Future<void> onFrameClick() async {
    if (getBoolAsync(IS_FRAME_REWARDED)) {
      mIsPenColorVisible = false;
      mIsBlurVisible = false;
      mIsFilterViewVisible = false;
      mIsBrightnessSliderVisible = false;
      mIsSaturationSliderVisible = false;
      mIsHueSliderVisible = false;
      mIsContrastSliderVisible = false;
      mIsFrameVisible = !mIsFrameVisible;

      setState(() {});
    } else {
      /*if (rewardedAd != null && await rewardedAd.isLoaded()) {
        rewardedAd.show();

        toast('Showing reward ad');
      }*/
    }
  }

  Future<void> onBrightnessSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBrightnessSliderVisible = !mIsBrightnessSliderVisible;

    setState(() {});
  }

  Future<void> onSaturationSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsSaturationSliderVisible = !mIsSaturationSliderVisible;

    setState(() {});
  }

  Future<void> onHueSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsHueSliderVisible = !mIsHueSliderVisible;

    setState(() {});
  }

  Future<void> onContrastSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = !mIsContrastSliderVisible;

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    signatureController.dispose();
    scrollController.dispose();
    rewardedAd?.dispose();
    myInterstitial?.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast('Press back again to exit from the app');
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          body: Container(
            height: context.height(),
            width: context.width(),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: topWidgetHeight,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CloseButton(
                            onPressed: () {
                              showConfirmDialog(context, 'You edited image will be lost', buttonColor: colorPrimary).then((value) {
                                if (value ?? false) {
                                  HomeScreen().launch(context, isNewTask: true);
                                }
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.crop),
                                onPressed: () {
                                  cropImage(originalFile!, onDone: (file) {
                                    croppedFile = file;
                                    getImageSize();
                                    setState(() {});
                                  }).catchError(log);
                                },
                              ).withTooltip(msg: 'Crop'),
                              /*IconButton(
                                icon: Icon(Icons.undo_outlined),
                                onPressed: () {
                                  //
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.redo_outlined),
                                onPressed: () {
                                  //
                                },
                              ),*/
                              GestureDetector(
                                onTapDown: (v) {
                                  mShowBeforeImage = true;
                                  setState(() {});
                                },
                                onTapUp: (v) {
                                  mShowBeforeImage = false;
                                  setState(() {});
                                },
                                onTapCancel: () {
                                  mShowBeforeImage = false;
                                  setState(() {});
                                },
                                child: Icon(Icons.compare_rounded).paddingAll(8),
                              ),
                              16.width,
                              Text('Save', style: boldTextStyle(color: colorPrimary)).paddingSymmetric(horizontal: 16, vertical: 8).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])).onTap(() {
                                capture();
                              }, borderRadius: radius()),
                            ],
                          ),
                        ],
                      ).paddingTop(16),
                    ),
                    Container(
                      height: imageHeight,
                      width: imageWidth,
                      child: Stack(
                        //fit: StackFit.expand,
                        children: [
                          /// This widget will be saved as edited Image
                          Screenshot(
                            controller: screenshotController,
                            key: screenshotKey,
                            child: Stack(
                              alignment: Alignment.center,
                              //fit: StackFit.expand,
                              children: [
                                (filter != null && filter!.matrix != null)
                                    ? ColorFiltered(
                                        colorFilter: ColorFilter.matrix(filter!.matrix!),
                                        child: Center(
                                          child: ImageFilterWidget(
                                            brightness: brightness,
                                            saturation: saturation,
                                            hue: hue,
                                            contrast: contrast,
                                            child: Image.file(croppedFile!, fit: BoxFit.fitWidth),
                                          ),
                                        ),
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            child: ImageFilterWidget(
                                              brightness: brightness,
                                              saturation: saturation,
                                              hue: hue,
                                              contrast: contrast,
                                              child: Image.file(croppedFile!, fit: BoxFit.fitWidth, key: imageKey),
                                            ),
                                          ),
                                          if (filter != null && filter!.color != null)
                                            Container(
                                              height: imageHeight,
                                              width: imageWidth,
                                              color: Colors.black12,
                                            ).withShaderMaskGradient(
                                              LinearGradient(colors: filter!.color!, begin: Alignment.topLeft, end: Alignment.bottomRight),
                                              blendMode: BlendMode.srcOut,
                                            ),
                                        ],
                                      ),
                                ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                    child: Container(
                                      alignment: Alignment.center,
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                /*(filter != null && filter!.color != null)
                                    ? Container(
                                        //height: context.height(),
                                        width: context.width(),
                                        color: Colors.black12,
                                        child: SizedBox(),
                                      ).withShaderMaskGradient(
                                        LinearGradient(colors: filter!.color!, begin: Alignment.topLeft, end: Alignment.bottomRight),
                                        blendMode: BlendMode.srcOut,
                                      )
                                    : SizedBox(),*/
                                frame != null
                                    ? Container(
                                        color: Colors.black12,
                                        child: Image.asset(
                                          frame!,
                                          fit: BoxFit.fill,
                                          height: context.height(),
                                          width: context.width(),
                                        ),
                                      )
                                    : SizedBox(),
                                IgnorePointer(
                                  ignoring: !mIsPenEnabled,
                                  child: SignatureWidget(
                                    signatureController: signatureController,
                                    points: points,
                                    width: context.width(),
                                    height: context.height() * 0.8,
                                  ),
                                ),
                                StackedWidgetComponent(mStackedWidgetList),
                              ],
                            ).center(),
                          ),
                          Positioned(
                            bottom: -10,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsPenColorVisible ? 80 : 0,
                              color: Colors.white38,
                              width: context.width(),
                              child: Row(
                                children: [
                                  Switch(
                                    value: mIsPenEnabled,
                                    onChanged: (b) {
                                      mIsPenEnabled = b;
                                      mIsPenColorVisible = false;

                                      setState(() {});
                                    },
                                  ),
                                  ColorSelectorBottomSheet(
                                    list: penColors,
                                    onColorSelected: (Color color) {
                                      List<Point> tempPoints = signatureController.points;
                                      signatureController = SignatureController(penStrokeWidth: 5, penColor: color);

                                      tempPoints.forEach((element) {
                                        signatureController.addPoint(element);
                                      });

                                      mIsPenColorVisible = false;
                                      mIsPenEnabled = true;

                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsBrightnessSliderVisible ? 120 : 0,
                              width: context.width(),
                              child: Container(
                                color: Colors.white38,
                                height: 60,
                                child: Row(
                                  children: [
                                    8.width,
                                    Text('Brightness'),
                                    8.width,
                                    Slider(
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (d) {
                                        brightness = d;

                                        setState(() {});
                                      },
                                      value: brightness,
                                    ).expand(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsContrastSliderVisible ? 120 : 0,
                              width: context.width(),
                              child: Container(
                                color: Colors.white38,
                                height: 60,
                                child: Row(
                                  children: [
                                    8.width,
                                    Text('Contrast'),
                                    8.width,
                                    Slider(
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (d) {
                                        contrast = d;

                                        setState(() {});
                                      },
                                      value: contrast,
                                    ).expand(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsSaturationSliderVisible ? 120 : 0,
                              width: context.width(),
                              child: Container(
                                color: Colors.white38,
                                height: 60,
                                child: Row(
                                  children: [
                                    8.width,
                                    Text('Saturation'),
                                    8.width,
                                    Slider(
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (d) {
                                        saturation = d;

                                        setState(() {});
                                      },
                                      value: saturation,
                                    ).expand(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsHueSliderVisible ? 120 : 0,
                              width: context.width(),
                              child: Container(
                                color: Colors.white38,
                                height: 60,
                                child: Row(
                                  children: [
                                    8.width,
                                    Text('Hue'),
                                    8.width,
                                    Slider(
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (d) {
                                        hue = d;

                                        setState(() {});
                                      },
                                      value: hue,
                                    ).expand(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsFilterViewVisible ? 120 : 0,
                              width: context.width(),
                              child: FilterSelectionWidget(
                                  image: croppedFile,
                                  onSelect: (v) {
                                    filter = v;

                                    setState(() {});
                                  }),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: mIsFrameVisible ? 120 : 0,
                              width: context.width(),
                              child: FrameSelectionWidget(onSelect: (v) {
                                frame = v;
                                if (v.isEmpty) frame = null;

                                setState(() {});
                              }),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: mIsBlurVisible == true
                                ? AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    height: mIsBlurVisible ? 120 : 0,
                                    color: Colors.white38,
                                    width: context.width(),
                                    child: BlurSelectorBottomSheet(
                                      sliderValue: blur,
                                      onColorSelected: (v) {
                                        blur = v;

                                        setState(() {});
                                      },
                                    ),
                                  )
                                : Container(),
                          ),

                          /// Show preview of edited image before save
                          if (mShowBeforeImage) Image.file(croppedFile!, fit: BoxFit.cover),
                        ],
                      ),
                    ).expand(),
                    Container(
                      height: bottomWidgetHeight,
                      color: Colors.white12,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ListView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            children: [
                              BottomBarItemWidget(title: 'Eraser', icons: Icon(FontAwesomeIcons.eraser).icon, onTap: () => onEraserClick()),
                              BottomBarItemWidget(title: 'Text', icons: Icon(Icons.text_fields_rounded).icon, onTap: () => onTextClick()),
                              BottomBarItemWidget(title: 'Neon', icons: Icon(Icons.text_fields_rounded).icon, onTap: () => onNeonLightClick()),
                              BottomBarItemWidget(title: 'Emoji', icons: Icon(FontAwesomeIcons.smile).icon, onTap: () => onEmojiClick()),
                              BottomBarItemWidget(title: 'Stickers', icons: Icon(FontAwesomeIcons.smileWink).icon, onTap: () => onStickerClick()),

                              /// Will be added in next update due to multiple finger bug
                              //BottomBarItemWidget(title: 'Pen', icons: Icon(FontAwesomeIcons.penFancy).icon, onTap: () => onPenClick()),

                              BottomBarItemWidget(title: 'Brightness', icons: Icon(Icons.brightness_2_outlined).icon, onTap: () => onBrightnessSliderClick()),
                              BottomBarItemWidget(title: 'Contrast', icons: Icon(Icons.brightness_4_outlined).icon, onTap: () => onContrastSliderClick()),
                              BottomBarItemWidget(title: 'Saturation', icons: Icon(Icons.brightness_4_sharp).icon, onTap: () => onSaturationSliderClick()),
                              BottomBarItemWidget(title: 'Hue', icons: Icon(Icons.brightness_medium_sharp).icon, onTap: () => onHueSliderClick()),
                              BottomBarItemWidget(title: 'Blur', icons: Icon(MaterialCommunityIcons.blur).icon, onTap: () => onBlurClick()),
                              BottomBarItemWidget(title: 'Filter', icons: Icon(Icons.photo).icon, onTap: () => onFilterClick()),
                              BottomBarItemWidget(title: 'Frame', icons: getBoolAsync(IS_FRAME_REWARDED) ? Icon(Icons.filter_frames).icon : Icon(Icons.lock_outline_rounded).icon, onTap: () => onFrameClick()),
                            ],
                          ),
                          Positioned(
                            child: AnimatedCrossFade(
                              firstChild: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
                              secondChild: Offstage(),
                              crossFadeState: mIsMoreConfigWidgetVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              duration: 700.milliseconds,
                            ),
                            right: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Observer(builder: (_) => Loader().visible(appStore.isLoading)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
