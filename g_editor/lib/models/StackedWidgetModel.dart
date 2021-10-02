import 'package:flutter/material.dart';

class StackedWidgetModel {
  String? widgetType;
  String? value;
  Offset? offset;
  double? size;
  FontStyle? fontStyle;

  // Text Widget Properties
  Color? textColor;
  Color? backgroundColor;
  String? fontFamily;

  StackedWidgetModel({
    this.widgetType,
    this.value,
    this.offset,
    this.size,
    this.textColor,
    this.backgroundColor,
    this.fontStyle,
    this.fontFamily,
  });
}
