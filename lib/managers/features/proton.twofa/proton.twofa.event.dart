// Define the events
import 'package:equatable/equatable.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';

abstract class ProtonTwoFaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadingTwoFa extends ProtonTwoFaEvent {}

class TestRecovery extends ProtonTwoFaEvent {}

class EnableTwoFa extends ProtonTwoFaEvent {
  final RecoverySteps step;
  final String password;
  final String twofa;

  EnableTwoFa(
    this.step, {
    this.password = "",
    this.twofa = "",
  });
  @override
  List<Object> get props => [step];
}

class DisableTwoFa extends ProtonTwoFaEvent {
  final RecoverySteps step;
  final String password;
  final String twofa;

  DisableTwoFa(
    this.step, {
    this.password = "",
    this.twofa = "",
  });
  @override
  List<Object> get props => [step];
}
