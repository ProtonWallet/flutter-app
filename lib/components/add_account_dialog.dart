import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';

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
      title: Text(S.of(context).import_account),
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
          decoration: InputDecoration(
              labelText: S.of(context).derivation_path,
              hintText: "m/purpose'/coin'/account'/0"),
        ),
        TextField(
          onChanged: (value) {
            setState(() {
              label = value;
            });
          },
          decoration: InputDecoration(
              labelText: S.of(context).label,
              hintText: S.of(context).label_for_this_account),
        ),
      ]),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () async {
            SecretKey? secretKey =
                await WalletManager.getWalletKey(widget.walletID);
            if (secretKey == null) {
              if (context.mounted) {
                LocalToast.showErrorToast(context, "secretKey is null!");
              }
              return;
            }
            //TODO:: logics need move to viewmodel
            CreateWalletAccountReq req = CreateWalletAccountReq(
                label: base64Encode(utf8
                    .encode(await WalletKeyHelper.encrypt(secretKey, label))),
                derivationPath: derivationPath,
                scriptType: ScriptType.nativeSegWit.index);

            try {
              WalletAccount walletAccount =
                  await proton_api.createWalletAccount(
                walletId: widget.serverWalletID,
                req: req,
              );

              WalletManager.importAccount(widget.walletID, label,
                  scriptType.index, "$derivationPath/0", walletAccount.id);
              if (context.mounted) {
                LocalToast.showToast(context, S.of(context).account_created);
              }
            } catch (e) {
              if (context.mounted) {
                LocalToast.showToast(
                    context, S.of(context).account_created_failed_err(e));
              }
            }

            if (context.mounted) {
              if (widget.callback != null) {
                widget.callback!();
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }
}
