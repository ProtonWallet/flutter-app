import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/custom.loading.dart';

typedef FutureCallback = Future<void> Function();

class ButtonV6 extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;
  final FutureCallback? onPressed;
  final bool enable;
  final bool? isLoading;
  final Size? maximumSize;
  final Alignment alignment;

  const ButtonV6({
    required this.text,
    required this.width,
    required this.height,
    super.key,
    this.onPressed,
    this.radius = 40.0,
    this.backgroundColor = const Color(0xFF6D4AFF),
    this.borderColor = Colors.transparent,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    ),
    this.enable = true,
    this.isLoading,
    this.maximumSize = Size.infinite,
    this.alignment = Alignment.center,
  });

  @override
  ButtonV6State createState() => ButtonV6State();
}

class ButtonV6State extends State<ButtonV6>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool enable = true;

  @override
  void initState() {
    super.initState();
    isLoading = widget.isLoading ?? false;
    enable = widget.enable;
  }

  @override
  void didUpdateWidget(ButtonV6 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enable != widget.enable) {
      setState(() {
        isLoading = widget.isLoading ?? false;
        enable = widget.enable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: widget.alignment,
        child: Stack(alignment: Alignment.center, children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              maximumSize: widget.maximumSize,
              fixedSize: Size(widget.width, widget.height),
              backgroundColor: widget.backgroundColor,
              // foreground
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                side: BorderSide(color: widget.borderColor),
              ),
              elevation: 0.0,
            ),
            onPressed: widget.enable
                ? () async {
                    setState(() {
                      isLoading = true;
                      enable = false;
                    });
                    await widget.onPressed?.call();
                    setState(() {
                      isLoading = false;
                      enable = widget.enable;
                    });
                  }
                : () {},
            child: Text(
              widget.text,
              style: widget.textStyle,
            ),
          ),
          if (isLoading)
            Positioned(
                right: 20,
                top: widget.height / 2 - 10,
                child: CustomLoading(
                  color: ProtonColors.textInverted,
                  durationInMilliSeconds: 1400,
                  size: 20,
                )),
          if (!enable)
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(widget.radius),
              ),
            ),
        ]));
  }
}
