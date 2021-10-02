import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/utils/DataProvider.dart';

import '../main.dart';

class EmojiPickerBottomSheet extends StatefulWidget {
  static String tag = '/EmojiPickerBottomSheet';

  @override
  EmojiPickerBottomSheetState createState() => EmojiPickerBottomSheetState();
}

class EmojiPickerBottomSheetState extends State<EmojiPickerBottomSheet> with AfterLayoutMixin<EmojiPickerBottomSheet> {
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
            Text('Select Emoji', style: boldTextStyle()),
            16.height,
            Wrap(
              children: getSmileys().map(
                (e) {
                  return Container(child: Text(e, style: TextStyle(fontSize: 35))).onTap(() {
                    finish(context, e);
                  });
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
