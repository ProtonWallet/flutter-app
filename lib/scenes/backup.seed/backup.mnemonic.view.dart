import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/tag.v2.dart';

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
          Assets.images.icon.key.applyThemeIfNeeded(context).image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
          Text(S.of(context).mnemonic_backup_content_title,
              style: ProtonStyles.headline(color: ProtonColors.textNorm)),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(
              top: 10,
            ),
            child: Text(
                S.of(context).mnemonic_backup_content_subtitle(walletName),
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
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
          textStyle: ProtonStyles.body1Medium(
            color: ProtonColors.textInverted,
          ),
          height: 52,
        ),
      ),
    ]));
  }
}
