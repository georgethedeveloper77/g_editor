import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/models/ColorFilterModel.dart';
import 'package:photo_editor_pro/utils/DataProvider.dart';

class FilterSelectionWidget extends StatefulWidget {
  static String tag = '/FilterSelectionWidget';
  final Function(ColorFilterModel)? onSelect;
  final File? image;

  FilterSelectionWidget({this.onSelect, this.image});

  @override
  FilterSelectionWidgetState createState() => FilterSelectionWidgetState();
}

class FilterSelectionWidgetState extends State<FilterSelectionWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: getFilters().map((e) {
        return Container(
          height: 60,
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: radius()),
          margin: EdgeInsets.all(2),
          child: Stack(
            // alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Image.file(widget.image!, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
              if (e.color != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: radius(),
                    gradient: LinearGradient(colors: e.color!),
                  ),
                ),
              if (e.matrix != null)
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(e.matrix!),
                  child: Image.file(widget.image!, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
                ),
              Align(alignment: Alignment.bottomCenter,
                child: Text(
                  e.name.validate(),
                  style: primaryTextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ).onTap(() {
          widget.onSelect?.call(e);
        });
      }).toList(),
    );
  }
}
