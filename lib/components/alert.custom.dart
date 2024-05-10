import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class AlertCustom extends StatefulWidget {
  final String content;
  final double? width;
  final Widget? learnMore;
  final Widget? leadingWidget;
  final Border? border;
  final Color? backgroundColor;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const AlertCustom({
    super.key,
    required this.content,
    this.width,
    this.learnMore,
    this.leadingWidget,
    this.border,
    this.backgroundColor,
    this.color,
    this.margin,
  });

  @override
  AlertCustomState createState() => AlertCustomState();
}

class AlertCustomState extends State<AlertCustom> {
  bool isClose = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isClose
        ? const SizedBox()
        : Container(
            width: widget.width ?? MediaQuery.of(context).size.width,
            margin: widget.margin,
            decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    ProtonColors.alertWaningBackground,
                borderRadius: BorderRadius.circular(10.0),
                border: widget.border ??
                    Border.all(
                      color: ProtonColors.alertWaning,
                      width: 1.0,
                    )),
            child: Stack(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 16, right: 20, left: 20),
                    child: Row(
                      children: [
                        widget.leadingWidget ??
                            Icon(Icons.warning,
                                color:
                                    widget.color ?? ProtonColors.alertWaning),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(widget.content,
                                  style: FontManager.body2Regular(
                                      widget.color ??
                                          ProtonColors.alertWaning)),
                              if (widget.learnMore != null)
                                Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: widget.learnMore!),
                            ])),
                      ],
                    )),
                Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isClose = true;
                          });
                        },
                        child: Icon(Icons.close_rounded,
                            size: 16, color: ProtonColors.textHint)))
              ],
            ));
  }
}
