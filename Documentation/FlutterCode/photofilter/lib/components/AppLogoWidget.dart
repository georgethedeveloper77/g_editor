import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/utils/Colors.dart';

class AppLogoWidget extends StatelessWidget {
  static String tag = '/AppLogoWidget';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 40),
      width: context.width(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/humans.png',
            height: 170,
          ),
          16.width,
          Column(
            children: [
              Text('Let\'s make your', style: boldTextStyle(size: 30)),
              Text('Photo Better!', style: boldTextStyle(size: 30)).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
            ],
          )
        ],
      ).center(),
    );
  }
}
