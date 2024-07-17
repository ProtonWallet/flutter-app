import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/core/coordinator.dart';

// TODO(improve): user other exsiting reused alert dialog
void showPermissionErrorDialog(
  String errorMessage,
) {
  final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Early access"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  width: 300,
                  child: Text(
                    "You don't have permssion to access Proton Wallet",
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: SizedBox(
                height: 50,
                child: ButtonV5(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemNavigator.pop();
                  },
                  text: 'Close',
                  backgroundColor: Colors.red,
                  width: 300,
                  height: 44,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
