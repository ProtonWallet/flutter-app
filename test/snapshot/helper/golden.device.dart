import 'package:flutter/widgets.dart';
import 'package:golden_toolkit/golden_toolkit.dart' as toolkit;

class Devices {
  /// Other device definitions...

  // iPhone 13 normal variant
  static toolkit.Device get iphone13 => const toolkit.Device(
        size: Size(390.0, 844.0), // Placeholder dimensions
        name: 'iphone_13__text_scale_1_0',
        safeArea: EdgeInsets.only(top: 44.0, bottom: 34.0),
      );
  static toolkit.Device iphone13WithTextScale(double textScale) =>
      iphone13.copyWith(
        name: 'iphone_13__text_scale_${textScale.title()}',
        textScale: textScale,
      );

  // iPhone 13 Pro variant
  static toolkit.Device get iphone13Pro => const toolkit.Device(
        size: Size(390.0, 844.0), // Placeholder dimensions
        name: 'iphone_13_pro__text_scale_1_0',
        safeArea: EdgeInsets.only(top: 44.0, bottom: 34.0),
      );
  static toolkit.Device iphone13ProWithTextScale(double textScale) =>
      iphone13Pro.copyWith(
        name: 'iphone_13_pro__text_scale_${textScale.title()}',
        textScale: textScale,
      );

  // iPhone 14 Plus variant
  static toolkit.Device get iphone14Plus => const toolkit.Device(
        size: Size(428.0, 926.0), // Placeholder dimensions
        name: 'iphone_14_plus__text_scale_1_0',
        safeArea: EdgeInsets.only(top: 47.0, bottom: 34.0),
      );
  static toolkit.Device iphone14PlusWithTextScale(double textScale) =>
      iphone14Plus.copyWith(
        name: 'iphone_14_plus__text_scale_${textScale.title()}',
        textScale: textScale,
      );

  /// Further device implementations as needed...
}

final devicesWithDifferentTextScales = [
  // Other devices...
  Devices.iphone13,
  Devices.iphone13Pro,
  Devices.iphone14Plus,
  Devices.iphone13WithTextScale(1.3),
  Devices.iphone13ProWithTextScale(1.3),
  Devices.iphone14PlusWithTextScale(1.3),
  Devices.iphone13WithTextScale(1.6),
  Devices.iphone13ProWithTextScale(1.6),
  Devices.iphone14PlusWithTextScale(1.6),
];

extension DoubleExtensions on double {
  String title() {
    return toString().replaceFirst('.', '_');
  }
}
