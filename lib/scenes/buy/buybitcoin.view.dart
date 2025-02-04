import 'package:card_loading/card_loading.dart';
import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.event.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';
import 'package:wallet/scenes/buy/buybitcoin.terms.dart';
import 'package:wallet/scenes/buy/widgets/payment.selector.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/core/view.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          color: ProtonColors.backgroundNorm,
        ),
        child: SafeArea(
          child: Column(children: [
            const CustomHeader(
              buttonDirection: AxisDirection.left,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: buildMainView(context),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /// build content
  Widget buildMainView(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel.bloc,
      child: SingleChildScrollView(
        child: BlocListener<BuyBitcoinBloc, BuyBitcoinState>(
          listener: (context, state) {
            if (state.error.isNotEmpty) {
              CommonHelper.showErrorDialog(
                state.error,
                callback: () {
                  viewModel.bloc.add(const ResetError(""));
                },
              );
            }
          },
          child: Column(
            children: [
              /// header `Buy`
              Text(
                S.of(context).buy,
                textAlign: TextAlign.center,
                style: ProtonStyles.headline(color: ProtonColors.textNorm),
              ),

              /// switch button [buy / sell]
              // const BuySellSwitch(showSell: false),
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
                                side:
                                    const BorderSide(color: Color(0xFFE6E8EC)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            Radius.circular(4),
                                          ),
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
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: '0.00',
                                                  // Remove the underline
                                                  border: InputBorder.none,
                                                  // Remove the underline when the field is enabled
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  // Remove the underline when the field is focused
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  // Remove the underline when the field has an error
                                                  errorBorder: InputBorder.none,
                                                  // Remove the underline when the field is disabled
                                                  disabledBorder:
                                                      InputBorder.none,
                                                ),
                                                controller:
                                                    viewModel.controller,
                                                focusNode: viewModel.focusNode,
                                                inputFormatters: [
                                                  CurrencyTextInputFormatter
                                                      .currency(
                                                    name: state.selectedModel
                                                        .fiatCurrency.symbol,
                                                    decimalDigits: 0,
                                                    symbol: "",
                                                    enableNegative: false,
                                                    minValue: 0,
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
                                              currencyFilter:
                                                  state.currencyNames,
                                              // favorite: ['USD'],
                                              onSelect: (Currency currency) {
                                                viewModel.selectCurrency(
                                                    currency.code);
                                              },
                                              theme: CurrencyPickerThemeData(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                ),
                                                // Optional. Styles the search field.
                                                inputDecoration:
                                                    InputDecoration(
                                                  labelText: 'Search',
                                                  hintText:
                                                      'Start typing to search',
                                                  prefixIcon:
                                                      const Icon(Icons.search),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: const Color(
                                                              0xFF8C98A8)
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
                                                  state.selectedModel
                                                      .fiatCurrency.symbol,
                                                  style: const TextStyle(
                                                    color: Color(0xFF191C32),
                                                    fontSize: 15,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              Assets
                                                  .images.icon.icChevronTinyDown
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
                                if (state.received.isNotEmpty)
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AccountDropdown(
                                          widgets: [
                                            for (final provider
                                                in state.received.entries)
                                              PaymentDropdownItem(
                                                icon: provider.key.getIcon(),
                                                item: DropdownItem(
                                                  title: provider.key
                                                      .enumToString(),
                                                  subtitle:
                                                      '${provider.value} BTC',
                                                ),
                                                selected: provider.key ==
                                                    state
                                                        .selectedModel.provider,
                                                onTap: () {
                                                  logger.i(provider.key
                                                      .enumToString());
                                                  viewModel.selectProvider(
                                                      provider.key);
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
                                                        '----------',
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
                                                  if (!state.isQuoteFailed)
                                                    state.selectedModel.provider
                                                        .getIcon(),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    state.isQuoteFailed
                                                        ? "------"
                                                        : state.selectedModel
                                                            .provider
                                                            .enumToString(),
                                                    style: ProtonStyles
                                                        .body2Medium(
                                                            color: const Color(
                                                                0xFF191C32)),
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
                      ],
                    ),
                  ),
                ],
              ),

              /// estimation
              // const EstimationWidget(),
              // SizedBoxes.box18,

              /// payments selector
              PaymentSelector(
                onSelect: viewModel.selectPayment,
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
                        return ButtonV6(
                            enable: state.isQuoteLoaded &&
                                !state.isQuoteFailed &&
                                !state.isCheckingOut,
                            isLoading:
                                state.isCheckingOut || !state.isQuoteLoaded,
                            onPressed: () async {
                              viewModel.focusNode.unfocus();
                              final model = viewModel.getTCModel(
                                state.selectedModel.provider,
                              );
                              OnRampTCSheet.show(context, model, onConfirm: () {
                                viewModel.pay(state.selectedModel);
                              }, onCancel: () {});
                            },
                            text: state.isCheckingOut
                                ? "Checking out"
                                : "Buy with ${state.selectedModel.provider.enumToString()}",
                            width: MediaQuery.of(context).size.width - 100,
                            backgroundColor: ProtonColors.protonBlue,
                            textStyle: ProtonStyles.body1Medium(
                                color: ProtonColors.textInverted),
                            height: 55);
                      },
                    ),
                  ],
                ),
              ),
              SizedBoxes.box8,

              SizedBoxes.box24,
            ],
          ),
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
