import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/tag.v2.dart';
import 'package:wallet/theme/theme.font.dart';

class BackupMnemonicView extends StatelessWidget {
  final List<Item> itemList;
  final VoidCallback? onPressed;
  final String walletName;
  const BackupMnemonicView({
    required this.itemList,
    required this.walletName,
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
          Assets.images.icon.key.image(
            fit: BoxFit.fill,
            width: 240,
            height: 167,
          ),
          Text(S.of(context).mnemonic_backup_content_title,
              style: FontManager.titleHeadline(ProtonColors.textNorm)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, ).copyWith(top: 10,),
            child: Text(S.of(context).mnemonic_backup_content_subtitle(walletName),
                style: FontManager.body2Regular(ProtonColors.textWeak),
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
