import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
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

class LocalToast {
  static final LocalAuthentication auth = LocalAuthentication();
  static final FToast fToast = FToast();

  static void showErrorToast(BuildContext context, String message) {
    showToast(
      context,
      message,
      icon: Icon(
        Icons.warning,
        color: ProtonColors.textInverted,
      ),
      toastType: ToastType.error,
      duration: 2,
    );
  }

  static void showToast(
    BuildContext context,
    String message, {
    int duration = 1,
    ToastType toastType = ToastType.norm,
    Icon? icon,
  }) {
    fToast.init(context);
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: toastType.color,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) icon,
        if (icon != null)
          const SizedBox(
            width: 12.0,
          ),
        Text(
          message,
          style: ProtonStyles.body2Medium(
            color: ProtonColors.textInverted,
          ),
        ),
      ]),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: duration),
    );
  }
}
