import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BuyBitcoinEvent extends Equatable {
  const BuyBitcoinEvent();
}

class LoadCountryEvent extends BuyBitcoinEvent {
  const LoadCountryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddressEvent extends BuyBitcoinEvent {
  const LoadAddressEvent();

  @override
  List<Object?> get props => [];
}

class BuyBitcoinState extends Equatable {
  final bool isAddressLoaded;
  final bool isCountryLoaded;

  const BuyBitcoinState({
    this.isAddressLoaded = false,
    this.isCountryLoaded = false,
  });

  BuyBitcoinState copyWith({bool? isAddressLoaded, bool? isCountryLoaded}) {
    return BuyBitcoinState(
      isAddressLoaded: isAddressLoaded ?? this.isAddressLoaded,
      isCountryLoaded: isCountryLoaded ?? this.isCountryLoaded,
    );
  }

  @override
  List<Object> get props => [isAddressLoaded, isCountryLoaded];
}

// class BuyBitcoinInitial extends BuyBitcoinState {
//   @override
//   List<Object?> get props => [];
// }

// class BuyBitcoinLoadingCountry extends BuyBitcoinState {
//   @override
//   List<Object?> get props => [];
// }

// class BuyBitcoinCountry extends BuyBitcoinState {
//   @override
//   List<Object?> get props => [];
// }

// class LoadingAddress extends BuyBitcoinState {
//   @override
//   List<Object?> get props => [];
// }

// class LoadedAddress extends BuyBitcoinState {
//   @override
//   List<Object?> get props => [];
// }

class BuyBitcoinBloc extends Bloc<BuyBitcoinEvent, BuyBitcoinState> {
  // final SecureStorageManager storage;
  // final SharedPreferences shared;
  // late UserInfo userInfo;
  // final ApiEnv apiEnv;

  BuyBitcoinBloc() : super(const BuyBitcoinState()) {
    on<LoadCountryEvent>((event, emit) async {
      emit(state.copyWith(isCountryLoaded: false));
      await Future.delayed(
          const Duration(seconds: 10)); // Simulate network call
      emit(state.copyWith(isCountryLoaded: true));
    });

    on<LoadAddressEvent>((event, emit) async {
      emit(state.copyWith(isAddressLoaded: false));
      await Future.delayed(const Duration(seconds: 5)); // Simulate network call
      emit(state.copyWith(isAddressLoaded: true));
    });
  }
}
