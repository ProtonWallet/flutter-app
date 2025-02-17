import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/scenes/components/underline.dart';

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
                width: widget.width ?? context.width,
                margin: widget.margin,
                decoration: BoxDecoration(
                    color: widget.backgroundColor ??
                        ProtonColors.notificationWaningBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    border: widget.border ??
                        Border.all(color: ProtonColors.notificationWaning)),
                child: Stack(children: [
                  Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                        right: 20,
                        left: 20,
                      ),
                      child: Row(children: [
                        if (widget.leadingWidget != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                            ),
                            child: widget.leadingWidget!,
                          ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.onTap != null
                                ? Underline(
                                    color: widget.color ??
                                        ProtonColors.notificationWaning,
                                    child: Text(widget.content,
                                        style: ProtonStyles.body2Regular(
                                            color: widget.color ??
                                                ProtonColors.notificationWaning)))
                                : Text(widget.content,
                                    style: ProtonStyles.body2Regular(
                                        color: widget.color ??
                                            ProtonColors.notificationWaning)),
                            if (widget.learnMore != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: widget.learnMore!),
                          ],
                        )),
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
                      ])),
                ])));
  }
}
