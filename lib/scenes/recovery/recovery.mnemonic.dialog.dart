import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/scenes/components/button.v5.dart';

Future<void> showMnemonicDialog(
  BuildContext context,
  String mnemonic,
  VoidCallback onClick,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Your recovery phrase'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const SizedBox(
                width: 360,
                child: Text(
                  "Your recovery phrase is a series of 12 words in a specific order.",
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 360,
                child: Text(
                  "Please keep it safe. You'll need it to access your account and decrypt your data in case of a password reset.",
                  style: TextStyle(
                    color: Color(0xFFFFC483),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Recovery phrase",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16).copyWith(bottom: 8),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                width: 360,
                child: GestureDetector(
                  onTap: () async {
                    Clipboard.setData(ClipboardData(text: mnemonic)).then((_) {
                      if (context.mounted) {
                        CommonHelper.showSnackbar(
                            context, "Recovery phrase copied to clipboard");
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(mnemonic),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Assets.images.icon.icSquares.svg(
                        width: 32,
                        height: 32,
                        fit: BoxFit.fill,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonV5(
                onPressed: () {
                  onClick();
                  Navigator.of(context).pop();
                },
                text: 'Done',
                width: 100,
                height: 44,
              ),
              ButtonV5(
                onPressed: () {
                  Share.share(
                    mnemonic,
                    subject: "Recovery phrase",
                  );
                },
                text: 'Share',
                width: 100,
                height: 44,
              ),
            ],
          ),
        ],
      );
    },
  );
}
