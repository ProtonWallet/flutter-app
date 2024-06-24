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
      add(const LoadCurrencyEvent());
      add(const GetQutoeEvent());
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

      add(SelectCurrencyEvent(defaultCountry.symbol));
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
      add(const LoadCurrencyEvent());
      add(const GetQutoeEvent());
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
      String numericAmountg = amount.replaceAll(RegExp(r'[^\d.]'), '');
      if (numericAmountg.isEmpty) {
        return;
      }
      emit(state.copyWith(
        selectedModel: state.selectedModel.copyWith(
          amount: numericAmountg,
        ),
      ));

      add(const GetQutoeEvent());
    });

    /// get qutoe event
    on<GetQutoeEvent>((event, emit) async {
      emit(state.copyWith(isQutueLoaded: false, isQutueFailed: false));
      var amount = state.selectedModel.amount.toString();
      var fiatCurrency = state.selectedModel.fiatCurrency.symbol;
      var provider = state.selectedModel.provider;
      var qutoes = await gatewayDataProvider.getQutoe(
        fiatCurrency,
        amount,
        provider,
      );

      var qutoe = qutoes[provider];
      if (qutoe == null) {
        emit(state.copyWith(
          isQutueLoaded: true,
          isQutueFailed: true,
        ));
        return;
      }
      for (var item in qutoe) {
        if (item.paymentMethod == state.selectedModel.paymentMethod) {
          emit(state.copyWith(
            isQutueLoaded: true,
            quotes: qutoe,
            selectedModel: state.selectedModel.copyWith(quote: item),
          ));
        }
      }
    });
  }
}
