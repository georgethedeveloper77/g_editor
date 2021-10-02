import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/models/StackedWidgetModel.dart';
import 'package:photo_editor_pro/utils/Constants.dart';

import 'PositionedNeonTextWidget.dart';
import 'PositionedTextViewWidget.dart';
import 'StackedItemConfigWidget.dart';

class StackedWidgetComponent extends StatefulWidget {
  static String tag = '/StackedWidgetComponent';
  final List<StackedWidgetModel> multiWidget;

  StackedWidgetComponent(this.multiWidget);

  @override
  StackedWidgetComponentState createState() => StackedWidgetComponentState();
}

class StackedWidgetComponentState extends State<StackedWidgetComponent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: widget.multiWidget.map((item) {
        if (item.widgetType == WidgetTypeText) {
          return PositionedTextViewWidget(
            value: item.value.validate(),
            left: item.offset!.dx,
            top: item.offset!.dy,
            align: TextAlign.center,
            fontSize: item.size,
            stackedWidgetModel: item,
            onTap: () async {
              var data = await showModalBottomSheet(
                context: context,
                builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                backgroundColor: Colors.transparent,
              );

              if (data != null) {
                widget.multiWidget.remove(data);
              }
              setState(() {});
            },
            onPanUpdate: (details) {
              item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);

              setState(() {});
            },
          );
        } else if (item.widgetType == WidgetTypeEmoji) {
          return PositionedTextViewWidget(
            value: item.value.validate(),
            left: item.offset!.dx,
            top: item.offset!.dy,
            align: TextAlign.center,
            fontSize: item.size,
            stackedWidgetModel: item,
            onTap: () async {
              var data = await showModalBottomSheet(
                context: context,
                builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                backgroundColor: Colors.transparent,
              );

              if (data != null) {
                widget.multiWidget.remove(data);
              }
              setState(() {});
            },
            onPanUpdate: (details) {
              item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);

              setState(() {});
            },
          );
        } else if (item.widgetType == WidgetTypeNeon) {
          return PositionedNeonTextWidget(
            value: item.value.validate(),
            left: item.offset!.dx,
            top: item.offset!.dy,
            align: TextAlign.center,
            fontSize: item.size,
            stackedWidgetModel: item,
            onTap: () async {
              var data = await showModalBottomSheet(
                context: context,
                builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                backgroundColor: Colors.transparent,
              );

              if (data != null) {
                widget.multiWidget.remove(data);
              }
              setState(() {});
            },
            onPanUpdate: (details) {
              item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);

              setState(() {});
            },
          );
        } else if (item.widgetType == WidgetTypeSticker) {
          return Positioned(
            left: item.offset!.dx,
            top: item.offset!.dy,
            child: GestureDetector(
              onTap: () async {
                var data = await showModalBottomSheet(
                  context: context,
                  builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                  backgroundColor: Colors.transparent,
                );

                if (data != null) {
                  widget.multiWidget.remove(data);
                }
                setState(() {});
              },
              onPanUpdate: (details) {
                item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);

                setState(() {});
              },
              child: Image.asset(item.value!, height: item.size),
            ),
          );
        }
        return Container();
      }).toList(),
    );
  }
}
