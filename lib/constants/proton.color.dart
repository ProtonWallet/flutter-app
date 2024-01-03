import 'package:flutter/material.dart';

class ProtonColors {
  static const Color interactionNorm = Color(0xFF6D4AFF);
  static const Color white = Colors.white;
  static const Color clear = Colors.transparent;
  // static const Color textNorm1 = Color.fromARGB(255, 18, 18, 170);
  static const Color textNorm = Color(0xFF0C0C14);
  static const Color textWeak = Color(0xFFB3A3F5);
  static const Color textHint = Color(0xFF999693);
  static const Color wMajor1 = Color(0xFFDEDBD9);
  static const Color nMajor1 = Color(0xFF6243E6);
  static const Color backgroundSecondary = Color(0xFFF5F4F2);
  static const Color alertWaning = Color(0xFFF78400);
  static const Color alertWaningBackground = Color.fromARGB(26, 255, 153, 0);
  static const Color signalSuccess = Color(0xFF1EA885);


  static const Color surfaceLight = Color.fromARGB(255, 245, 244, 242);

  static Color calculateInverseColor(Color color) {
    Color inverseColor = Color.fromARGB(
      255,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
    return inverseColor;
  }
}
