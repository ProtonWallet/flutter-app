import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/local.toast.view.dart';

class LocalToast {
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
    TextStyle? textStyle,
  }) {
    fToast.init(context);
    final toast = ToastView(
      toastType: toastType,
      icon: icon,
      message: message,
      textStyle: textStyle,
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: duration),
    );
  }
}
