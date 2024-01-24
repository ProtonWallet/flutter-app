import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/wallet_manager.dart';

import '../network/api.helper.dart';

class AddAccountAlertDialog extends StatefulWidget {
  final int walletID;
  final String serverWalletID;
  final VoidCallback? callback;

  const AddAccountAlertDialog(
      {super.key,
      required this.walletID,
      required this.serverWalletID,
      this.callback});

  @override
  AddAccountAlertDialogState createState() => AddAccountAlertDialogState();

  static void show(BuildContext context, int walletID, String serverWalletID,
      {VoidCallback? callback}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAccountAlertDialog(
            walletID: walletID,
            serverWalletID: serverWalletID,
            callback: callback);
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
          onPressed: () async {
            String serverAccountID =
                await APIHelper.createAccount(widget.serverWalletID, {
              "DerivationPath": derivationPath,
              "Label":
                  base64Encode(utf8.encode(await WalletManager.encrypt(label))),
              "ScriptType": scriptType.index,
            });
            if (serverAccountID != "") {
              WalletManager.importAccount(widget.walletID, label,
                  scriptType.index, "$derivationPath/0", serverAccountID);
              if (context.mounted) {
                LocalToast.showToast(context, "Account created!");
              }
            } else {
              if (context.mounted) {
                LocalToast.showToast(context, "Account created failed!");
              }
            }
            if (context.mounted) {
              if (widget.callback != null) {
                widget.callback!();
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
