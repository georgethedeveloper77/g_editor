import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/utils/Colors.dart';

class HomeItemWidget extends StatelessWidget {
  static String tag = '/HomeItemWidget';
  final Function? onTap;
  final Widget? widget;

  HomeItemWidget({this.onTap, this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width() / 2 - 50,
      height: 150,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: radius(30),
        gradient: LinearGradient(colors: [
          itemGradient1,
          itemGradient2,
        ], end: Alignment.topCenter, begin: Alignment.bottomCenter),
      ),
      child: Material(
        color: Colors.white24,
        child: InkWell(
          onTap: onTap as void Function()?,
          child: widget.paddingAll(16),
          borderRadius: radius(30),
        ),
      ),
    );
  }
}
