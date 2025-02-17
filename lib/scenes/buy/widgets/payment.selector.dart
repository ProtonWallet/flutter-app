import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/scenes/buy/dropdown.dialog.dart';
import 'package:wallet/scenes/buy/payment.dropdown.item.dart';
import 'package:wallet/scenes/buy/payment.dropdown.item.view.dart';
import 'package:wallet/scenes/components/custom.card_loading.builder.dart';

typedef PaymentCallback = void Function(PaymentMethod wallet);

class PaymentSelector extends StatelessWidget {
  final PaymentCallback? onSelect;

  const PaymentSelector({
    super.key,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BuyBitcoinBloc, BuyBitcoinState, BuyBitcoinState>(
      selector: (state) {
        return state;
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state.received.isNotEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AccountDropdown(
                    widgets: [
                      for (final payment
                          in state.selectedModel.supportedPayments)
                        PaymentDropdownItem(
                          selected:
                              payment == state.selectedModel.paymentMethod,
                          item: DropdownItem(
                            title: payment.enumToString(),
                            subtitle: '',
                          ),
                          icon: payment.getIcon(),
                          onTap: () {
                            onSelect?.call(payment);
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                    title: 'Pay with',
                  );
                },
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 16,
              bottom: 16,
            ),
            decoration: ShapeDecoration(
              color: ProtonColors.backgroundSecondary,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE6E8EC)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: !state.isQuoteLoaded
                ? const CustomCardLoadingBuilder(height: 44).build(context)
                : Row(
                    children: [
                      /// payment type icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFE6E8EC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            state.selectedModel.paymentMethod.getIcon(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      /// payment type text
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: Text(
                                S.of(context).pay_with,
                                style: ProtonStyles.body2Medium(
                                    color: ProtonColors.textHint),
                              ),
                            ),
                            Text(
                              state.isQuoteFailed
                                  ? "-------"
                                  : state.selectedModel.paymentMethod
                                      .enumToString(),
                              style: ProtonStyles.body1Medium(
                                  color: ProtonColors.textNorm),
                            ),
                          ],
                        ),
                      ),

                      /// dropdown icon
                      Assets.images.icon.icChevronTinyDown.svg(
                        fit: BoxFit.fill,
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
