import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/delete.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.auth.dialog.dart';
import 'package:wallet/theme/theme.font.dart';

class DeleteWalletSheet {
  static void show(
    BuildContext context,
    HomeViewModel viewModel,
    WalletMenuModel walletMenuModel, {
    required bool hasBalance,
    bool isInvalidWallet = false,
    VoidCallback? onBackup,
  }) {
    bool isDeleting = false;
    HomeModalBottomSheet.show(
      context,
      child: BlocProvider.value(
        value: viewModel.deleteWalletBloc,
        child: BlocListener<DeleteWalletBloc, DeleteWalletState>(
          listener: (context, state) {
            if (state.deleted) {
              if (context.mounted) {
                if (!isInvalidWallet) {
                  Navigator.of(context).pop(); // pop up this bottomSheet
                  Navigator.of(context)
                      .pop(); // pop up wallet setting bottomSheet
                } else {
                  Navigator.of(context).pop(); // pop up this bottomSheet
                }
                CommonHelper.showSnackbar(
                    context, S.of(context).wallet_deleted);
              }
            }
            if (state.error.isNotEmpty) {
              CommonHelper.showErrorDialog(state.error);
            }
            if (state.requireAuthModel.requireAuth) {
              showAuthDialog(context, state.requireAuthModel.twofaStatus, (
                password,
                twofa,
              ) async {
                viewModel.deleteWalletAuth(
                  walletMenuModel.walletModel,
                  password,
                  twofa,
                );
              }, () {});
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                }),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Column(children: [
                  Assets.images.icon.deleteWarning.svg(
                    width: 72,
                    height: 72,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            S.of(context).confirm_to_delete_wallet(
                                walletMenuModel.walletName),
                            style: FontManager.titleHeadline(
                                ProtonColors.textNorm),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        if (hasBalance)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AlertCustom(
                              content: S
                                  .of(context)
                                  .confirm_to_delete_wallet_has_balance_warning,
                              canClose: false,
                              leadingWidget:
                                  Assets.images.icon.alertWarning.svg(
                                width: 22,
                                height: 22,
                                fit: BoxFit.fill,
                              ),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 0,
                              ),
                              backgroundColor: ProtonColors.errorBackground,
                              color: ProtonColors.signalError,
                            ),
                          ),
                        Text(S.of(context).confirm_to_delete_wallet_content,
                            style: FontManager.body2Regular(
                                ProtonColors.textWeak)),
                        const SizedBox(height: 40),
                        ButtonV5(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            onBackup?.call();
                          },
                          text: S.of(context).backup_wallet,
                          width: MediaQuery.of(context).size.width,
                          textStyle:
                              FontManager.body1Median(ProtonColors.textNorm),
                          backgroundColor: ProtonColors.textWeakPressed,
                          borderColor: ProtonColors.textWeakPressed,
                          height: 48,
                        ),
                        const SizedBox(height: 8),
                        BlocSelector<DeleteWalletBloc, DeleteWalletState, bool>(
                          selector: (state) {
                            return state.isLoading;
                          },
                          builder: (context, loading) {
                            return ButtonV6(
                              onPressed: () async {
                                if (!loading || !isDeleting) {
                                  isDeleting = true;
                                  viewModel.deleteWallet(
                                    walletMenuModel.walletModel,
                                  );
                                  isDeleting = false;
                                }
                              },
                              isLoading: loading,
                              enable: !loading,
                              text: S.of(context).delete_wallet_now,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.signalError,
                              borderColor: ProtonColors.signalError,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
