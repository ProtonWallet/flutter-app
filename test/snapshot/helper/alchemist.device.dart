// Copied and adapted from https://github.com/eBay/flutter_glove_box/blob/master/packages/golden_toolkit/lib/src/device.dart

import 'package:flutter/material.dart';

/// This [Device] is a configuration for golden test.
class Device {
  /// This [Device] is a configuration for golden test.
  const Device({
    required this.size,
    required this.name,
    this.devicePixelRatio = 1.0,
    this.textScaleFactor = 1.0,
    this.brightness = Brightness.light,
    this.safeArea = EdgeInsets.zero,
  });

  /// [phoneLandscape] example of phone that in landscape mode
  static const Device phoneLandscape =
      Device(name: 'phone_landscape', size: Size(667, 375));

  /// [phonePortrait] example of phone that in portrait mode
  static const Device phonePortrait =
      Device(name: 'phone_portrait', size: Size(375, 667));

  /// [tabletLandscape] example of tablet that in landscape mode
  static const Device tabletLandscape =
      Device(name: 'tablet_landscape', size: Size(1366, 1024));

  /// [tabletPortrait] example of tablet that in portrait mode
  static const Device tabletPortrait =
      Device(name: 'tablet_portrait', size: Size(1024, 1366));

  static List<Device> all = [
    phonePortrait,
    phonePortrait.dark(),
    phoneLandscape,
    phoneLandscape.dark(),
    tabletPortrait,
    tabletPortrait.dark(),
    tabletLandscape,
    tabletLandscape.dark(),
  ];

  /// [name] specify device name. Ex: Phone, Tablet, Watch
  final String name;

  /// [size] specify device screen size. Ex: Size(1366, 1024))
  final Size size;

  /// [devicePixelRatio] specify device Pixel Ratio
  final double devicePixelRatio;

  /// [textScaleFactor] specify custom text scale factor
  final double textScaleFactor;

  /// [brightness] specify platform brightness
  final Brightness brightness;

  /// [safeArea] specify insets to define a safe area
  final EdgeInsets safeArea;

  /// [copyWith] convenience function for [Device] modification
  Device copyWith({
    Size? size,
    double? devicePixelRatio,
    String? name,
    double? textScale,
    Brightness? brightness,
    EdgeInsets? safeArea,
  }) {
    return Device(
      size: size ?? this.size,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      name: name ?? this.name,
      textScaleFactor: textScale ?? textScaleFactor,
      brightness: brightness ?? this.brightness,
      safeArea: safeArea ?? this.safeArea,
    );
  }

  /// [dark] convenience method to copy the current device and apply dark theme
  Device dark() {
    return Device(
      size: size,
      devicePixelRatio: devicePixelRatio,
      textScaleFactor: textScaleFactor,
      brightness: Brightness.dark,
      safeArea: safeArea,
      name: '${name}_dark',
    );
  }

  @override
  String toString() {
    return 'Device: $name, '
        '${size.width}x${size.height} @ $devicePixelRatio, '
        'text: $textScaleFactor, $brightness, safe: $safeArea';
  }
}
