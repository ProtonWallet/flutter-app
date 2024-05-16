import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/alert.warning.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class DeleteAccountSheet {
  static void show(
      BuildContext context, HomeViewModel viewModel, AccountModel userAccount) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            AlertWarning(
                content: S.of(context).delete_account_message,
                width: MediaQuery.of(context).size.width),
            Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV5(
                    onPressed: () async {
                      await viewModel.deleteAccount(
                          Provider.of<ProtonWalletProvider>(context,
                                  listen: false)
                              .protonWallet
                              .currentWallet!,
                          userAccount);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        CommonHelper.showSnackbar(
                            context, S.of(context).account_deleted);
                      }
                    },
                    backgroundColor: ProtonColors.signalError,
                    text: S.of(context).delete_account,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(
                        ProtonColors.backgroundSecondary),
                    height: 48)),
          ]);
    }));
  }
}
