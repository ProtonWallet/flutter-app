import 'package:flutter/material.dart';
import 'package:wallet/scenes/components/button.v5.dart';

Future<void> showDisableDialog(
  BuildContext context,
  VoidCallback onDisable,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Disable recovery phrase?'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(
                width: 300,
                child: Text(
                  "This will disable your current recovery phrase. You won't be able to use it to access your account or decrypt your data.",
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 300,
                child: Text(
                  "Enabling recovery by phrase again will generate a new recovery phrase.",
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          Column(
            children: [
              SizedBox(
                height: 50,
                child: ButtonV5(
                  onPressed: () {
                    onDisable();
                    Navigator.of(context).pop();
                  },
                  text: 'Disable recovery phrase',
                  backgroundColor: Colors.red,
                  width: 300,
                  height: 44,
                ),
              ),
              SizedBox(
                height: 50,
                child: ButtonV5(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: 'Cancel',
                  width: 300,
                  height: 44,
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
