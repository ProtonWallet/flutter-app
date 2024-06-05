import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/theme/theme.font.dart';

typedef WalletCallback = void Function(WalletModel wallet);
typedef AccountCallback = void Function(AccountModel wallet);
typedef SelectedCallback = void Function(
  WalletModel wallet,
  AccountModel account,
);
typedef DeleteCallback = void Function(
  WalletModel wallet,
  bool hasBalance,
  bool isInvalidWallet,
);

class SidebarWalletItems extends StatelessWidget {
  final WalletListBloc walletListBloc;
  final WalletCallback? addAccount;
  final SelectedCallback? selectAccount;
  final DeleteCallback? onDelete;
  final WalletCallback? updatePassphrase;

  const SidebarWalletItems({
    super.key,
    required this.walletListBloc,
    this.addAccount,
    this.selectAccount,
    this.onDelete,
    this.updatePassphrase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletListBloc, WalletListState>(
      bloc: walletListBloc,
      builder: (context, state) {
        if (state.initialized) {
          return Column(
            children: [
              for (WalletListModel wlModel in state.walletsModel)
                ListTileTheme(
                  contentPadding:
                      const EdgeInsets.only(left: defaultPadding, right: 10),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedBackgroundColor: _isCurrentWallet(state, wlModel)
                        ? ProtonColors.drawerBackgroundHighlight
                        : Colors.transparent,
                    backgroundColor: _isCurrentWallet(state, wlModel)
                        ? ProtonColors.drawerBackgroundHighlight
                        : Colors.transparent,
                    initiallyExpanded: wlModel.hasValidPassword,
                    leading: SvgPicture.asset(
                      "assets/images/icon/wallet-${state.walletsModel.indexOf(wlModel) % 4}.svg",
                      fit: BoxFit.fill,
                      width: 18,
                      height: 18,
                    ),
                    title: Transform.translate(
                      offset: const Offset(-8, 0),
                      // Build title
                      child:
                          _buildTitle(context, walletListBloc, state, wlModel),
                    ),
                    iconColor: ProtonColors.textHint,
                    collapsedIconColor: ProtonColors.textHint,
                    children: _buildExpansionChildren(
                      context,
                      walletListBloc,
                      state,
                      wlModel,
                    ),
                  ),
                ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  bool _isCurrentWallet(WalletListState state, WalletListModel walletData) {
    var currentWallet = state.currentWallet;
    if (currentWallet != null && state.currentAccount == null) {
      return currentWallet.serverWalletID == walletData.wallet.serverWalletID;
    }
    return false;
  }

  Widget _buildTitle(
    BuildContext context,
    WalletListBloc bloc,
    WalletListState state,
    WalletListModel wlModel,
  ) {
    if (wlModel.hasValidPassword) {
      return GestureDetector(
        onTap: null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: min(MediaQuery.of(context).size.width - 180,
                      drawerMaxWidth - 110),
                  child: Text(
                    wlModel.wallet.name,
                    style: FontManager.captionSemiBold(
                      AvatarColorHelper.getTextColor(
                          state.walletsModel.indexOf(wlModel)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${wlModel.accounts.length} accounts",
                  style: FontManager.captionRegular(ProtonColors.textHint),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Row(
        children: [
          GestureDetector(
            onTap: () {
              updatePassphrase?.call(wlModel.wallet);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: min(MediaQuery.of(context).size.width - 250,
                          drawerMaxWidth - 180),
                      child: Text(
                        wlModel.wallet.name,
                        style: FontManager.captionSemiBold(
                          AvatarColorHelper.getTextColor(
                              state.walletsModel.indexOf(wlModel)),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${wlModel.accounts.length} accounts",
                      style: FontManager.captionRegular(ProtonColors.textHint),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: ProtonColors.signalError,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              onDelete?.call(wlModel.wallet, false, true);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.delete_outline_rounded,
                color: ProtonColors.signalError,
                size: 24,
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> _buildExpansionChildren(
    BuildContext context,
    WalletListBloc bloc,
    WalletListState state,
    WalletListModel wlModel,
  ) {
    final List<Widget> children = [];
    if (wlModel.hasValidPassword) {
      for (AccountModel accountModel in wlModel.accounts) {
        children.add(
          Material(
            color: ProtonColors.drawerBackground,
            child: ListTile(
              tileColor: state.currentAccount == null
                  ? null
                  : accountModel.serverAccountID ==
                          state.currentAccount!.serverAccountID
                      ? ProtonColors.drawerBackgroundHighlight
                      : ProtonColors.drawerBackground,
              onTap: () {
                selectAccount?.call(wlModel.wallet, accountModel);
              },
              leading: Container(
                margin: const EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  "assets/images/icon/wallet-account-${state.walletsModel.indexOf(wlModel) % 4}.svg",
                  fit: BoxFit.fill,
                  width: 16,
                  height: 16,
                ),
              ),
              title: Transform.translate(
                offset: const Offset(-4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CommonHelper.getFirstNChar(
                              accountModel.labelDecrypt, 20),
                          style: FontManager.captionMedian(
                            AvatarColorHelper.getTextColor(
                                state.walletsModel.indexOf(wlModel)),
                          ),
                        ),
                      ],
                    ),
                    getWalletAccountBalanceWidget(
                      context,
                      accountModel,
                      AvatarColorHelper.getTextColor(
                          state.walletsModel.indexOf(wlModel)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      children.add(
        Material(
          color: ProtonColors.drawerBackground,
          child: ListTile(
            onTap: () {
              if (wlModel.accounts.length < freeUserWalletAccountLimit) {
                addAccount?.call(wlModel.wallet);
              } else {
                CommonHelper.showSnackbar(
                  context,
                  S.of(context).freeuser_wallet_account_limit(
                      freeUserWalletAccountLimit),
                );
              }
            },
            tileColor: ProtonColors.drawerBackground,
            leading: Container(
              margin: const EdgeInsets.only(left: 10),
              child: Assets.images.icon.addAccount.svg(
                fit: BoxFit.fill,
                width: 16,
                height: 16,
              ),
            ),
            title: Transform.translate(
              offset: const Offset(-4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).add_account,
                          style: FontManager.captionRegular(
                              ProtonColors.textHint)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return children;
  }

  // TODO:: build a balance bloc.
  Widget getWalletAccountBalanceWidget(
    BuildContext context,
    AccountModel accountModel,
    Color textColor,
  ) {
    double esitmateValue = Provider.of<UserSettingProvider>(context)
        .getNotionalInFiatCurrency(accountModel.balance.toInt());
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName()}${esitmateValue.toStringAsFixed(defaultDisplayDigits)}",
          style: FontManager.captionSemiBold(textColor)),
      Text(
          Provider.of<UserSettingProvider>(context)
              .getBitcoinUnitLabel(accountModel.balance.toInt()),
          style: FontManager.overlineRegular(ProtonColors.textHint))
    ]);
  }
}
