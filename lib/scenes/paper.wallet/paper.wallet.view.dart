import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/extension/platform.extension.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/components/bottom.sheets/qr.code.scanner.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/transaction.history.item.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/paper.wallet/paper.wallet.viewmodel.dart';

class PaperWalletView extends ViewBase<PaperWalletViewModel> {
  const PaperWalletView(PaperWalletViewModel viewModel)
      : super(viewModel, const Key("PaperWalletView"));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: PageLayoutV1(
      headerWidget: Align(
        alignment: Alignment.centerRight,
        child: CloseButtonV1(
          backgroundColor: ProtonColors.backgroundNorm,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: ProtonColors.backgroundSecondary,
      child: buildContent(context),
    ));
  }

  Widget buildContent(BuildContext context) {
    switch (viewModel.pageStatus) {
      case PageStatus.importPaperWallet:
        return buildImportPaperWallet(context);
      case PageStatus.verifyBalance:
        return buildVerifyBalance(context);
    }
  }

  Widget buildVerifyBalance(BuildContext context) {
    final fiatCurrencyName = viewModel.getFiatCurrencyName();
    final fiatCurrencySign = viewModel.getFiatCurrencySign();
    final displayDigits = viewModel.getDisplayDigits();
    final bitcoinUnit = viewModel.getBitcoinUnit();
    return Column(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Row [icon | receive/send ]
          Row(
            children: [
              context.images.iconReceive.svg(
                fit: BoxFit.fill,
                width: 32,
                height: 32,
              ),
              SizedBoxes.box12,
              Text(
                context.local.you_received,
                style: ProtonStyles.body2Medium(
                  color: ProtonColors.textHint,
                ),
              )
            ],
          ),
          SizedBoxes.box12,

          /// Row [amount | currency]
          Row(
            children: [
              Text(
                  "$fiatCurrencySign${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.getExchangeRate(), viewModel.getTransactionAmount()), displayDigits: displayDigits)}",
                  style: ProtonStyles.headlineHugeSemibold(
                    color: ProtonColors.textNorm,
                  )),
              const SizedBox(width: 8),
              Text(
                fiatCurrencyName,
                style: ProtonStyles.body1Medium(
                  color: ProtonColors.textNorm,
                ),
              ),
            ],
          ),
          SizedBoxes.box12,
          Text(
            ExchangeCalculator.getBitcoinUnitLabel(
                bitcoinUnit, viewModel.getTransactionAmount()),
            style: ProtonStyles.body2Medium(
              color: ProtonColors.textHint,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          TransactionHistoryItem(
            title: context.local.trans_to,
            content: "${viewModel.walletName} - ${viewModel.accountName}",
            backgroundColor: ProtonColors.backgroundSecondary,
          ),
          const Divider(
            thickness: 0.2,
            height: 1,
          ),
          TransactionHistoryItem(
            title: context.local.trans_metwork_fee,
            content:
                "$fiatCurrencyName ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.getExchangeRate(), viewModel.getTransactionFee()), displayDigits: displayDigits)}",
            memo: ExchangeCalculator.getBitcoinUnitLabel(
                bitcoinUnit, viewModel.getTransactionFee()),
            backgroundColor: ProtonColors.backgroundSecondary,
          )
        ],
      ),
      const SizedBox(height: 26),
      ButtonV6(
        onPressed: () async {
          final result = await viewModel.broadcast();
          if (result && context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            LocalToast.showToast(
              context,
              context.local.paper_wallet_import_success_toast,
              duration: 2,
            );
            LocalToast.showToast(
              context,
              context.local.syncing_new_data,
              duration: 4,
            );
          }
        },
        backgroundColor: ProtonColors.protonBlue,
        text: context.local.confirm_and_import,
        width: MediaQuery.of(context).size.width,
        textStyle: ProtonStyles.body1Medium(
          color: ProtonColors.textInverted,
        ),
        height: 52,
      ),
      const SizedBox(
        height: defaultPadding,
      ),
    ]);
  }

  Widget buildImportPaperWallet(BuildContext context) {
    return Column(children: [
      Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.icon.bitcoinBigIcon.applyThemeIfNeeded(context).image(
                  fit: BoxFit.fill,
                  width: 240,
                  height: 167,
                ),
            Text(
              context.local.add_bitcoin,
              style: ProtonStyles.headline(color: ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              context.local.add_bitcoin_desc,
              style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFieldTextV2(
              labelText: context.local.private_key,
              backgroundColor: ProtonColors.backgroundSecondary,
              borderColor: ProtonColors.interActionWeakDisable,
              hintText: context.local.tap_to_add_bitcoin_hint,
              textController: viewModel.privateKeyController,
              myFocusNode: viewModel.privateKeyFocusNode,
              suffixIcon: (android || iOS)
                  ? IconButton(
                      onPressed: () {
                        if (android || iOS) {
                          viewModel.privateKeyFocusNode.unfocus();
                          viewModel.clearImportedError();
                          showQRScanBottomSheet(
                            context,
                            viewModel.privateKeyController,
                            null,
                          );
                        }
                      },
                      icon: Icon(Icons.qr_code_rounded,
                          size: 26, color: ProtonColors.textWeak),
                    )
                  : null,
              alwaysShowHint: true,
              maxLines: null,
              validation: (String newAccountName) {
                return "";
              },
            ),
            if (viewModel.importedError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Icon(
                    Icons.info_rounded,
                    size: 18,
                    color: ProtonColors.notificationError,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Flexible(
                    child: Text(
                      viewModel.importedError,
                      style: ProtonStyles.body2Medium(
                          color: ProtonColors.notificationError),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
      ButtonV6(
        onPressed: () async {
          await viewModel.tryImportWithPrivateKey();
        },
        backgroundColor: ProtonColors.protonBlue,
        text: context.local.continue_buttion,
        width: MediaQuery.of(context).size.width,
        textStyle: ProtonStyles.body1Medium(
          color: ProtonColors.textInverted,
        ),
        height: 52,
      ),
      const SizedBox(
        height: defaultPadding,
      ),
    ]);
  }
}
