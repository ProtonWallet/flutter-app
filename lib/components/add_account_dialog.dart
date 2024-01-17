import 'package:flutter/material.dart';

import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/wallet_manager.dart';

class AddAccountAlertDialog extends StatefulWidget {
  final int walletID;

  const AddAccountAlertDialog({super.key, required this.walletID});

  @override
  AddAccountAlertDialogState createState() => AddAccountAlertDialogState();

  static void show(BuildContext context, int walletID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAccountAlertDialog(walletID: walletID);
      },
    );
  }
}

class AddAccountAlertDialogState extends State<AddAccountAlertDialog> {
  ScriptType scriptType = ScriptType.legacy;
  String derivationPath = '';
  String label = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Account'),
      content: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton<ScriptType>(
          value: scriptType,
          onChanged: (ScriptType? newValue) {
            setState(() {
              scriptType = newValue!;
            });
          },
          items: <ScriptType>[
            ScriptType.legacy,
            ScriptType.nestedSegWit,
            ScriptType.nativeSegWit,
            ScriptType.taproot
          ].map((ScriptType scriptType) {
            return DropdownMenuItem<ScriptType>(
              value: scriptType,
              child: Text("${scriptType.name} (${scriptType.desc})"),
            );
          }).toList(),
        ),
        TextField(
          onChanged: (value) {
            setState(() {
              derivationPath = value;
            });
          },
          decoration: const InputDecoration(
              labelText: 'Derivation Path',
              hintText: "m/purpose'/coin'/account'/0"),
        ),
        TextField(
          onChanged: (value) {
            setState(() {
              label = value;
            });
          },
          decoration: const InputDecoration(
              labelText: 'Label', hintText: "label for this account"),
        ),
      ]),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            WalletManager.importAccount(
                widget.walletID, label, scriptType.index, derivationPath);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
