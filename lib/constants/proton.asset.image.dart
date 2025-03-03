import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';

@immutable
class ProtonAssetImage extends ThemeExtension<ProtonAssetImage> {
  final SvgGenImage test;

  const ProtonAssetImage({required this.test});

  @override
  ProtonAssetImage copyWith({SvgGenImage? test}) {
    return ProtonAssetImage(test: test ?? this.test);
  }

  @override
  ProtonAssetImage lerp(ThemeExtension<ProtonAssetImage>? other, double t) {
    if (other is! ProtonAssetImage) {
      return this;
    }
    return ProtonAssetImage(test: other.test);
  }
}
