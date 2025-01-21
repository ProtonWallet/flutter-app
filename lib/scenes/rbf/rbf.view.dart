import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
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
            backgroundColor: ProtonColors.backgroundNorm,
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
              width: context.width,
            ),
            Assets.images.icon.earlyAccess.image(
              fit: BoxFit.fill,
              width: 240,
              height: 167,
            ),
            Text(
              S.of(context).rbf_title,
              style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).rbf_desc,
              style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
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
                        style: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${viewModel.fiatCurrencySign} ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, viewModel.currentFee), displayDigits: viewModel.displayDigits)}",
                        style: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm,
                        ),
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
                    viewModel.currentFee,
                  ),
                  style: ProtonStyles.body1Medium(color: ProtonColors.textHint),
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
                    style:
                        ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "${viewModel.fiatCurrencySign} ${CommonHelper.formatDouble(ExchangeCalculator.getNotionalInFiatCurrency(viewModel.exchangeRate, int.parse(viewModel.newFeeController.text)), displayDigits: viewModel.displayDigits)}",
                    style: ProtonStyles.body1Medium(
                      color: ProtonColors.textNorm,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            if (viewModel.initialized)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ExchangeCalculator.getBitcoinUnitLabel(viewModel.bitcoinUnit,
                      int.parse(viewModel.newFeeController.text)),
                  style: ProtonStyles.body1Medium(color: ProtonColors.textHint),
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
                          style: ProtonStyles.body2Medium(
                            color: ProtonColors.textWeak,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          S.of(context).rbf_confirm_speed_in_minutes(
                              viewModel.estimatedBlock * 10),
                          style: ProtonStyles.body1Semibold(
                            color: ProtonColors.textNorm,
                          ),
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
                  context.showSnackbar(context.local.rbf_send_success);
                }
              },
              enable: viewModel.initialized,
              text: S.of(context).rbf_send,
              width: context.width,
              backgroundColor: ProtonColors.protonBlue,
              textStyle: ProtonStyles.body1Medium(
                color: ProtonColors.textInverted,
              ),
              borderColor: ProtonColors.protonBlue,
              height: 48,
            ),
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
