import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.event.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';
import 'package:wallet/managers/providers/gateway.data.provider.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/scenes/buy/buybitcoin.view.dart';

/// On rampe buying flow features. used in [BuyBitcoinView]
class BuyBitcoinBloc extends Bloc<BuyBitcoinEvent, BuyBitcoinState> {
  final GatewayDataProvider gatewayDataProvider;

  BuyBitcoinBloc(this.gatewayDataProvider) : super(const BuyBitcoinState()) {
    /// load country
    on<LoadCountryEvent>((event, emit) async {
      emit(state.copyWith(isCountryLoaded: false, error: ""));

      /// get country without provider
      final defaultProvider = state.selectedModel.provider;

      /// get all countries
      final countries = await gatewayDataProvider.getCountries();

      /// get supported providers
      final supportedProviders = gatewayDataProvider.supportedProviders;

      /// default country
      final selectedCountry = state.selectedModel.country;
      final defaultCountry = gatewayDataProvider.getApiCountry(
        defaultProvider,
        selectedCountry.code,
      );

      /// country loaded
      emit(state.copyWith(
        isCountryLoaded: true,
        countryCodes: countries,
        selectedModel: state.selectedModel.copyWith(country: defaultCountry),
        supportedProviders: supportedProviders,
      ));

      /// load currency
      if (!isClosed) {
        add(const LoadCurrencyEvent());
        add(const GetQuoteEvent());
      }
    });

    /// load currency
    on<LoadCurrencyEvent>((event, emit) async {
      emit(state.copyWith(isCurrencyLoaded: false, error: ""));
      //

      final selectedProvider = state.selectedModel.provider;
      final selectedCountry = state.selectedModel.country;

      final currencies = await gatewayDataProvider.getCurrencies(
        selectedProvider,
        selectedCountry.code,
      );

      final defaultCountry = gatewayDataProvider.getApiCountryFiatCurrency(
        selectedProvider,
        selectedCountry.fiatCurrency,
      );
      emit(state.copyWith(
          isCurrencyLoaded: true,
          currencyNames: currencies,
          selectedModel:
              state.selectedModel.copyWith(fiatCurrency: defaultCountry)));

      if (!isClosed) {
        add(SelectCurrencyEvent(defaultCountry.symbol));
      }
    });

    /// select country
    on<SelectCountryEvent>((event, emit) async {
      final selectedCode = event.code;
      var selectedProvider = state.selectedModel.provider;
      final apiCountry = gatewayDataProvider.getApiCountry(
        selectedProvider,
        selectedCode,
      );
      final supportedProviders = gatewayDataProvider.supportedProviders;

      if (supportedProviders.isNotEmpty &&
          !supportedProviders.contains(selectedProvider)) {
        selectedProvider = supportedProviders.first;
      }

      emit(state.copyWith(
        selectedModel: state.selectedModel.copyWith(
          country: apiCountry,
          provider: selectedProvider,
        ),
        supportedProviders: supportedProviders,
        error: "",
      ));

      /// load currency
      if (!isClosed) {
        add(const LoadCurrencyEvent());
        add(const GetQuoteEvent());
      }
    });

    /// select currency
    on<SelectCurrencyEvent>((event, emit) async {
      final fiatCurrency = event.fiatCurrency;
      final selectedProvider = state.selectedModel.provider;
      final apiCountry = gatewayDataProvider.getApiCountryFiatCurrency(
          selectedProvider, fiatCurrency);
      emit(state.copyWith(
          selectedModel: state.selectedModel.copyWith(fiatCurrency: apiCountry),
          error: ""));
    });

    /// select amount
    on<SelectAmountEvent>((event, emit) async {
      final String amount = event.amount;
      final String numericAmountg = toNumberAmount(amount);
      emit(state.copyWith(
        selectedModel: state.selectedModel.copyWith(
          amount: numericAmountg,
        ),
        error: "",
      ));
      if (!isClosed) {
        add(const GetQuoteEvent());
      }
    });

    /// Update amount
    on<UpdateAmountEvent>((event, emit) async {
      final String amount = event.amount;
      final String numericAmountg = toNumberAmount(amount);
      emit(state.copyWith(
        selectedModel: state.selectedModel.copyWith(
          amount: numericAmountg,
        ),
        error: "",
      ));
    });

    /// get quote event
    on<GetQuoteEvent>((event, emit) async {
      emit(state.copyWith(
        isQuoteLoaded: false,
        isQuoteFailed: false,
        error: "",
      ));
      final amount = state.selectedModel.amount;
      final fiatCurrency = state.selectedModel.fiatCurrency.symbol;

      var provider = state.selectedModel.provider;
      try {
        final quotes = await gatewayDataProvider.getQuotes(
          fiatCurrency,
          amount,
          state.supportedProviders,
        );

        if (quotes.isEmpty) {
          final limitString = state.selectedModel.fiatCurrency.minimumAmount;
          final double max = double.tryParse(amount) ?? 0;
          final double limit = double.tryParse(limitString ?? "") ?? 0;

          final limitAmount = limitString != null
              ? " ${state.selectedModel.fiatCurrency.minimumAmount} ${state.selectedModel.fiatCurrency.symbol}"
              : "";
          if (limit > max) {
            emit(state.copyWith(
              isQuoteLoaded: true,
              isQuoteFailed: true,
              quotes: [],
              selectedModel: state.selectedModel.copyWith(
                supportedPayments: [],
                provider: provider,
              ),
              received: {},
              error:
                  "The entered amount is below the required minimum limit: $limitAmount",
            ));
          } else {
            emit(state.copyWith(
              isQuoteLoaded: true,
              isQuoteFailed: true,
              quotes: [],
              selectedModel: state.selectedModel.copyWith(
                supportedPayments: [],
                provider: provider,
              ),
              received: {},
              error:
                  "The entered amount check failed: $amount ${state.selectedModel.fiatCurrency.symbol}",
            ));
          }
          return;
        }

        final Map<GatewayProvider, String> received = {};

        for (var entry in quotes.entries) {
          String maxReceived = "";
          for (var item in entry.value) {
            final double max = double.tryParse(maxReceived) ?? 0;
            final double current = double.tryParse(item.bitcoinAmount) ?? 0;
            if (current > max) {
              maxReceived = item.bitcoinAmount;
              provider = entry.key;
            }
          }
          received[entry.key] = maxReceived;
        }

        String findMaxAmount = "";
        for (var entry in received.entries) {
          final double currentMax = double.tryParse(findMaxAmount) ?? 0;
          final double check = double.tryParse(entry.value) ?? 0;
          if (check > currentMax) {
            findMaxAmount = entry.value;
            provider = entry.key;
          }
        }

        final defaultQuotes = quotes[provider] ?? quotes.values.first;
        var defaultQuote = defaultQuotes.first;
        var selectedPayment = defaultQuote.paymentMethod;
        final List<PaymentMethod> supportedPayments = [];
        for (var item in defaultQuotes) {
          if (item.paymentMethod == state.selectedModel.paymentMethod) {
            defaultQuote = item;
            selectedPayment = item.paymentMethod;
          }
          if (defaultTargetPlatform == TargetPlatform.android) {
            if (item.paymentMethod != PaymentMethod.applePay) {
              supportedPayments.add(item.paymentMethod);
            }
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            if (item.paymentMethod != PaymentMethod.googlePay) {
              supportedPayments.add(item.paymentMethod);
            }
          } else {
            supportedPayments.add(item.paymentMethod);
          }
        }
        emit(state.copyWith(
          isQuoteLoaded: true,
          isQuoteFailed: false,
          quotes: defaultQuotes,
          selectedModel: state.selectedModel.copyWith(
            paymentMethod: selectedPayment,
            quote: defaultQuote,
            supportedPayments: supportedPayments.toSet().toList(),
            provider: provider,
          ),
          received: received,
        ));
      } on BridgeError catch (e, stacktrace) {
        final errorMessage = parseMuonError(e) ?? parseSampleDisplayError(e);
        logger.e("Get quote error: $e, stacktrace: $stacktrace");
        emit(state.copyWith(
          isQuoteLoaded: true,
          isQuoteFailed: true,
          quotes: [],
          selectedModel: state.selectedModel.copyWith(
            supportedPayments: [],
            provider: provider,
          ),
          received: {},
          error: errorMessage,
        ));
      } catch (e) {
        emit(state.copyWith(
          isQuoteLoaded: true,
          isQuoteFailed: true,
          quotes: [],
          selectedModel: state.selectedModel.copyWith(
            supportedPayments: [],
            provider: provider,
          ),
          received: {},
          error: e.toString(),
        ));
      }
    });

    /// select provider
    on<SelectProviderEvent>((event, emit) async {
      emit(state.copyWith(isQuoteLoaded: false, isQuoteFailed: false));
      final provider = event.provider;

      final amount = state.selectedModel.amount;
      final fiatCurrency = state.selectedModel.fiatCurrency.symbol;

      final quote = await gatewayDataProvider.getCachedQuote(
        fiatCurrency,
        amount,
        provider,
      );
      if (quote == null) {
        emit(state.copyWith(
          isQuoteLoaded: true,
          isQuoteFailed: true,
        ));
        return;
      }
      var defaultQuote = quote.first;
      var selectedPayment = defaultQuote.paymentMethod;
      final List<PaymentMethod> supportedPayments = [];
      for (var item in quote) {
        if (item.paymentMethod == state.selectedModel.paymentMethod) {
          defaultQuote = item;
          selectedPayment = item.paymentMethod;
        }
        if (defaultTargetPlatform == TargetPlatform.android) {
          if (item.paymentMethod != PaymentMethod.applePay) {
            supportedPayments.add(item.paymentMethod);
          }
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          if (item.paymentMethod != PaymentMethod.googlePay) {
            supportedPayments.add(item.paymentMethod);
          }
        } else {
          supportedPayments.add(item.paymentMethod);
        }
      }

      emit(state.copyWith(
        isQuoteLoaded: true,
        quotes: quote,
        selectedModel: state.selectedModel.copyWith(
          quote: defaultQuote,
          provider: provider,
          paymentMethod: selectedPayment,
          supportedPayments: supportedPayments.toSet().toList(),
        ),
      ));
    });

    /// select payment method
    on<SelectPaymentEvent>((event, emit) async {
      final method = event.method;

      final provider = state.selectedModel.provider;
      final amount = state.selectedModel.amount;
      final fiatCurrency = state.selectedModel.fiatCurrency.symbol;
      final quote = await gatewayDataProvider.getCachedQuote(
        fiatCurrency,
        amount,
        provider,
      );
      if (quote == null) {
        return;
      }
      final selectedQuote = quote.firstWhere(
        (element) => element.paymentMethod == method,
        orElse: () => quote.first,
      );
      emit(state.copyWith(
        selectedModel: state.selectedModel.copyWith(
          paymentMethod: method,
          quote: selectedQuote,
        ),
      ));
    });

    on<CheckoutLoadingEvnet>((event, emit) async {
      emit(state.copyWith(isCheckingOut: true));
    });

    on<CheckoutFinishedEvnet>((event, emit) async {
      emit(state.copyWith(isCheckingOut: false));
    });
    on<ResetError>((event, emit) async {
      emit(state.copyWith(error: event.error));
    });
  }

  Future<String> checkout(String btcAddress) async {
    final amount = state.selectedModel.amount;
    final fiat = state.selectedModel.fiatCurrency.symbol;
    final payMethod = state.selectedModel.paymentMethod;
    final provider = state.selectedModel.provider;
    return gatewayDataProvider.checkout(
      amount,
      btcAddress,
      fiat,
      payMethod,
      provider,
    );
  }

  String toNumberAmount(String textAmount) {
    final String numericAmountg = textAmount.replaceAll(RegExp(r'[^\d.]'), '');
    if (numericAmountg.isEmpty) {
      return '0';
    }
    return numericAmountg;
  }
}
