import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class CustomSliderV1 extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final TextEditingController controller;

  const CustomSliderV1({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.controller,
    super.key,
  });

  @override
  CustomSliderV1State createState() => CustomSliderV1State();
}

class CustomSliderV1State extends State<CustomSliderV1> {
  bool isDisposed = false;
  int value = 0;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        showValueIndicator: ShowValueIndicator.always,
        thumbShape: CustomSliderV1ThumbShape(),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        trackHeight: 8.0,
      ),
      child: Slider(
        value: value.toDouble(),
        max: widget.maxValue.toDouble(),
        min: widget.minValue.toDouble(),
        activeColor: ProtonColors.sliderActiveColor,
        inactiveColor: ProtonColors.sliderInactiveColor,
        thumbColor: ProtonColors.backgroundSecondary,
        label: value.toString(),
        onChanged: (double value) {
          setState(() {
            this.value = value.toInt();
            widget.controller.text = this.value.toString();
          });
        },
      ),
    );
  }
}

class CustomSliderV1ThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(32, 32);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    const double radius = 16.0;
    final Paint paint = Paint()
      ..color = ProtonColors.backgroundSecondary
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = ProtonColors.sliderInactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw the border
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawCircle(
        center, radius - 1, paint); // Adjust radius for inner circle
  }
}
