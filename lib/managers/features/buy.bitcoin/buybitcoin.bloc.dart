import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.event.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.state.dart';
import 'package:wallet/managers/providers/gateway.data.provider.dart';

/// On rampe buying flow features
class BuyBitcoinBloc extends Bloc<BuyBitcoinEvent, BuyBitcoinState> {
  final GatewayDataProvider gatewayDataProvider;

  BuyBitcoinBloc(this.gatewayDataProvider) : super(BuyBitcoinState()) {
    /// load country
    on<LoadCountryEvent>((event, emit) async {
      emit(state.copyWith(isCountryLoaded: false));
      //
      final selectedProvider = state.selectedModel.provider;
      final countries =
          await gatewayDataProvider.getCountries(selectedProvider);

      //
      final selectedCountry = state.selectedModel.country;
      final defaultCountry = gatewayDataProvider.getApiCountry(
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
      final selectedProvider = state.selectedModel.provider;
      final apiCountry = gatewayDataProvider.getApiCountry(
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
      final fiatCurrency = event.fiatCurrency;
      final selectedProvider = state.selectedModel.provider;
      // var selectedCountry = state.selectedModel.country;
      final apiCountry = gatewayDataProvider.getApiCountryFiatCurrency(
          selectedProvider, fiatCurrency);
      emit(state.copyWith(
          selectedModel:
              state.selectedModel.copyWith(fiatCurrency: apiCountry)));
    });

    /// select amount
    on<SelectAmountEvent>((event, emit) async {
      final String amount = event.amount;
      final String numericAmountg = toNumberAmount(amount);
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
      final amount = state.selectedModel.amount;
      final fiatCurrency = state.selectedModel.fiatCurrency.symbol;
      final provider = state.selectedModel.provider;
      final quotes = await gatewayDataProvider.getQuote(
        fiatCurrency,
        amount,
        provider,
      );

      final quote = quotes[provider];
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
    final String numericAmountg = textAmount.replaceAll(RegExp(r'[^\d.]'), '');
    if (numericAmountg.isEmpty) {
      return '0';
    }
    return numericAmountg;
  }
}
