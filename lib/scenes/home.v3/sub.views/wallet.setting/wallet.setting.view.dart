import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.state.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/sub.views/account.row.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/sub.views/expandable.options.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/sub.views/wallet.name.card.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.viewmodel.dart';

class WalletSettingView extends ViewBase<WalletSettingViewModel> {
  const WalletSettingView(WalletSettingViewModel viewModel)
      : super(viewModel, const Key("WalletSettingView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV2(
      title: S.of(context).wallet_preference,
      backgroundColor: ProtonColors.backgroundNorm,
      cbtBgColor: ProtonColors.backgroundSecondary,
      dividerOffset: 4,
      scrollController: viewModel.scrollController,
      child: BlocBuilder<WalletListBloc, WalletListState>(
        bloc: viewModel.walletListBloc,
        builder: (context, wlState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),

              /// wallet name card [icon | name | bitcoin unit]
              WalletNameCard(
                initialized: viewModel.initialized,
                maxWalletNameSize: maxWalletNameSize,
                waleltIndex: viewModel.walletMenuModel.currentIndex,
                nameController: viewModel.walletNameController,
                nameFocusNode: viewModel.walletNameFocusNode,
                onFinish: () async {
                  viewModel.updateWalletName(
                    viewModel.walletNameController.text,
                  );
                },
                valueNotifier: viewModel.bitcoinUnitNotifier,
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context).accounts,
                style: ProtonStyles.body1Semibold(color: ProtonColors.textWeak),
              ),
              const SizedBox(height: 12),
              BlocBuilder<WalletListBloc, WalletListState>(
                bloc: viewModel.walletListBloc,
                builder: (context, state) {
                  return Column(children: [
                    for (final accountMenuModel
                        in viewModel.walletMenuModel.accounts)
                      AccountRow(
                        viewModel: viewModel,
                        accountMenuModel: accountMenuModel,
                        settingInfo: viewModel.getAccSettingsBy(
                          accountID: accountMenuModel.accountID,
                        ),
                      )
                  ]);
                },
              ),

              /// bottom view more button
              ExpandableOptions(
                scrollController: viewModel.scrollController,
                onBackupWallet: () {
                  viewModel.move(NavID.setupBackup);
                },
                onDeleteWallet: () {
                  viewModel.showDeleteWallet(
                    triggerFromSidebar: false,
                  );
                },
              ),

              ///
              const SizedBox(height: defaultPadding),
            ],
          );
        },
      ),
    );
  }
}
