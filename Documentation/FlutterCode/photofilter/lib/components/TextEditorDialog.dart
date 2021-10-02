import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class TextEditorDialog extends StatelessWidget {
  static String tag = '/AddTextDialog';
  final TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: name,
            textFieldType: TextFieldType.NAME,
            decoration: InputDecoration(
              labelText: 'Text',
              labelStyle: primaryTextStyle(),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
            ),
            autoFocus: true,
          ),
          16.height,
          AppButton(
            text: 'Done',
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            onTap: () {
              if (name.text.trim().isNotEmpty) {
                finish(context, name.text);
              } else {
                toast('Write something');
              }
            },
          ),
        ],
      ),
    );
  }
}
