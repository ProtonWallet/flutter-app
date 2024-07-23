import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';

class EstimationWidget extends StatelessWidget {
  const EstimationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BuyBitcoinBloc, BuyBitcoinState, BuyBitcoinState>(
      selector: (state) {
        return state;
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!state.isQuoteLoaded)
                          const CardLoading(
                            margin: EdgeInsets.only(top: 4),
                            height: 15,
                            width: 300,
                          ),
                        if (state.isQuoteLoaded)
                          Text(
                            "${state.selectedModel.amount} ${state.selectedModel.fiatCurrency.symbol} is all you need to pay",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9294A3),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (state.isQuoteFailed)
                          Text(
                            S.of(context).quote_failed_warning,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ProtonColors.signalError,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBoxes.box8,
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!state.isQuoteLoaded)
                          const CardLoading(
                            margin: EdgeInsets.only(top: 4),
                            height: 15,
                            width: 300,
                          ),
                        if (state.isQuoteLoaded && !state.isQuoteFailed)
                          Text(
                            "${state.selectedModel.provider.enumToString()} fee",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9294A3),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (state.isQuoteLoaded && !state.isQuoteFailed)
                          Text(
                            "${state.selectedModel.paymentGatewayFee} ${state.selectedModel.fiatCurrency.symbol}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9294A3),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!state.isQuoteLoaded)
                          const CardLoading(
                            margin: EdgeInsets.only(top: 4),
                            height: 15,
                            width: 300,
                          ),
                        if (state.isQuoteLoaded && !state.isQuoteFailed)
                          Text(
                            S.of(context).trans_metwork_fee,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9294A3),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (state.isQuoteLoaded && !state.isQuoteFailed)
                          Text(
                            "${state.selectedModel.networkFee} ${state.selectedModel.fiatCurrency.symbol}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9294A3),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
