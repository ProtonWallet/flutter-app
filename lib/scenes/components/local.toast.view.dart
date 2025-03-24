import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

enum ToastType {
  success,
  warning,
  error,
  norm,
}

extension ToastTypeExtension on ToastType {
  Color get color {
    switch (this) {
      case ToastType.success:
        return ProtonColors.notificationNorm;
      case ToastType.warning:
        return ProtonColors.notificationWaning;
      case ToastType.error:
        return ProtonColors.notificationError;
      case ToastType.norm:
      default:
        return ProtonColors.textNorm;
    }
  }
}

class ToastView extends StatelessWidget {
  const ToastView({
    required this.toastType,
    required this.message,
    this.icon,
    this.textStyle,
    super.key,
  });

  final ToastType toastType;
  final Icon? icon;
  final String message;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: toastType.color,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 12.0),
        ],
        Flexible(
          child: Text(
            message,
            style: textStyle ??
                ProtonStyles.body2Medium(
                  color: ProtonColors.textInverted,
                ),
          ),
        ),
      ]),
    );
    return toast;
  }
}
