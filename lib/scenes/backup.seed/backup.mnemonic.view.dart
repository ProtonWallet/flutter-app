import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/tag.v2.dart';
import 'package:wallet/theme/theme.font.dart';

class BackupMnemonicView extends StatelessWidget {
  final List<Item> itemList;
  final VoidCallback? onPressed;
  const BackupMnemonicView({
    required this.itemList,
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      Expanded(
          child: SingleChildScrollView(
              child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Text(S.of(context).mnemonic_backup_content_title,
              style: FontManager.titleHero(ProtonColors.textNorm)),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(S.of(context).mnemonic_backup_content_subtitle,
                style: FontManager.body1Regular(ProtonColors.textWeak),
                textAlign: TextAlign.center),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  for (int i = 0; i < itemList.length ~/ 2; i++)
                    TagV2(
                      width: 164,
                      text: itemList[i].title!,
                      index: i + 1,
                    ),
                ],
              ),
              Column(
                children: [
                  for (int i = itemList.length ~/ 2; i < itemList.length; i++)
                    TagV2(
                      width: 164,
                      text: itemList[i].title!,
                      index: i + 1,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 22,
          ),
        ],
      ))),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ButtonV5(
              onPressed: () {
                onPressed?.call();
                Navigator.pop(context);
              },
              backgroundColor: ProtonColors.protonBlue,
              text: S.of(context).done,
              width: MediaQuery.of(context).size.width,
              textStyle: FontManager.body1Median(ProtonColors.white),
              radius: 40,
              height: 52)),
    ]));
  }
}
