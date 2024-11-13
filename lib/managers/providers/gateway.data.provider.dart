import 'dart:io';

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
  Map<GatewayProvider, List<ApiSimpleFiatCurrency>> fiatCurrencies = {};
  Map<GatewayProvider, List<PaymentMethod>> paymentMethods = {};

  /// find the list of available providers
  List<GatewayProvider> supportedProviders = [];

  /// latest quotes
  Map<GatewayProvider, List<Quote>> quoted = {};

  /// constructor
  GatewayDataProvider(this.onRampGatewayClient);

  Future<List<String>> getCountries() async {
    if (countries.isEmpty) {
      countries = await onRampGatewayClient.getCountries();
    }

    /// update supported providers
    supportedProviders = countries.keys.toList();

    if (Platform.isAndroid) {
      supportedProviders.remove(GatewayProvider.moonPay);
    }

    final Set<String> uniqueCodesSet = {"US", "CA"};
    for (var entry in countries.entries) {
      final providerCountries = entry.value;
      for (var country in providerCountries) {
        uniqueCodesSet.add(country.code);
      }
    }
    return uniqueCodesSet.toList();
  }

  ApiCountry getApiCountry(GatewayProvider provider, String localCode) {
    ApiCountry? apiCountry;
    final Set<GatewayProvider> providers = {};
    for (final entry in countries.entries) {
      for (var country in entry.value) {
        if (country.code == localCode) {
          apiCountry = country;
          providers.add(entry.key);
        }
      }
    }

    if (providers.isNotEmpty) {
      supportedProviders = providers.toList();
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
    final Set<String> uniqueCodesSet = {};
    final providerCountries = countries[provider];
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
  }

  ApiSimpleFiatCurrency getApiCountryFiatCurrency(
    GatewayProvider provider,
    String fiatCurrency,
  ) {
    ApiSimpleFiatCurrency? apiCountry;

    final countryFiatCurrencies = fiatCurrencies[provider];
    if (countryFiatCurrencies != null) {
      for (var country in countryFiatCurrencies) {
        if (country.symbol == fiatCurrency) {
          apiCountry = country;
        }
      }
    }

    return apiCountry ??
        ApiSimpleFiatCurrency(
          name: fiatCurrency,
          symbol: fiatCurrency,
        );
  }

  Future<void> getPaymentMethods(FiatCurrency fiatCurrency) async {
    paymentMethods = await onRampGatewayClient.getPaymentMethods(
      fiatSymbol: fiatCurrency.enumToString(),
    );
  }

  Future<Map<GatewayProvider, List<Quote>>> getQuotes(
    String fiatCurrency,
    String amount,
    List<GatewayProvider> providers,
  ) async {
    final doubleAmount = double.parse(amount);

    final Map<GatewayProvider, List<Quote>> newQuoted = {};
    for (var item in providers) {
      final quote = await onRampGatewayClient.getQuotes(
        amount: doubleAmount,
        fiatCurrency: fiatCurrency,
        provider: item,
      );
      if (quote.isNotEmpty) {
        for (var entry in quote.entries) {
          if (entry.value.isNotEmpty) {
            newQuoted[entry.key] = entry.value;
          }
        }
      }
    }
    if (newQuoted.isNotEmpty) {
      quoted = newQuoted;
    } else {
      quoted = {};
    }

    return quoted;
  }

  Future<List<Quote>?> getCachedQuote(
    String fiatCurrency,
    String amount,
    GatewayProvider provider,
  ) async {
    final quotes = quoted[provider];
    if (quotes == null) {
      return null;
    }
    // TODO(fix): get the quote for the selected payment method and amount
    // final doubleAmount = double.parse(amount);
    // final quote = await onRampGatewayClient.getQuotes(
    //   amount: doubleAmount,
    //   fiatCurrency: fiatCurrency,
    //   provider: provider,
    // );
    // if (quote.isNotEmpty) {
    //   for (var entry in quote.entries) {
    //     quoted[entry.key] = entry.value;
    //   }
    // }
    return quotes;
  }

  Future<String> checkout(
    String amount,
    String btcAddress,
    String fiatCurrency,
    PaymentMethod payMethod,
    GatewayProvider provider,
  ) async {
    final url = await onRampGatewayClient.createOnRampCheckout(
      amount: amount,
      btcAddress: btcAddress,
      fiatCurrency: fiatCurrency,
      paymentMethod: payMethod,
      provider: provider,
    );

    return url;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> reload() async {}
}
