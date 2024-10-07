import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class CustomSliderV1 extends StatefulWidget {
  final double value;

  const CustomSliderV1({
    required this.value,
    super.key,
  });

  @override
  CustomSliderV1State createState() => CustomSliderV1State();
}

class CustomSliderV1State extends State<CustomSliderV1> {
  bool isDisposed = false;
  double value = 0.0;
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
        trackHeight: 8.0,
      ),
      child: Slider(
        value: value,
        max: 50,
        min: 10,
        activeColor: ProtonColors.interactionNormMinor1,
        inactiveColor: ProtonColors.textDisabled,
        thumbColor: ProtonColors.white,
        label: value.toStringAsFixed(2),
        onChanged: (double value) {
          setState(() {
            this.value = value;
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
      ..color = ProtonColors.white
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = ProtonColors.textDisabled
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw the border
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawCircle(center, radius - 1, paint); // Adjust radius for inner circle
  }
}