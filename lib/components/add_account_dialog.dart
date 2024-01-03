import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/script_type.dart';
import '../helper/wallet_manager.dart';

class AddAccountAlertDialog extends StatefulWidget {
  int walletID;
  String label = '';
  String derivationPath = '';
  ScriptType scriptType = ScriptType.Legacy;

  AddAccountAlertDialog({required this.walletID});

  @override
  _AddAccountAlertDialogState createState() => _AddAccountAlertDialogState();

  static void show(BuildContext context, int walletID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAccountAlertDialog(walletID: walletID);
      },
    );
  }
}

class _AddAccountAlertDialogState extends State<AddAccountAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Account'),
      content: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton<ScriptType>(
          value: widget.scriptType,
          onChanged: (ScriptType? newValue) {
            setState(() {
              widget.scriptType = newValue!;
            });
          },
          items: <ScriptType>[
            ScriptType.Legacy,
            ScriptType.NestedSegWit,
            ScriptType.NativeSegWit,
            ScriptType.Taproot
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
              widget.derivationPath = value;
            });
          },
          decoration: const InputDecoration(
              labelText: 'Derivation Path',
              hintText: "m/purpose'/coin'/account'/0"),
        ),
        TextField(
          onChanged: (value) {
            setState(() {
              widget.label = value;
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
            WalletManager.importAccount(widget.walletID, widget.label, widget.scriptType.index, widget.derivationPath);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
