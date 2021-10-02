  import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/services/FileService.dart';
import 'package:photo_editor_pro/utils/Colors.dart';

import '../main.dart';

class CompressImageScreen extends StatefulWidget {
  static String tag = '/CompressImageScreen';
  final File file;

  CompressImageScreen({required this.file});

  @override
  CompressImageScreenState createState() => CompressImageScreenState();
}

class CompressImageScreenState extends State<CompressImageScreen> {
  File? originalFile;
  File? compressedFile;

  int originalFileSize = 0;
  int compressFileSize = 0;

  bool isCompress = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    originalFile = widget.file;

    originalFileSize = originalFile!.lengthSync().toDouble() ~/ 1024.0;
  }

  Future<void> compressFile() async {
    appStore.setLoading(true);

    compressedFile = await getCompressedFile(originalFile, await getFileSavePathWithName(), onDone: (aOriginalFileSize, aCompressFileSize) {
      appStore.setLoading(false);

      compressFileSize = aCompressFileSize;
      isCompress = true;

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString());
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
        appBar: appBarWidget('Compress Image'),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Original File', style: boldTextStyle()),
                            8.height,
                            Image.file(originalFile!, height: (context.height() / 2) - 60, fit: BoxFit.cover),
                          ],
                        ).expand(),
                        16.width,
                        if (compressedFile != null)
                          Column(
                            children: [
                              Text('Compressed File', style: boldTextStyle(color: colorPrimary)),
                              8.height,
                              Image.file(compressedFile!, height: (context.height() / 2) - 60, fit: BoxFit.cover),
                            ],
                          ).expand(),
                      ],
                    ),
                    30.height,
                    Text("Original file size: $originalFileSize kb", style: primaryTextStyle()),
                    16.height,
                    compressedFile != null
                        ? RichText(
                            text: TextSpan(
                              text: 'Compress file size: ',
                              style: boldTextStyle(size: 18),
                              children: <TextSpan>[
                                TextSpan(text: compressFileSize.toString(), style: boldTextStyle(size: 18)),
                                TextSpan(text: ' kb', style: primaryTextStyle()),
                              ],
                            ),
                          )
                        : SizedBox(),
                    8.height,
                    compressedFile != null ? Text("You saved: ${originalFileSize - compressFileSize} kb", style: boldTextStyle(color: Color(0xFF00A508))) : SizedBox(),
                  ],
                ),
              ],
            ),
            AppButton(
              child: Text('Compress', style: boldTextStyle(color: Colors.white)),
              color: colorPrimary,
              width: context.width(),
              onTap: () {
                compressFile();
              },
            ).paddingAll(16).visible(!isCompress == true),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
