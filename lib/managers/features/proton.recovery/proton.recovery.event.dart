// Define the events
import 'package:equatable/equatable.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';

abstract class ProtonRecoveryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadingRecovery extends ProtonRecoveryEvent {}

class TestRecovery extends ProtonRecoveryEvent {}

class EnableRecovery extends ProtonRecoveryEvent {
  final RecoverySteps step;
  final String password;
  final String twofa;

  EnableRecovery(
    this.step, {
    this.password = "",
    this.twofa = "",
  });
  @override
  List<Object> get props => [step];
}

class DisableRecovery extends ProtonRecoveryEvent {
  final RecoverySteps step;
  final String password;
  final String twofa;

  DisableRecovery(
    this.step, {
    this.password = "",
    this.twofa = "",
  });
  @override
  List<Object> get props => [step];
}
