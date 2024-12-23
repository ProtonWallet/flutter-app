import 'package:equatable/equatable.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';

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

class UpdateAmountEvent extends BuyBitcoinEvent {
  final String amount;
  const UpdateAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SelectProviderEvent extends BuyBitcoinEvent {
  final GatewayProvider provider;
  const SelectProviderEvent(this.provider);

  @override
  List<Object?> get props => [provider];
}

class SelectPaymentEvent extends BuyBitcoinEvent {
  final PaymentMethod method;
  const SelectPaymentEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class GetQuoteEvent extends BuyBitcoinEvent {
  const GetQuoteEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutEvnet extends BuyBitcoinEvent {
  final String btcAddress;

  const CheckoutEvnet(this.btcAddress);

  @override
  List<Object?> get props => [btcAddress];
}

class CheckoutLoadingEvnet extends BuyBitcoinEvent {
  @override
  List<Object?> get props => [];
}

class CheckoutFinishedEvnet extends BuyBitcoinEvent {
  @override
  List<Object?> get props => [];
}

class ResetError extends BuyBitcoinEvent {
  final String error;

  const ResetError(this.error);
  @override
  List<Object?> get props => [error];
}
