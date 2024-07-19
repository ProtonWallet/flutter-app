import 'dart:async';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.bloc.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.event.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.coordinator.dart';

abstract class RecoveryViewModel extends ViewModel<RecoveryCoordinator> {
  RecoveryViewModel(super.coordinator, this.protonRecoveryBloc);

  final ProtonRecoveryBloc protonRecoveryBloc;

  ///
  bool recoveryEnabled = false;

  void disableRecovery() {
    protonRecoveryBloc.add(DisableRecovery(RecoverySteps.start));
  }

  void enableRecovery() {
    protonRecoveryBloc.add(EnableRecovery(RecoverySteps.start));
  }

  void stateReset() {
    protonRecoveryBloc.add(LoadingRecovery());
  }

  void disableRecoverAuth(String pwd, String twofa) {
    protonRecoveryBloc.add(DisableRecovery(
      RecoverySteps.auth,
      password: pwd,
      twofa: twofa,
    ));
  }

  void enableRecoverAuth(String pwd, String twofa) {
    protonRecoveryBloc.add(EnableRecovery(
      RecoverySteps.auth,
      password: pwd,
      twofa: twofa,
    ));
  }
}

class RecoveryViewModelImpl extends RecoveryViewModel {
  RecoveryViewModelImpl(
    super.coordinator,
    super.protonRecoveryBloc,
    this.protonUsersApi,
  );
  final ProtonUsersClient protonUsersApi;

  @override
  Future<void> loadData() async {
    // get user recovery phrase
    stateReset();
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      default:
        break;
    }
  }
}
