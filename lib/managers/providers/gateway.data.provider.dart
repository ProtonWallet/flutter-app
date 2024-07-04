import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/onramp_gateway_client.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class GatewayDataProvider extends DataProvider {
  // api client
  final OnRampGatewayClient onRampGatewayClient;

  // memory cache
  Map<GatewayProvider, List<ApiCountry>> countries = {};
  Map<GatewayProvider, List<ApiCountryFiatCurrency>> fiatCurrencies = {};
  Map<GatewayProvider, List<PaymentMethod>> paymentMethods = {};

  // find the list of available providers
  List<GatewayProvider> providers = [];

  /// constructor
  GatewayDataProvider(this.onRampGatewayClient);

  Future<List<String>> getCountries(GatewayProvider provider) async {
    // read from cache

    countries = await onRampGatewayClient.getCountries();

    //
    for (var element in countries.keys) {
      providers.add(element);
    }

    //set default country
    Set<String> uniqueCodesSet = {"US", "CA"};
    var providerCountries = countries[provider];
    if (providerCountries != null) {
      for (var country in providerCountries) {
        uniqueCodesSet.add(country.code);
      }
    }
    return uniqueCodesSet.toList();
  }

  ApiCountry getApiCountry(GatewayProvider provider, String localCode) {
    ApiCountry? apiCountry;
    var providerCountries = countries[provider];
    if (providerCountries != null) {
      for (var country in providerCountries) {
        if (country.code == localCode) {
          apiCountry = country;
        }
      }
    }
    return apiCountry ??
        const ApiCountry(
          code: "US",
          fiatCurrency: "USD",
          name: "United States",
        );
  }

  Future<List<String>> getCurrencies(
      GatewayProvider provider, String localCode) async {
    if (countries.isEmpty) {
      countries = await onRampGatewayClient.getCountries();
    }
    if (fiatCurrencies.isEmpty) {
      fiatCurrencies = await onRampGatewayClient.getFiatCurrencies();
    }
    //set default country
    Set<String> uniqueCodesSet = {};
    var providerCountries = countries[provider];
    if (providerCountries != null) {
      for (var country in providerCountries) {
        if (country.code == localCode) {
          uniqueCodesSet.add(country.fiatCurrency);
        }
      }
    }
    if (uniqueCodesSet.isEmpty) {
      uniqueCodesSet.add("USD");
    }
    return uniqueCodesSet.toList();

    // fiatCurrencies = await onRampGatewayClient.getFiatCurrencies();
    // Set<String> uniqueCodesSet = {};
    // // Iterate over the values in the map
    // for (var countryList in fiatCurrencies.values) {
    //   for (var country in countryList) {
    //     uniqueCodesSet.add(country.symbol);
    //   }
    // }
    // return uniqueCodesSet.toList();
  }

  ApiCountryFiatCurrency getApiCountryFiatCurrency(
    GatewayProvider provider,
    String fiatCurrency,
  ) {
    ApiCountryFiatCurrency? apiCountry;

    var countryFiatCurrencies = fiatCurrencies[provider];
    if (countryFiatCurrencies != null) {
      for (var country in countryFiatCurrencies) {
        if (country.symbol == fiatCurrency) {
          apiCountry = country;
        }
      }
    }

    return apiCountry ??
        ApiCountryFiatCurrency(
          name: fiatCurrency,
          symbol: fiatCurrency,
        );
  }

  Future<void> getPaymentMethods(FiatCurrency fiatCurrency) async {
    paymentMethods = await onRampGatewayClient.getPaymentMethods(
      fiatSymbol: fiatCurrency.enumToString(),
    );
  }

  Future<Map<GatewayProvider, List<Quote>>> getQuote(
      String fiatCurrency, String amount, GatewayProvider provider) async {
    var doubleAmount = double.parse(amount);
    var quote = await onRampGatewayClient.getQuotes(
        amount: doubleAmount, fiatCurrency: fiatCurrency, provider: provider);
    return quote;
  }

  Future<void> checkout() async {}

  @override
  Future<void> clear() async {}
}
