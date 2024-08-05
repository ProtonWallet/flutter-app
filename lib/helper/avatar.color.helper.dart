import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class AvatarColor {
  final Color backgroundColor;
  final Color textColor;

  const AvatarColor(this.textColor, this.backgroundColor);
}

class AvatarColorHelper {
  static List<AvatarColor> colors = [
    AvatarColor(
      ProtonColors.yellow1Text,
      ProtonColors.yellow1Background,
    ),
    AvatarColor(
      ProtonColors.pink1Text,
      ProtonColors.pink1Background,
    ),
    AvatarColor(
      ProtonColors.blue1Text,
      ProtonColors.blue1Background,
    ),
    AvatarColor(
      ProtonColors.green1Text,
      ProtonColors.green1Background,
    ),
  ];

  static List<AvatarColor> avatarColors = [
    AvatarColor(
      ProtonColors.avatarOrange1Text,
      ProtonColors.avatarOrange1Background,
    ),
    AvatarColor(
      ProtonColors.avatarPink1Text,
      ProtonColors.avatarPink1Background,
    ),
    AvatarColor(
      ProtonColors.avatarPurple1Text,
      ProtonColors.avatarPurple1Background,
    ),
    AvatarColor(
      ProtonColors.avatarBlue1Text,
      ProtonColors.avatarBlue1Background,
    ),
    AvatarColor(
      ProtonColors.avatarGreen1Text,
      ProtonColors.avatarGreen1Background,
    ),
  ];

  static Color getAvatarBackgroundColor(int index) {
    return avatarColors[index % max(avatarColors.length, 1)].backgroundColor;
  }

  static Color getAvatarTextColor(int index) {
    return avatarColors[index % max(avatarColors.length, 1)].textColor;
  }

  static Color getBackgroundColor(int index) {
    return colors[index % max(colors.length, 1)].backgroundColor;
  }

  static Color getTextColor(int index) {
    return colors[index % max(colors.length, 1)].textColor;
  }

  static int getIndexFromString(String string) {
    int sum = 0;
    for (var i = 0; i < string.length; i++) {
      sum += string.codeUnitAt(i);
    }

    return sum % (max(colors.length, 1));
  }
}
