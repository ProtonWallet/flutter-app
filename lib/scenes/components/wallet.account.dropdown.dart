import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/theme/theme.font.dart';

class WalletAccountDropdown extends StatefulWidget {
  final double width;
  final List<AccountModel> accounts;
  final ValueNotifier? valueNotifier;
  final String? labelText;
  final Color? backgroundColor;
  final BitcoinUnit? bitcoinUnit;
  final EdgeInsetsGeometry? padding;

  const WalletAccountDropdown({
    required this.width,
    required this.accounts,
    super.key,
    this.labelText,
    this.valueNotifier,
    this.backgroundColor,
    this.padding,
    this.bitcoinUnit = BitcoinUnit.btc,
  });

  @override
  WalletAccountDropdownState createState() => WalletAccountDropdownState();
}

class WalletAccountDropdownState extends State<WalletAccountDropdown> {
  dynamic selected;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    selected = widget.valueNotifier?.value;
    final int selectedIndex = _getIndexOfAccount(selected);
    _textEditingController.text = widget.accounts[selectedIndex].labelDecrypt;
    super.initState();
  }

  int _getIndexOfAccount(AccountModel selectedAccount) {
    int selectedIndex = 0;
    for (AccountModel accountModel in widget.accounts) {
      if (accountModel.accountID == selectedAccount.accountID) {
        selectedIndex = widget.accounts.indexOf(accountModel);
        break;
      }
    }
    return selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return widget.accounts.isNotEmpty
        ? buildWithList(context)
        : Text(S.of(context).no_data);
  }

  Widget buildWithList(BuildContext buildContext) {
    return Container(
        width: widget.width,
        padding: widget.padding ??
            const EdgeInsets.only(
                left: defaultPadding, right: 8, top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? ProtonColors.white,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: TextField(
          controller: _textEditingController,
          readOnly: true,
          onTap: () {
            if (widget.accounts.length > 1) {
              showOptionsInBottomSheet(context);
              Future.delayed(const Duration(milliseconds: 100), () {
                _scrollTo(_getIndexOfAccount(selected) * 60 -
                    MediaQuery.of(context).size.height / 6 +
                    60);
              });
            }
          },
          style: FontManager.body1Median(ProtonColors.textNorm),
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            labelText: widget.labelText,
            labelStyle: FontManager.textFieldLabelStyle(ProtonColors.textWeak)
                .copyWith(fontSize: 15),
            suffixIconConstraints: const BoxConstraints(maxWidth: 24.0),
            contentPadding: const EdgeInsets.only(top: 4, bottom: 16),
            suffixIcon: widget.accounts.length > 1
                ? Icon(Icons.keyboard_arrow_down_rounded,
                    color: ProtonColors.textWeak, size: 24)
                : null,
          ),
        ));
  }

  void _scrollTo(double offset) {
    if (offset > 0) {
      try {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        e.toString();
      }
    }
  }

  Widget getWalletAccountBalanceWidget(
    BuildContext context,
    AccountModel accountModel,
  ) {
    final fiatCurrency = accountModel.getFiatCurrency();
    final ProtonExchangeRate? exchangeRate =
        ExchangeRateService.getExchangeRateOrNull(fiatCurrency);
    double estimatedValue = 0.0;
    if (exchangeRate != null) {
      estimatedValue = ExchangeCalculator.getNotionalInFiatCurrency(
          exchangeRate, accountModel.balance.toInt());
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(
          "${Provider.of<UserSettingProvider>(context).getFiatCurrencyName(fiatCurrency: exchangeRate?.fiatCurrency ?? FiatCurrency.usd)}${estimatedValue.toStringAsFixed(defaultDisplayDigits)}",
          style: FontManager.captionSemiBold(ProtonColors.textNorm)),
      Text(
          ExchangeCalculator.getBitcoinUnitLabel(
              widget.bitcoinUnit!, accountModel.balance.toInt()),
          style: FontManager.overlineRegular(ProtonColors.textHint))
    ]);
  }

  void showOptionsInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.white,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height / 3,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
              padding: const EdgeInsets.only(
                  bottom: defaultPadding,
                  top: defaultPadding * 2,
                  left: defaultPadding,
                  right: defaultPadding),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text(
                          S.of(context).accounts,
                          style: FontManager.body2Median(ProtonColors.textNorm),
                        )),
                        const SizedBox(
                          height: 10,
                        ),
                        for (int index = 0;
                            index < widget.accounts.length;
                            index++)
                          Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: Column(children: [
                                ListTile(
                                  leading: selected == widget.accounts[index]
                                      ? Assets.images.icon.icCheckmark.svg(
                                          fit: BoxFit.fill,
                                          width: 20,
                                          height: 20,
                                        )
                                      : const SizedBox(
                                          width: 20,
                                          height: 20,
                                        ),
                                  title: Transform.translate(
                                      offset: const Offset(-8, 0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                widget.accounts[index]
                                                    .labelDecrypt,
                                                style: FontManager.body2Regular(
                                                    ProtonColors.textNorm)),
                                            getWalletAccountBalanceWidget(
                                                context,
                                                widget.accounts[index]),
                                          ])),
                                  onTap: () {
                                    setState(() {
                                      selected = widget.accounts[index];
                                      _textEditingController.text =
                                          selected.labelDecrypt;
                                      widget.valueNotifier?.value = selected;
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                                const Divider(
                                  thickness: 0.2,
                                  height: 1,
                                )
                              ])),
                      ],
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}
