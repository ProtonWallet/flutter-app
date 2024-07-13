import 'package:flutter/material.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/core/coordinator.dart';

void showLogoutErrorDialog(
  String errorMessage,
  VoidCallback onLogout,
) {
  final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session expired!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  width: 300,
                  child: Text(
                    "Your session has expired. Please log in again.",
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
                    onLogout();
                  },
                  text: 'Logout',
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
