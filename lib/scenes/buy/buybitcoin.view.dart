import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/page.layout.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/buy/buybitcoin.bloc.dart';
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
              Text(viewModel.userEmail,
                  style: FontManager.body2Regular(ProtonColors.textHint)),
              Text(viewModel.receiveAddress,
                  style: FontManager.body2Regular(ProtonColors.textHint)),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.move(NavID.rampExternal);
                  },
                  child: const Text("Present Ramp"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      isSelected: [viewModel.isBuying, !viewModel.isBuying],
                      onPressed: (index) {
                        // setState(() {
                        //   isBuying = index == 0;
                        // });
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      selectedColor: Colors.white,
                      fillColor: Colors.blue,
                      color: Colors.black,
                      constraints: const BoxConstraints(
                          minHeight: 40.0, minWidth: 100.0),
                      children: const [
                        Text('Buy'),
                        Text('Sell'),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Receive to BTC address',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 5.0),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.blue),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    BlocBuilder<BuyBitcoinBloc, BuyBitcoinState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            if (state.isAddressLoaded)
                              const Text("Address Loaded"),
                            if (state.isCountryLoaded)
                              const Text("Country Loaded"),
                            if (!state.isAddressLoaded ||
                                !state.isCountryLoaded)
                              const CircularProgressIndicator(),
                            if (!state.isAddressLoaded)
                              ElevatedButton(
                                onPressed: () => {},
                                child: const Text('Load State A'),
                              ),
                            if (!state.isCountryLoaded)
                              ElevatedButton(
                                onPressed: () => {},
                                child: const Text('Load State B'),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: 'USD', //selectedCurrency,
                          onChanged: (String? newValue) {
                            // setState(() {
                            //   selectedCurrency = newValue!;
                            // });
                          },
                          items: <String>['USD', 'EUR', 'GBP', 'JPY']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 20.0),
                        DropdownButton<String>(
                          value: 'USA', // selectedCountry,
                          onChanged: (String? newValue) {
                            // setState(() {
                            //   selectedCountry = newValue!;
                            // });
                          },
                          items: <String>['USA', 'UK', 'Germany', 'Japan']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  // Image.asset(
                                  //   'assets/flags/${value.toLowerCase()}.png',
                                  //   width: 24,
                                  //   height: 24,
                                  // ),
                                  const SizedBox(width: 10.0),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pay with Credit card\nwith Ramp',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          viewModel.isloading
                              ? const CircularProgressIndicator()
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: const Text(
                                    'Recommended',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ButtonV5(
                        onPressed:
                            viewModel.isloading ? null : viewModel.startLoading,
                        text: "Buy with credit card",
                        width: MediaQuery.of(context).size.width - 100,
                        backgroundColor: ProtonColors.protonBlue,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
