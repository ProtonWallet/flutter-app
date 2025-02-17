import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? logo;
  final bool hidden;
  final Color? color;

  const SettingsItem(
      {required this.title,
      required this.onTap,
      super.key,
      this.subtitle,
      this.logo,
      this.hidden = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: ProtonStyles.body1Medium(color: color ?? ProtonColors.textNorm),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: logo ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: ProtonColors.textHint,
          ),
      onTap: onTap,
    );
  }
}
