import 'package:wallet/rust/proton_api/payment_gateway.dart';

class SelectedInfoModel {
  final GatewayProvider provider;
  final GatewayProviderInfo providerInfo;
  final ApiCountry country;
  final ApiCountryFiatCurrency fiatCurrency;
  final PaymentMethod paymentMethod;
  final String amount;
  final Quote selectedQuote;
  final String paymentGatewayFee;
  final String networkFee;

  const SelectedInfoModel({
    this.provider = GatewayProvider.ramp,
    this.providerInfo = const GatewayProviderInfo(
      name: 'Ramp',
      logo: "",
    ),
    this.country = const ApiCountry(
      code: "US",
      fiatCurrency: "USD",
      name: "United States",
    ),
    this.fiatCurrency = const ApiCountryFiatCurrency(
      name: 'United States',
      symbol: "USD",
    ),
    this.paymentMethod = PaymentMethod.applePay,
    this.amount = "100",
    this.selectedQuote = const Quote(
      bitcoinAmount: "0.001",
      fiatAmount: "100",
      fiatCurrencySymbol: "USD",
      networkFee: "10",
      paymentGatewayFee: "20",
      paymentMethod: PaymentMethod.card,
    ),
    this.paymentGatewayFee = "",
    this.networkFee = "",
  });

  SelectedInfoModel copyWith({
    GatewayProvider? provider,
    GatewayProviderInfo? providerInfo,
    ApiCountry? country,
    ApiCountryFiatCurrency? fiatCurrency,
    PaymentMethod? paymentMethod,
    String? amount,
    Quote? quote,
  }) {
    var paymentGatewayFee = "";
    var networkFee = "";
    if (quote != null) {
      networkFee = roundUpToTwoDecimalPlaces(quote.networkFee);
      paymentGatewayFee = roundUpToTwoDecimalPlaces(quote.paymentGatewayFee);
    }

    return SelectedInfoModel(
      provider: provider ?? this.provider,
      providerInfo: providerInfo ?? this.providerInfo,
      country: country ?? this.country,
      fiatCurrency: fiatCurrency ?? this.fiatCurrency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      selectedQuote: quote ?? selectedQuote,
      paymentGatewayFee: paymentGatewayFee,
      networkFee: networkFee,
    );
  }

  String roundUpToTwoDecimalPlaces(String value) {
    final double number = double.parse(value);
    final double roundedUpNumber = (number * 100).ceil() / 100;
    return "$roundedUpNumber";
  }
}

class GatewayProviderInfo {
  final String name;
  final String logo;

  const GatewayProviderInfo({
    required this.name,
    required this.logo,
  });
}

// class FiatCurrencyInfo {

/// These info comes from /api/wallet/v1/fiat-currencies
/// Since change is unlikely, there's no need to load dynamically via API.
final Map<GatewayProvider, GatewayProviderInfo> providersInfo = {
  GatewayProvider.ramp: const GatewayProviderInfo(
    name: 'Ramp',
    logo: "",
  ),
  GatewayProvider.banxa: const GatewayProviderInfo(
    name: 'Banxa',
    logo: "",
  ),
};

class BuyBitcoinProviderModel {
  GatewayProvider selected = GatewayProvider.ramp;
  GatewayProviderInfo providerInfo = providersInfo[GatewayProvider.ramp]!;
  // supported features
  List<GatewayProvider> supportedProvider = [
    GatewayProvider.ramp,
    GatewayProvider.banxa
  ];
}
