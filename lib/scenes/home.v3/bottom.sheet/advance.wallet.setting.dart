import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class AdvanceWalletSettingSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, viewModel, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          ListTile(
              leading: Icon(Icons.refresh_rounded,
                  size: 18, color: ProtonColors.textNorm),
              title: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Text(S.of(context).backup_wallet,
                      style: FontManager.body2Regular(
                          ProtonColors.textNorm))),
              onTap: () {
                Navigator.of(context).pop();
                viewModel.move(ViewIdentifiers.setupBackup);
              }),
          const Divider(
            thickness: 0.2,
            height: 1,
          ),
          ListTile(
              leading: Icon(Icons.delete_rounded,
                  size: 18, color: ProtonColors.signalError),
              title: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Text(S.of(context).delete_wallet,
                      style: FontManager.body2Regular(
                          ProtonColors.signalError))),
              onTap: () {
                Navigator.of(context).pop();
                viewModel.move(ViewIdentifiers.walletDeletion);
              }),
        ],
      );
    }));
  }
}