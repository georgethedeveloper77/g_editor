import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/utils/DataProvider.dart';

import '../main.dart';

class StickerPickerBottomSheet extends StatefulWidget {
  static String tag = '/StickerPickerBottomSheet';

  @override
  StickerPickerBottomSheetState createState() => StickerPickerBottomSheetState();
}

class StickerPickerBottomSheetState extends State<StickerPickerBottomSheet> with AfterLayoutMixin<StickerPickerBottomSheet> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void afterFirstLayout(BuildContext context) {
    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: context.width(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Sticker', style: boldTextStyle()),
            16.height,
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: getStickers().map(
                (e) {
                  return Image.asset(e, width: 100, height: 100).onTap(() {
                    finish(context, e);
                  });
                },
              ).toList(),
            ).center(),
          ],
        ),
      ),
    );
  }
}
