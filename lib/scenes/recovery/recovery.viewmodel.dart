import 'dart:async';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.bloc.dart';
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
  void updateRecovery(bool value);
  void stateReset();

  void disableRecover(String pwd, String twofa);
  void enableRecover(String pwd, String twofa);
}

class RecoveryViewModelImpl extends RecoveryViewModel {
  RecoveryViewModelImpl(
    super.coordinator,
    super.protonRecoveryBloc,
    this.protonUsersApi,
  );
  final datasourceChangedStreamController =
      StreamController<RecoveryViewModel>.broadcast();
  final ProtonUsersClient protonUsersApi;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    // get user recovery phrase
    stateReset();

    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      default:
        break;
    }
  }

  @override
  void updateRecovery(bool value) {
    // get user recovery phrase
    if (!value) {
      protonRecoveryBloc.add(DisableRecovery(RecoverySteps.start));
    } else {
      protonRecoveryBloc.add(EnableRecovery(RecoverySteps.start));
    }
  }

  @override
  void stateReset() {
    protonRecoveryBloc.add(LoadingRecovery());
  }

  @override
  void disableRecover(String pwd, String twofa) {
    protonRecoveryBloc.add(DisableRecovery(
      RecoverySteps.auth,
      password: pwd,
      twofa: twofa,
    ));
  }

  @override
  void enableRecover(String pwd, String twofa) {
    protonRecoveryBloc.add(EnableRecovery(
      RecoverySteps.auth,
      password: pwd,
      twofa: twofa,
    ));
  }
}