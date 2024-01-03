import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet/helper/logger.dart';

class LocalToast {
  static final LocalAuthentication auth = LocalAuthentication();
  static final FToast fToast = FToast();

  static showToast(BuildContext context, String message,
      {int duration = 1,
      Icon icon = const Icon(Icons.check),
      bool isWarning = false}) {
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: isWarning == false
            ? Border.all(
                color: Colors.black,
                width: 1.0,
              )
            : const Border(),
        color: isWarning
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(
              color: isWarning
                  ? Colors.white
                  : Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: duration),
    );

    // // Custom Toast Position
    // fToast.showToast(
    //     child: toast,
    //     toastDuration: Duration(seconds: 2),
    //     positionedToastBuilder: (context, child) {
    //       return Positioned(
    //         child: child,
    //         top: 16.0,
    //         left: 16.0,
    //       );
    //     });
  }
}
