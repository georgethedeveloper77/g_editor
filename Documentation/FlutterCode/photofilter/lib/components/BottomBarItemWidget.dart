import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BottomBarItemWidget extends StatelessWidget {
  final Color? color;
  final Function? onTap;
  final String? title;
  final IconData? icons;

  BottomBarItemWidget({this.color, this.onTap, this.title, this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width() / 6,
      height: 60,
      decoration: BoxDecoration(border: Border.all(color: viewLineColor), color: color),
      alignment: Alignment.center,
      child: Material(
        color: Colors.white24,
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icons, color: Colors.black),
              4.height,
              Text(title.validate(), style: boldTextStyle(color: Colors.black, size: 13)).fit(),
            ],
          ),
        ),
      ),
    );
  }
}
