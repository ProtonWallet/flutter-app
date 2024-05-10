import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionFilterSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, viewModel, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              ListTile(
                trailing: Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .transactionFilter
                        .isEmpty
                    ? SvgPicture.asset("assets/images/icon/ic-checkmark.svg",
                        fit: BoxFit.fill, width: 20, height: 20)
                    : null,
                title: Text(S.of(context).transaction_filter_all_transactions,
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                onTap: () {
                  Provider.of<ProtonWalletProvider>(context, listen: false)
                      .applyHistoryTransactionFilterAndKeyword(
                          "", viewModel.transactionSearchController.text);
                  Navigator.of(context).pop();
                },
              ),
              const Divider(
                thickness: 0.2,
                height: 1,
              ),
              ListTile(
                trailing: Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .transactionFilter
                        .contains("send")
                    ? SvgPicture.asset("assets/images/icon/ic-checkmark.svg",
                        fit: BoxFit.fill, width: 20, height: 20)
                    : null,
                title: Text(S.of(context).transaction_filter_sent,
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                onTap: () {
                  Provider.of<ProtonWalletProvider>(context, listen: false)
                      .applyHistoryTransactionFilterAndKeyword(
                          "send", viewModel.transactionSearchController.text);
                  Navigator.of(context).pop();
                },
              ),
              const Divider(
                thickness: 0.2,
                height: 1,
              ),
              ListTile(
                trailing: Provider.of<ProtonWalletProvider>(context)
                        .protonWallet
                        .transactionFilter
                        .contains("receive")
                    ? SvgPicture.asset("assets/images/icon/ic-checkmark.svg",
                        fit: BoxFit.fill, width: 20, height: 20)
                    : null,
                title: Text(S.of(context).transaction_filter_received,
                    style: FontManager.body2Regular(ProtonColors.textNorm)),
                onTap: () {
                  Provider.of<ProtonWalletProvider>(context, listen: false)
                      .applyHistoryTransactionFilterAndKeyword("receive",
                          viewModel.transactionSearchController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      );
    }));
  }
}