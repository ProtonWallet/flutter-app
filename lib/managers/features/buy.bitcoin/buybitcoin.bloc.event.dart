import 'package:equatable/equatable.dart';

abstract class BuyBitcoinEvent extends Equatable {
  const BuyBitcoinEvent();
}

class LoadCountryEvent extends BuyBitcoinEvent {
  const LoadCountryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrencyEvent extends BuyBitcoinEvent {
  const LoadCurrencyEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddressEvent extends BuyBitcoinEvent {
  const LoadAddressEvent();

  @override
  List<Object?> get props => [];
}

class SelectCountryEvent extends BuyBitcoinEvent {
  final String code;
  const SelectCountryEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class SelectCurrencyEvent extends BuyBitcoinEvent {
  final String fiatCurrency;
  const SelectCurrencyEvent(this.fiatCurrency);

  @override
  List<Object?> get props => [fiatCurrency];
}

class SelectAmountEvent extends BuyBitcoinEvent {
  final String amount;
  const SelectAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class GetQuoteEvent extends BuyBitcoinEvent {
  const GetQuoteEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutEvnet extends BuyBitcoinEvent {
  const CheckoutEvnet();

  @override
  List<Object?> get props => [];
}
