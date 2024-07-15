import 'package:equatable/equatable.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.model.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';

class BuyBitcoinState extends Equatable {
  final bool isCountryLoaded;
  final bool isCurrencyLoaded;
  final bool isQuoteLoaded;
  final bool isQuoteFailed;

  /// selected
  final SelectedInfoModel selectedModel;

  /// providers
  final List<GatewayProvider> supportedProviders;

  /// country codes
  final List<String> countryCodes;

  /// country codes
  final List<String> currencyNames;

  /// quote
  final List<Quote> quotes;

  /// quote
  final Map<GatewayProvider, String> received;

  const BuyBitcoinState({
    this.selectedModel = const SelectedInfoModel(),
    this.countryCodes = const [],
    this.isCountryLoaded = false,
    this.isCurrencyLoaded = false,
    this.isQuoteLoaded = false,
    this.isQuoteFailed = false,
    this.currencyNames = const [],
    this.quotes = const [],
    this.received = const {},
    this.supportedProviders = const [GatewayProvider.ramp],
  });

  BuyBitcoinState copyWith({
    bool? isCountryLoaded,
    bool? isCurrencyLoaded,
    List<String>? countryCodes,
    List<String>? currencyNames,
    List<Quote>? quotes,
    List<GatewayProvider>? supportedProviders,
    SelectedInfoModel? selectedModel,
    Map<GatewayProvider, String>? received,
    bool? isQuoteFailed,
    bool? isQuoteLoaded,
  }) {
    return BuyBitcoinState(
      selectedModel: selectedModel ?? this.selectedModel,
      isCountryLoaded: isCountryLoaded ?? this.isCountryLoaded,
      countryCodes: countryCodes ?? this.countryCodes,
      currencyNames: currencyNames ?? this.currencyNames,
      quotes: quotes ?? this.quotes,
      supportedProviders: supportedProviders ?? this.supportedProviders,
      isCurrencyLoaded: isCurrencyLoaded ?? this.isCurrencyLoaded,
      isQuoteLoaded: isQuoteLoaded ?? this.isQuoteLoaded,
      isQuoteFailed: isQuoteFailed ?? this.isQuoteFailed,
      received: received ?? this.received,
    );
  }

  @override
  List<Object> get props => [
        isCountryLoaded,
        isCurrencyLoaded,
        isQuoteLoaded,
        BuyBitcoinState,
        countryCodes,
        currencyNames,
        selectedModel,
        quotes,
        supportedProviders,
        received,
      ];
}
