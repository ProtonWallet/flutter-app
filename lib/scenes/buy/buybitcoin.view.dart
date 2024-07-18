import 'package:card_loading/card_loading.dart';
import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';

import 'buybitcoin.keyboard.done.dart';
import 'buybitcoin.viewmodel.dart';
import 'dropdown.dialog.dart';
import 'payment.dropdown.item.dart';
import 'payment.dropdown.item.view.dart';

class BuyBitcoinView extends ViewBase<BuyBitcoinViewModel> {
  const BuyBitcoinView(BuyBitcoinViewModel viewModel)
      : super(viewModel, const Key("BuyBitcoinView"));

  @override
  Widget build(BuildContext context) {
    viewModel.focusNode.addListener(() {
      final bool hasFocus = viewModel.focusNode.hasFocus;
      if (hasFocus) {
        showOverlay(context, viewModel.keyboardDone);
      } else {
        removeOverlay();
      }
    });

    return BlocProvider(
      create: (context) => viewModel.bloc,
      child: PageLayoutV1(
        title: S.of(context).buy_bitcoin,
        child: Column(
          children: [
            SizedBoxes.box32,

            /// switch button [buy / sell]
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).buy,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).sell,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                              favorite: state.isCountryLoaded
                                  ? viewModel
                                      .getFavoriteCountry(state.countryCodes)
                                  : null,
                              useSafeArea: true,
                              onSelect: (Country country) {
                                viewModel.selectCountry(country.countryCode);
                              },
                              // Optional. Sets the theme for the country list picker.
                              countryListTheme: CountryListThemeData(
                                // Optional. Sets the border radius for the bottomsheet.
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                // Optional. Styles the search field.
                                inputDecoration: InputDecoration(
                                  labelText: S.of(context).search,
                                  hintText: S.of(context).search_hint,
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
                              side: const BorderSide(color: Color(0xFFE6E8EC)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.of(context).country,
                                      style: const TextStyle(
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
                            ),
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Color(0xFFE6E8EC)),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                            ),
                            child: KeyboardVisibilityBuilder(
                              builder: (context, isKeyboardVisible) {
                                if (!isKeyboardVisible) {
                                  removeOverlay();
                                }
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /// currency input
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).you_pay,
                                            style: const TextStyle(
                                              color: Color(0xFF535964),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          if (state.isCurrencyLoaded)
                                            TextFormField(
                                              decoration: const InputDecoration(
                                                hintText: 'Enter text',
                                                // Remove the underline
                                                border: InputBorder.none,
                                                // Remove the underline when the field is enabled
                                                enabledBorder: InputBorder.none,
                                                // Remove the underline when the field is focused
                                                focusedBorder: InputBorder.none,
                                                // Remove the underline when the field has an error
                                                errorBorder: InputBorder.none,
                                                // Remove the underline when the field is disabled
                                                disabledBorder:
                                                    InputBorder.none,
                                              ),
                                              controller: viewModel.controller,
                                              focusNode: viewModel.focusNode,
                                              inputFormatters: [
                                                CurrencyTextInputFormatter
                                                    .currency(
                                                  name: state.selectedModel
                                                      .fiatCurrency.symbol,
                                                  decimalDigits: 0,
                                                  symbol: "",
                                                  enableNegative: false,
                                                  minValue: 1,
                                                ),
                                              ],
                                              onChanged: (value) {},
                                              onFieldSubmitted:
                                                  viewModel.selectAmount,
                                              keyboardType:
                                                  TextInputType.number,
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
                                            // favorite: ['USD'],
                                            onSelect: (Currency currency) {
                                              viewModel.selectCurrency(
                                                  currency.code);
                                            },
                                            theme: CurrencyPickerThemeData(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0),
                                                ),
                                              ),
                                              // Optional. Styles the search field.
                                              inputDecoration: InputDecoration(
                                                labelText: 'Search',
                                                hintText:
                                                    'Start typing to search',
                                                prefixIcon:
                                                    const Icon(Icons.search),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        const Color(0xFF8C98A8)
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                );
                              },
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
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AccountDropdown(
                                      widgets: [
                                        for (final provider
                                            in state.supportedProviders)
                                          PaymentDropdownItem(
                                            icon: provider.getIcon(),
                                            item: DropdownItem(
                                              title: provider.enumToString(),
                                              subtitle:
                                                  '${state.received[provider]} BTC',
                                            ),
                                            selected: provider ==
                                                state.selectedModel.provider,
                                            onTap: () {
                                              logger.i(provider.enumToString());
                                              viewModel
                                                  .selectProvider(provider);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                      ],
                                      title: 'Choose your provider',
                                    );
                                  })
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
                                  side: BorderSide(color: Color(0xFFE6E8EC)),
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
                                              Text(
                                                S.of(context).you_receive,
                                                style: const TextStyle(
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
                                              children: [
                                                state.selectedModel.provider
                                                    .getIcon(),
                                                const SizedBox(width: 8),
                                                Text(
                                                  state.selectedModel.provider
                                                      .enumToString(),
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
                                              S
                                                  .of(context)
                                                  .quote_failed_warning,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                              S.of(context).trans_metwork_fee,
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AccountDropdown(
                          widgets: [
                            for (var payment
                                in state.selectedModel.supportedPayments)
                              PaymentDropdownItem(
                                selected: payment ==
                                    state.selectedModel.paymentMethod,
                                item: DropdownItem(
                                  title: payment.enumToString(),
                                  subtitle: '',
                                ),
                                icon: payment.getIcon(),
                                onTap: () {
                                  viewModel.selectPayment(payment);
                                  Navigator.of(context).pop();
                                },
                              ),
                          ],
                          title: 'Pay with',
                        );
                      },
                    );
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
                        side: const BorderSide(color: Color(0xFFE6E8EC)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: !state.isQuoteLoaded
                        ? const CardLoading(height: 44)
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
                                        style: const TextStyle(
                                          color: Color(0xFF535964),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      state.selectedModel.paymentMethod
                                          .enumToString(),
                                      style: const TextStyle(
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
                              ? () => {
                                    viewModel.focusNode.unfocus(),
                                    viewModel.pay(state.selectedModel),
                                  }
                              : null,
                          text:
                              "Buy with ${state.selectedModel.provider.enumToString()}",
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
            SizedBox(
              width: 400,
              child: Text(
                S.of(context).buy_flow_bottom_desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
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

  /// when platform is ios. we show overlay on top of keyboard Done button
  void showOverlay(BuildContext context, VoidCallback? onTap) {
    if (TargetPlatform.iOS != defaultTargetPlatform) return;
    if (viewModel.overlayEntry != null) return;
    final OverlayState overlayState = Overlay.of(context);
    viewModel.overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView(onTap: onTap));
    });

    overlayState.insert(viewModel.overlayEntry!);
  }

  /// remove the overlay
  void removeOverlay() {
    if (viewModel.overlayEntry != null) {
      viewModel.overlayEntry!.remove();
      viewModel.overlayEntry = null;
    }
  }
}
