import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/underline.dart';
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
  final VoidCallback? onTap;
  final bool? canClose;

  const AlertCustom({
    required this.content,
    super.key,
    this.width,
    this.learnMore,
    this.leadingWidget,
    this.border,
    this.backgroundColor,
    this.color,
    this.margin,
    this.onTap,
    this.canClose,
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
        : GestureDetector(
            onTap: widget.onTap,
            child: Container(
                width: widget.width ?? MediaQuery.of(context).size.width,
                margin: widget.margin,
                decoration: BoxDecoration(
                    color: widget.backgroundColor ??
                        ProtonColors.alertWaningBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    border: widget.border ??
                        Border.all(
                          color: ProtonColors.alertWaning,
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
                                    color: widget.color ??
                                        ProtonColors.alertWaning),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  widget.onTap != null
                                      ? Underline(
                                          color: widget.color ??
                                              ProtonColors.alertWaning,
                                          child: Text(widget.content,
                                              style: FontManager.body2Regular(
                                                  widget.color ??
                                                      ProtonColors
                                                          .alertWaning)))
                                      : Text(widget.content,
                                          style: FontManager.body2Regular(
                                              widget.color ??
                                                  ProtonColors.alertWaning)),
                                  if (widget.learnMore != null)
                                    Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: widget.learnMore!),
                                ])),
                            if (widget.canClose ?? true)
                              Transform.translate(
                                offset: const Offset(8, 0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isClose = true;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: ProtonColors.textNorm,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        )),
                  ],
                )));
  }
}
