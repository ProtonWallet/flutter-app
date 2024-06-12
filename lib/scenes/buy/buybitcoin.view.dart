import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/page.layout.v1.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/buy/dropdown.dialog.dart';
import 'package:wallet/scenes/buy/payment.dropdown.item.view.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/theme/theme.font.dart';

import 'buybitcoin.viewmodel.dart';

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
                            letterSpacing: -0.15,
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
                            letterSpacing: -0.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ToggleButtons(
                  //   isSelected: [viewModel.isBuying, !viewModel.isBuying],
                  //   onPressed: (index) {
                  //     viewModel.toggleButtons();
                  //   },
                  //   highlightColor: ProtonColors.protonBlue,
                  //   hoverColor: Colors.transparent,
                  //   splashColor: Colors.transparent,
                  //   renderBorder: false,
                  //   selectedColor: Colors.black,
                  //   fillColor: ProtonColors.protonGrey,
                  //   // color: Colors.black,
                  //   disabledColor: Colors.grey,
                  //   borderRadius: BorderRadius.circular(10.0),
                  //   constraints: const BoxConstraints(
                  //     minHeight: 36.0,
                  //     minWidth: 90.0,
                  //   ),
                  //   children: const [
                  //     Text('Buy'),
                  //     Text('Sell'),
                  //   ],
                  // ),
                ],
              ),
              SizedBoxes.box18,

              /// country
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
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
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBoxes.box12,
                          const Expanded(
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Country',
                                  style: TextStyle(
                                    color: Color(0xFF535964),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'United States',
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
                          Assets.images.icon.icChevronTinyDown.svg(
                            fit: BoxFit.fill,
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBoxes.box12,
                  Expanded(
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
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBoxes.box12,
                          const Expanded(
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'State',
                                  style: TextStyle(
                                    color: Color(0xFF535964),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Florida',
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
                          Assets.images.icon.icChevronTinyDown.svg(
                            fit: BoxFit.fill,
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const DropdownButtonV2(
                  //   labelText: "Account",
                  //   items: [],
                  //   itemsText: ["BTC Account"],
                  //   valueNotifier: null,
                  //   width: 200,
                  // ),
                  // const DropdownButtonV2(
                  //   labelText: "Account",
                  //   items: [],
                  //   itemsText: ["BTC Account"],
                  //   valueNotifier: null,
                  //   width: 200,
                  // ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              SizedBoxes.box18,

              /// input and price
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// you pay input
                        Container(
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
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        'You pay',
                                        style: TextStyle(
                                          color: Color(0xFF535964),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextField(
                                        inputFormatters: [
                                          CurrencyTextInputFormatter.currency(
                                            locale: 'en-US',
                                            decimalDigits: 2,
                                            symbol: "\$",
                                          ),
                                        ],
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 16,
                                  right: 8,
                                  bottom: 10,
                                ),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF3F5F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'USD',
                                              style: TextStyle(
                                                color: Color(0xFF191C32),
                                                fontSize: 15,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Assets.images.icon.icChevronTinyDown.svg(
                                      fit: BoxFit.fill,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// ramp providers
                        GestureDetector(
                          onTap: () => {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AccountDropdown(
                                    widgets: [
                                      for (final provider
                                          in viewModel.providers)
                                        PaymentDropdownItem(
                                          item: provider,
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
                                side: BorderSide(
                                    width: 1, color: Color(0xFFE6E8EC)),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You receive',
                                        style: TextStyle(
                                          color: Color(0xFF535964),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '0.00155 BTC',
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
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Recommended',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Color(0xFF767DFF),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: FlutterLogo(),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ramp',
                                      style: TextStyle(
                                        color: Color(0xFF191C32),
                                        fontSize: 16,
                                        fontFamily: 'SF Pro Display',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Assets.images.icon.icChevronTinyDown.svg(
                                      fit: BoxFit.fill,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// space
                        const SizedBox(height: 16),

                        /// estimation
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '1 BTC ≈ \$60,045.78 CHF (Includes fee)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF9294A3),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBoxes.box18,

              /// payments
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AccountDropdown(
                        widgets: [
                          for (var pay in viewModel.payments)
                            PaymentDropdownItem(
                              item: pay,
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
                      side:
                          const BorderSide(width: 1, color: Color(0xFFE6E8EC)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
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
                            Container(
                              width: 16,
                              height: 16,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(),
                              child: const FlutterLogo(),
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
              ),

              /// pay button Ramp
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBoxes.box8,
                    ButtonV5(
                        onPressed: () => {viewModel.move(NavID.rampExternal)},
                        text: "Buy with Ramp",
                        width: MediaQuery.of(context).size.width - 100,
                        backgroundColor: ProtonColors.protonBlue,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                  ],
                ),
              ),

              /// pay button Banxa
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBoxes.box8,
                    ButtonV5(
                        onPressed: () => {viewModel.move(NavID.banaxExternal)},
                        text: "Buy with Banax",
                        width: MediaQuery.of(context).size.width - 100,
                        backgroundColor: ProtonColors.protonBlue,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
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
        ));
  }
}
