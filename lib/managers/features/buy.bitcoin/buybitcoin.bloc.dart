import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/managers/providers/gateway.data.provider.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.event.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';

/// On rampe buying flow features
class BuyBitcoinBloc extends Bloc<BuyBitcoinEvent, BuyBitcoinState> {
  final GatewayDataProvider gatewayDataProvider;

  BuyBitcoinBloc(this.gatewayDataProvider) : super(BuyBitcoinState()) {
    /// load country
    on<LoadCountryEvent>((event, emit) async {
      emit(state.copyWith(isCountryLoaded: false));
      //
      var selectedProvider = state.selectedModel.provider;
      var countries = await gatewayDataProvider.getCountries(selectedProvider);

      //
      var selectedCountry = state.selectedModel.country;
      var defaultCountry = gatewayDataProvider.getApiCountry(
        selectedProvider,
        selectedCountry.code,
      );

      /// country loaded
      emit(state.copyWith(
        isCountryLoaded: true,
        countryCodes: countries,
        selectedModel: state.selectedModel.copyWith(country: defaultCountry),
      ));

      /// load currency
      if (!isClosed) {
        add(const LoadCurrencyEvent());
        add(const GetQuoteEvent());
      }
    });

    /// load currency
    on<LoadCurrencyEvent>((event, emit) async {
      emit(state.copyWith(isCurrencyLoaded: false));
      //

      var selectedProvider = state.selectedModel.provider;
      var selectedCountry = state.selectedModel.country;

      var currencies = await gatewayDataProvider.getCurrencies(
        selectedProvider,
        selectedCountry.code,
      );

      var defaultCountry = gatewayDataProvider.getApiCountryFiatCurrency(
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
      var selectedCode = event.code;
      var selectedProvider = state.selectedModel.provider;
      var apiCountry = gatewayDataProvider.getApiCountry(
        selectedProvider,
        selectedCode,
      );
      emit(state.copyWith(
          selectedModel: state.selectedModel.copyWith(country: apiCountry)));

      /// load currency
      if (!isClosed) {
        add(const LoadCurrencyEvent());
        add(const GetQuoteEvent());
      }
    });

    /// select currency
    on<SelectCurrencyEvent>((event, emit) async {
      var fiatCurrency = event.fiatCurrency;
      var selectedProvider = state.selectedModel.provider;
      // var selectedCountry = state.selectedModel.country;
      var apiCountry = gatewayDataProvider.getApiCountryFiatCurrency(
          selectedProvider, fiatCurrency);
      emit(state.copyWith(
          selectedModel:
              state.selectedModel.copyWith(fiatCurrency: apiCountry)));
    });

    /// select amount
    on<SelectAmountEvent>((event, emit) async {
      String amount = event.amount;
      String numericAmountg = toNumberAmount(amount);
      emit(state.copyWith(
        selectedModel: state.selectedModel.copyWith(
          amount: numericAmountg,
        ),
      ));
      if (!isClosed) {
        add(const GetQuoteEvent());
      }
    });

    /// get quote event
    on<GetQuoteEvent>((event, emit) async {
      emit(state.copyWith(isQuoteLoaded: false, isQuoteFailed: false));
      var amount = state.selectedModel.amount.toString();
      var fiatCurrency = state.selectedModel.fiatCurrency.symbol;
      var provider = state.selectedModel.provider;
      var quotes = await gatewayDataProvider.getQuote(
        fiatCurrency,
        amount,
        provider,
      );

      var quote = quotes[provider];
      if (quote == null) {
        emit(state.copyWith(
          isQuoteLoaded: true,
          isQuoteFailed: true,
        ));
        return;
      }
      for (var item in quote) {
        if (item.paymentMethod == state.selectedModel.paymentMethod) {
          emit(state.copyWith(
            isQuoteLoaded: true,
            quotes: quote,
            selectedModel: state.selectedModel.copyWith(quote: item),
          ));
        }
      }
    });
  }

  String toNumberAmount(String textAmount) {
    String numericAmountg = textAmount.replaceAll(RegExp(r'[^\d.]'), '');
    if (numericAmountg.isEmpty) {
      return '0';
    }
    return numericAmountg;
  }
}
