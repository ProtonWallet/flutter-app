import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.slider.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/rbf/rbf.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class RbfView extends ViewBase<RbfViewModel> {
  const RbfView(RbfViewModel viewModel)
      : super(viewModel, const Key("RbfView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      height: context.height * 0.8,
      backgroundColor: ProtonColors.white,
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
            ),
            Assets.images.icon.earlyAccess.image(
              fit: BoxFit.fill,
              width: 240,
              height: 167,
            ),
            Text(
              S.of(context).rbf_title,
              style: FontManager.titleHeadline(ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).rbf_desc,
              style: FontManager.body2Median(ProtonColors.textWeak),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            viewModel.initialized
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).rbf_current_fee,
                        style: FontManager.body1Median(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${viewModel.fiatCurrencySign} ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, viewModel.currentFee), displayDigits: viewModel.displayDigits)}",
                        style: FontManager.body1Median(ProtonColors.textNorm),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : const CardLoading(height: 50),
            if (viewModel.initialized)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ExchangeCalculator.getBitcoinUnitLabel(
                      viewModel.bitcoinUnit,
                      viewModel.currentFee),
                  style: FontManager.body1Median(ProtonColors.textHint),
                  textAlign: TextAlign.right,
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Divider(thickness: 0.2, height: 1),
            ),
            if (viewModel.initialized)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).rbf_new_fee,
                    style: FontManager.body1Median(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "${viewModel.fiatCurrencySign} ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, int.parse(viewModel.newFeeController.text)), displayDigits: viewModel.displayDigits)}",
                    style: FontManager.body1Median(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            if (viewModel.initialized)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ExchangeCalculator.getBitcoinUnitLabel(
                      viewModel.bitcoinUnit,
                      int.parse(viewModel.newFeeController.text)),
                  style: FontManager.body1Median(ProtonColors.textHint),
                  textAlign: TextAlign.right,
                ),
              ),
            const SizedBox(
              height: 12,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return viewModel.initialized
                  ? CustomSliderV1(
                      value: viewModel.initialNewFee,
                      minValue: viewModel.minNewFee,
                      maxValue: viewModel.maxNewFee,
                      controller: viewModel.newFeeController,
                    )
                  : const CardLoading(height: 50);
            }),
            const SizedBox(
              height: 6,
            ),
            viewModel.initialized
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                          S
                              .of(context)
                              .rbf_confirm_speed(getSpeedString(context)),
                          style: FontManager.body2Median(ProtonColors.textWeak),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          S.of(context).rbf_confirm_speed_in_minutes(
                              viewModel.estimatedBlock * 10),
                          style: FontManager.body1Bold(ProtonColors.textNorm),
                          textAlign: TextAlign.center,
                        ),
                      ])
                : const CardLoading(height: 30),
            const SizedBox(
              height: 26,
            ),
            ButtonV6(
                onPressed: () async {
                  final success = await viewModel.bumpTransactionFees();
                  if (context.mounted && success) {
                    Navigator.of(context).pop(); // exit rbf view
                    Navigator.of(context).pop(); // exit transaction detail view
                    CommonHelper.showSnackbar(
                      context,
                      S.of(context).rbf_send_success,
                    );
                  }
                },
                enable: viewModel.initialized,
                text: S.of(context).rbf_send,
                width: MediaQuery.of(context).size.width,
                backgroundColor: ProtonColors.protonBlue,
                textStyle:
                    FontManager.body1Median(ProtonColors.backgroundSecondary),
                borderColor: ProtonColors.protonBlue,
                height: 48),
          ],
        ),
      ),
    );
  }

  String getSpeedString(BuildContext context) {
    switch (viewModel.rbfSpeed) {
      case RBFSpeed.fast:
        return S.of(context).rbf_confirm_speed_fast;
      case RBFSpeed.normal:
        return S.of(context).rbf_confirm_speed_normal;
      default:
        return S.of(context).rbf_confirm_speed_low;
    }
  }
}
