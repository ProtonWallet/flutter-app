import 'dart:async';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/managers/features/proton.recovery.bloc.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.coordinator.dart';

abstract class RecoveryViewModel extends ViewModel<RecoveryCoordinator> {
  RecoveryViewModel(super.coordinator);

  ///
  bool recoveryEnabled = false;
  void updateRecovery(bool value);
}

class RecoveryViewModelImpl extends RecoveryViewModel {
  RecoveryViewModelImpl(
    super.coordinator,
    this.protonRecoveryBloc,
    this.protonUsersApi,
  );
  final datasourceChangedStreamController =
      StreamController<RecoveryViewModel>.broadcast();

  final ProtonRecoveryBloc protonRecoveryBloc;
  final ProtonUsersClient protonUsersApi;
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    var userInfo = await protonUsersApi.getUserInfo();
    recoveryEnabled = userInfo.mnemonicStatus == 3;
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
    // get user check if recovery is enabled

    // get user recovery phrase

    protonRecoveryBloc.enableRecovery();

    // recoveryEnabled = value;
    // datasourceChangedStreamController.sinkAddSafe(this);
  }
}
