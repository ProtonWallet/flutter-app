import 'package:equatable/equatable.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.model.dart';

class BuyBitcoinState extends Equatable {
  final bool isCountryLoaded;
  final bool isCurrencyLoaded;
  final bool isQutueLoaded;

  /// selected
  final SelectedInfoModel selectedModel;

  /// country codes
  final List<String> countryCodes;

  /// country codes
  final List<String> currencyNames;

  /// quote
  final List<Quote> quotes;

  /// provider model;
  final BuyBitcoinProviderModel providerModel = BuyBitcoinProviderModel();

  BuyBitcoinState({
    this.selectedModel = const SelectedInfoModel(),
    this.countryCodes = const [],
    this.isCountryLoaded = false,
    this.isCurrencyLoaded = false,
    this.isQutueLoaded = false,
    this.currencyNames = const [],
    this.quotes = const [],
  });

  BuyBitcoinState copyWith({
    bool? isCountryLoaded,
    bool? isCurrencyLoaded,
    bool? isQutueLoaded,
    List<String>? countryCodes,
    List<String>? currencyNames,
    List<Quote>? quotes,
    SelectedInfoModel? selectedModel,
  }) {
    return BuyBitcoinState(
      selectedModel: selectedModel ?? this.selectedModel,
      isCountryLoaded: isCountryLoaded ?? this.isCountryLoaded,
      countryCodes: countryCodes ?? this.countryCodes,
      currencyNames: currencyNames ?? this.currencyNames,
      quotes: quotes ?? this.quotes,
      isCurrencyLoaded: isCurrencyLoaded ?? this.isCurrencyLoaded,
      isQutueLoaded: isQutueLoaded ?? this.isQutueLoaded,
    );
  }

  @override
  List<Object> get props => [
        isCountryLoaded,
        isCurrencyLoaded,
        isQutueLoaded,
        BuyBitcoinState,
        countryCodes,
        currencyNames,
        selectedModel,
        quotes,
      ];
}
