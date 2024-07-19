import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/delete.account.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class AdvanceWalletAccountSettingSheet {
  static void show(
    BuildContext context,
    HomeViewModel viewModel,
    WalletModel userWallet,
    AccountMenuModel userAccount,
  ) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          ListTile(
              leading: Icon(Icons.delete_rounded,
                  size: 18, color: ProtonColors.signalError),
              title: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Text(S.of(context).delete_account,
                      style:
                          FontManager.body2Regular(ProtonColors.signalError))),
              onTap: () {
                Navigator.of(context).pop();
                DeleteAccountSheet.show(
                    context, viewModel, userWallet, userAccount);
              }),
        ],
      );
    }));
  }
}
