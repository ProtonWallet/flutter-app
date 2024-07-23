import 'package:wallet/rust/proton_api/payment_gateway.dart';

class SelectedInfoModel {
  final GatewayProvider provider;
  final ApiCountry country;
  final ApiSimpleFiatCurrency fiatCurrency;
  final PaymentMethod paymentMethod;
  final String amount;
  final Quote selectedQuote;
  final String paymentGatewayFee;
  final String networkFee;
  final List<PaymentMethod> supportedPayments;
  final String checkOutUrl;

  const SelectedInfoModel({
    this.provider = GatewayProvider.ramp,
    this.country = const ApiCountry(
      code: "US",
      fiatCurrency: "USD",
      name: "United States",
    ),
    this.fiatCurrency = const ApiSimpleFiatCurrency(
      name: 'United States',
      symbol: "USD",
    ),
    this.paymentMethod = PaymentMethod.card,
    this.amount = "200",
    this.selectedQuote = const Quote(
      bitcoinAmount: "0.001",
      fiatAmount: "200",
      fiatCurrencySymbol: "USD",
      networkFee: "10",
      paymentGatewayFee: "20",
      paymentMethod: PaymentMethod.card,
    ),
    this.paymentGatewayFee = "",
    this.networkFee = "",
    this.supportedPayments = const [PaymentMethod.card],
    this.checkOutUrl = "",
  });

  SelectedInfoModel copyWith({
    GatewayProvider? provider,
    ApiCountry? country,
    ApiSimpleFiatCurrency? fiatCurrency,
    PaymentMethod? paymentMethod,
    String? amount,
    Quote? quote,
    List<PaymentMethod>? supportedPayments,
    String? checkOutUrl,
  }) {
    var paymentGatewayFee = "";
    var networkFee = "";
    if (quote != null) {
      networkFee = roundUpToTwoDecimalPlaces(quote.networkFee);
      paymentGatewayFee = roundUpToTwoDecimalPlaces(quote.paymentGatewayFee);
    }

    return SelectedInfoModel(
      provider: provider ?? this.provider,
      country: country ?? this.country,
      fiatCurrency: fiatCurrency ?? this.fiatCurrency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      selectedQuote: quote ?? selectedQuote,
      paymentGatewayFee: paymentGatewayFee,
      networkFee: networkFee,
      supportedPayments: supportedPayments ?? this.supportedPayments,
      checkOutUrl: checkOutUrl ?? this.checkOutUrl,
    );
  }

  String roundUpToTwoDecimalPlaces(String value) {
    final double number = double.parse(value);
    final double roundedUpNumber = (number * 100).ceil() / 100;
    return "$roundedUpNumber";
  }
}
