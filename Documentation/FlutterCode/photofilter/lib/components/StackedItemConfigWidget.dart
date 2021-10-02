import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/models/FontData.dart';
import 'package:photo_editor_pro/models/StackedWidgetModel.dart';
import 'package:photo_editor_pro/utils/Colors.dart';
import 'package:photo_editor_pro/utils/Constants.dart';
import 'package:photo_editor_pro/utils/DataProvider.dart';

import 'ColorSelectorBottomSheet.dart';

// ignore: must_be_immutable
class StackedItemConfigWidget extends StatefulWidget {
  StackedWidgetModel? stackedWidgetModel;
  final VoidCallback? voidCallback;

  StackedItemConfigWidget({this.stackedWidgetModel, this.voidCallback});

  @override
  StackedItemConfigWidgetState createState() => StackedItemConfigWidgetState();
}

class StackedItemConfigWidgetState extends State<StackedItemConfigWidget> {
  List<FontData> fontList = getFontFamilies();
  FontData? selectedFontFamily;

  @override
  void initState() {
    super.initState();
    selectedFontFamily = fontList.first;

    log(selectedFontFamily);
  }

  @override
  Widget build(BuildContext context) {
    bool isTextTypeWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeNeon || widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeText;
    bool isTextWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeText;
    bool isNeonWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeNeon;
    bool isEmojiWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeEmoji;
    bool isStickerWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeSticker;

    return Container(
      padding: EdgeInsets.all(16),
      height: context.height() * 0.5,
      decoration: BoxDecoration(color: Colors.white, borderRadius: radiusOnly(topLeft: 16, topRight: 16)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Size ${widget.stackedWidgetModel!.size!.toInt()}', style: boldTextStyle()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Text('Normal', style: boldTextStyle()).onTap(() {
                      widget.stackedWidgetModel!.fontStyle = FontStyle.normal;
                      widget.voidCallback!.call();

                      setState(() {});
                    }),
                    Text('Italic', style: boldTextStyle(fontStyle: FontStyle.italic)).onTap(() {
                      widget.stackedWidgetModel!.fontStyle = FontStyle.italic;
                      widget.voidCallback!.call();

                      setState(() {});
                    }),
                  ],
                ),
              ],
            ).visible(isTextTypeWidget),
            8.height,
            if (selectedFontFamily != null && isTextWidget)
              Row(
                children: [
                  Text('Font Family', style: primaryTextStyle()),
                  8.width,
                  DropdownButton(
                    value: selectedFontFamily,
                    items: fontList.map((e) {
                      return DropdownMenuItem(child: Text(e.fontName!, style: primaryTextStyle(fontFamily: GoogleFonts.getFont(e.fontName!).fontFamily)), value: e);
                    }).toList(),
                    underline: SizedBox(),
                    onChanged: (FontData? s) {
                      selectedFontFamily = s;

                      widget.stackedWidgetModel!.fontFamily = s!.fontFamily;
                      widget.voidCallback!.call();

                      setState(() {});
                    },
                  ).expand(),
                ],
              ),
            8.height,
            Slider(
              value: widget.stackedWidgetModel!.size.validate(value: 16),
              min: 10.0,
              max: isStickerWidget ? 300.0 : 100.0,
              onChangeEnd: (v) {
                widget.stackedWidgetModel!.size = v;
                widget.voidCallback!.call();

                setState(() {});
              },
              onChanged: (v) {
                widget.stackedWidgetModel!.size = v;
                widget.voidCallback!.call();

                setState(() {});
              },
            ),
            16.height.visible(isTextTypeWidget),
            Text('Background Color', style: boldTextStyle()).visible(isTextTypeWidget),
            8.height.visible(isTextTypeWidget),
            ColorSelectorBottomSheet(
              list: backgroundColors,
              selectedColor: widget.stackedWidgetModel!.backgroundColor,
              onColorSelected: (c) {
                widget.stackedWidgetModel!.backgroundColor = c;
                widget.voidCallback!.call();

                setState(() {});
              },
            ).visible(isTextTypeWidget),
            16.height.visible(isTextTypeWidget),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Text Color', style: boldTextStyle()),
                8.height,
                ColorSelectorBottomSheet(
                  list: textColors,
                  selectedColor: widget.stackedWidgetModel!.textColor,
                  onColorSelected: (c) {
                    widget.stackedWidgetModel!.textColor = c;
                    widget.voidCallback!.call();

                    setState(() {});
                  },
                ),
              ],
            ).visible(isTextTypeWidget),
            16.height,
            AppButton(
              text: 'Remove',
              padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8 ),
              onTap: () {
                finish(context, widget.stackedWidgetModel);
              },
            ),
          ],
        ),
      ),
    );
  }
}
