import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/backup.seed/backup.viewmodel.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/theme/theme.font.dart';

void showConfirm(BuildContext context, SetupBackupViewModel viewModel) {
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.backgroundProton,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(
                vertical: 30, horizontal: defaultPadding),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 10),
              Text(S.of(context).mnemonic_backup_confirm_title,
                  style: FontManager.titleHero(ProtonColors.textNorm)),
              const SizedBox(height: 10),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(S.of(context).mnemonic_backup_confirm_subtitle,
                      style: FontManager.body1Regular(ProtonColors.textHint))),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ButtonV5(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: ProtonColors.protonGrey,
                    text: S.of(context).cancel,
                    width: MediaQuery.of(context).size.width / 2 -
                        defaultPadding -
                        5,
                    textStyle: FontManager.body1Median(ProtonColors.textNorm),
                    radius: 40,
                    height: 55),
                ButtonV5(
                    onPressed: () {
                      viewModel.setBackup();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    backgroundColor: ProtonColors.protonBlue,
                    text: S.of(context).done,
                    width: MediaQuery.of(context).size.width / 2 -
                        defaultPadding -
                        5,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    radius: 40,
                    height: 55),
              ])
            ]));
      });
}
