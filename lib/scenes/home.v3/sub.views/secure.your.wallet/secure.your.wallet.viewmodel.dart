import 'dart:async';

import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/secure.your.wallet/secure.your.wallet.coordinator.dart';

abstract class SecureYourWalletViewModel
    extends ViewModel<SecureYourWalletCoordinator> {
  final bool hadSetupRecovery;
  final bool showWalletRecovery;
  final bool hadSetup2FA;

  SecureYourWalletViewModel(
    super.coordinator, {
    required this.hadSetupRecovery,
    required this.showWalletRecovery,
    required this.hadSetup2FA,
  });
}

class SecureYourWalletViewModelImpl extends SecureYourWalletViewModel {
  SecureYourWalletViewModelImpl(
    super.coordinator, {
    required super.hadSetupRecovery,
    required super.showWalletRecovery,
    required super.hadSetup2FA,
  });

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
