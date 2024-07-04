import 'package:card_loading/card_loading.dart';
import 'package:country_picker/country_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'buybitcoin.viewmodel.dart';
import 'package:currency_picker/currency_picker.dart';

class BuyBitcoinView extends ViewBase<BuyBitcoinViewModel> {
  const BuyBitcoinView(BuyBitcoinViewModel viewModel)
      : super(viewModel, const Key("BuyBitcoinView"));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel.bloc,
      child: PageLayoutV1(
        title: S.of(context).buy_bitcoin,
        child: Column(
          children: [
            SizedBoxes.box32,

            /// switch button [buy / sell]
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF191C32),
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w600,
                          height: 0.08,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sell',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9294A3),
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w600,
                          height: 0.08,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBoxes.box18,

            /// country
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: BlocSelector<BuyBitcoinBloc, BuyBitcoinState,
                      BuyBitcoinState>(
                    selector: (state) {
                      return state;
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () => {
                          if (state.isCountryLoaded)
                            showCountryPicker(
                              context: context,
                              //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
                              countryFilter: state.isCountryLoaded
                                  ? state.countryCodes
                                  : null,
                              favorite: viewModel.favoriteCountryCode,
                              //Optional. Shows phone code before the country name.
                              showPhoneCode: false,
                              useSafeArea: true,
                              onSelect: (Country country) {
                                viewModel.selectCountry(country.countryCode);
                              },
                              // Optional. Sheet moves when keyboard opens.
                              moveAlongWithKeyboard: false,
                              // Optional. Sets the theme for the country list picker.
                              countryListTheme: CountryListThemeData(
                                // Optional. Sets the border radius for the bottomsheet.
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                // Optional. Styles the search field.
                                inputDecoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText: 'Start typing to search',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color(0xFF8C98A8)
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                // Optional. Styles the text in the search field
                                searchTextStyle: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                ),
                              ),
                            )
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 24,
                            right: 16,
                            bottom: 16,
                          ),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFFE6E8EC)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Country',
                                      style: TextStyle(
                                        color: Color(0xFF535964),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (state.isCountryLoaded)
                                      Text(
                                        state.selectedModel.country.name,
                                        style: const TextStyle(
                                          color: Color(0xFF191C32),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                    /// country loading
                                    if (!state.isCountryLoaded)
                                      const CardLoading(
                                        height: 26,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        margin: EdgeInsets.only(top: 4),
                                      ),
                                  ],
                                ),
                              ),
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
                  ),
                ),
              ],
            ),
            SizedBoxes.box18,

            /// input, price, provider
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// you pay input
                      BlocSelector<BuyBitcoinBloc, BuyBitcoinState,
                          BuyBitcoinState>(
                        selector: (state) {
                          return state;
                        },
                        builder: (context, state) {
                          return Container(
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 24,
                              right: 16,
                              bottom: 16,
                            ),
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1, color: Color(0xFFE6E8EC)),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /// currency input
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'You pay',
                                        style: TextStyle(
                                          color: Color(0xFF535964),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (state.isCurrencyLoaded)
                                        TextFormField(
                                          initialValue:
                                              state.selectedModel.amount,
                                          inputFormatters: [
                                            CurrencyTextInputFormatter.currency(
                                              name: state.selectedModel
                                                  .fiatCurrency.symbol,
                                              decimalDigits: 0,
                                              symbol: "",
                                              enableNegative: false,
                                              minValue: 1,
                                            ),
                                          ],
                                          onChanged: (value) {},
                                          onFieldSubmitted: (value) {
                                            viewModel.selectAmount(value);
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      if (!state.isCurrencyLoaded)
                                        const CardLoading(
                                          height: 26,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          margin: EdgeInsets.only(top: 4),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),

                                /// currency dropdown picker
                                GestureDetector(
                                  onTap: () => {
                                    if (state.isCurrencyLoaded)
                                      showCurrencyPicker(
                                        context: context,
                                        currencyFilter: state.currencyNames,
                                        showFlag: true,
                                        showSearchField: true,
                                        showCurrencyName: true,
                                        showCurrencyCode: true,
                                        // favorite: ['USD'],
                                        onSelect: (Currency currency) {
                                          viewModel
                                              .selectCurrency(currency.code);
                                        },
                                        theme: CurrencyPickerThemeData(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8.0),
                                              topRight: Radius.circular(8.0),
                                            ),
                                          ),
                                          // Optional. Styles the search field.
                                          inputDecoration: InputDecoration(
                                            labelText: 'Search',
                                            hintText: 'Start typing to search',
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color(0xFF8C98A8)
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      left: 16,
                                      right: 8,
                                      bottom: 10,
                                    ),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF3F5F6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (state.isCurrencyLoaded)
                                          Text(
                                            state.selectedModel.fiatCurrency
                                                .symbol,
                                            style: const TextStyle(
                                              color: Color(0xFF191C32),
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        Assets.images.icon.icChevronTinyDown
                                            .svg(
                                          fit: BoxFit.fill,
                                          width: 24,
                                          height: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      /// ramp providers
                      BlocSelector<BuyBitcoinBloc, BuyBitcoinState,
                          BuyBitcoinState>(
                        selector: (state) {
                          return state;
                        },
                        builder: (context, state) {
                          return GestureDetector(
                            onTap: () => {
                              // showDialog(
                              //     context: context,
                              //     barrierDismissible: true,
                              //     builder: (BuildContext context) {
                              //       return AccountDropdown(
                              //         widgets: [
                              //           for (final provider
                              //               in viewModel.providers)
                              //             PaymentDropdownItem(
                              //               item: DropdownItem(
                              //                 icon:
                              //                     'assets/images/credit-card.png',
                              //                 title: provider.title,
                              //                 subtitle: 'Take minutes',
                              //               ),
                              //             ),
                              //         ],
                              //         title: 'Choose your provider',
                              //       );
                              //     })
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 16,
                                left: 24,
                                right: 16,
                                bottom: 16,
                              ),
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1, color: Color(0xFFE6E8EC)),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                              ),
                              child: !state.isQuoteLoaded
                                  ? const CardLoading(height: 44)
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (!state.isQuoteLoaded)
                                                const CardLoading(height: 50),
                                              const Text(
                                                'You receive',
                                                style: TextStyle(
                                                  color: Color(0xFF535964),
                                                  fontSize: 14,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              state.isQuoteFailed
                                                  ? const Text(
                                                      '---',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF191C32),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                                  : Text(
                                                      '${state.selectedModel.selectedQuote.bitcoinAmount} BTC',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF191C32),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        BlocSelector<BuyBitcoinBloc,
                                            BuyBitcoinState, BuyBitcoinState>(
                                          selector: (state) {
                                            return state;
                                          },
                                          builder: (context, state) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Assets.images.icon.ramp.svg(
                                                  fit: BoxFit.fill,
                                                  width: 24,
                                                  height: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  state.providerModel
                                                      .providerInfo.name,
                                                  style: const TextStyle(
                                                    color: Color(0xFF191C32),
                                                    fontSize: 16,
                                                    fontFamily:
                                                        'SF Pro Display',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Assets.images.icon
                                                    .icChevronTinyDown
                                                    .svg(
                                                  fit: BoxFit.fill,
                                                  width: 24,
                                                  height: 24,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),

                      /// space
                      const SizedBox(height: 16),

                      /// estimation
                      BlocSelector<BuyBitcoinBloc, BuyBitcoinState,
                          BuyBitcoinState>(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                              "Quote is not a vailable but you can still try to buy",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (!state.isQuoteLoaded)
                                            const CardLoading(
                                              margin: EdgeInsets.only(top: 4),
                                              height: 15,
                                              width: 300,
                                            ),
                                          if (state.isQuoteLoaded &&
                                              !state.isQuoteFailed)
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
                                          if (state.isQuoteLoaded &&
                                              !state.isQuoteFailed)
                                            Text(
                                              "${state.selectedModel.selectedQuote.paymentGatewayFee} ${state.selectedModel.fiatCurrency.symbol}",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (!state.isQuoteLoaded)
                                            const CardLoading(
                                              margin: EdgeInsets.only(top: 4),
                                              height: 15,
                                              width: 300,
                                            ),
                                          if (state.isQuoteLoaded &&
                                              !state.isQuoteFailed)
                                            const Text(
                                              "network fee",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF9294A3),
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          if (state.isQuoteLoaded &&
                                              !state.isQuoteFailed)
                                            Text(
                                              "${state.selectedModel.selectedQuote.networkFee} ${state.selectedModel.fiatCurrency.symbol}",
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBoxes.box18,

            /// payments
            BlocSelector<BuyBitcoinBloc, BuyBitcoinState, BuyBitcoinState>(
              selector: (state) {
                return state;
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    // showDialog(
                    //   context: context,
                    //   barrierDismissible: true,
                    //   builder: (BuildContext context) {
                    //     return AccountDropdown(
                    //       widgets: [
                    //         for (var pay in viewModel.payments)
                    //           PaymentDropdownItem(
                    //             item: pay,
                    //           ),
                    //       ],
                    //       title: 'Pay with',
                    //     );
                    //   },
                    // );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 24,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFE6E8EC)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: !state.isQuoteLoaded
                        ? const CardLoading(height: 44)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Assets.images.icon.creditCard.svg(
                                      fit: BoxFit.fitHeight,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              /// payment type text
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      child: Text(
                                        'Pay with ',
                                        style: TextStyle(
                                          color: Color(0xFF535964),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Credit card',
                                      style: TextStyle(
                                        color: Color(0xFF191C32),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
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
            ),

            /// pay button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBoxes.box8,
                  BlocSelector<BuyBitcoinBloc, BuyBitcoinState,
                      BuyBitcoinState>(
                    selector: (state) {
                      return state;
                    },
                    builder: (context, state) {
                      return ButtonV5(
                          onPressed: state.isQuoteLoaded
                              ? () => {viewModel.pay(state.selectedModel)}
                              : null,
                          text:
                              "Buy with ${state.providerModel.providerInfo.name}",
                          width: MediaQuery.of(context).size.width - 100,
                          backgroundColor: ProtonColors.protonBlue,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          height: 48);
                    },
                  ),
                ],
              ),
            ),
            SizedBoxes.box8,

            ///buttom description
            const SizedBox(
              width: 400,
              child: Text(
                'Proton suggests the best provider based on your input and current market prices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9294A3),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBoxes.box24,
          ],
        ),
      ),
    );
  }
}
