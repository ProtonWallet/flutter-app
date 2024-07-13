import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? logo;
  final bool hidden;

  const SettingsItem({
    required this.title, required this.onTap, super.key,
    this.subtitle,
    this.logo,
    this.hidden = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: logo ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: Color(0xFF848993),
          ),
      onTap: onTap,
    );
  }
}
