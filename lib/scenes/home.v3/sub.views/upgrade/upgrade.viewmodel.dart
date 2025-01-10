import 'dart:async';

import 'package:wallet/helper/external.url.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.coordinator.dart';

abstract class UpgradeViewModel extends ViewModel<UpgradeCoordinator> {
  final bool isWalletAccountExceedLimit;

  Future<void> upgrade();
  Future<void> link();

  UpgradeViewModel(
    super.coordinator, {
    required this.isWalletAccountExceedLimit,
  });
}

class UpgradeViewModelImpl extends UpgradeViewModel {
  UpgradeViewModelImpl(
    super.coordinator, {
    required super.isWalletAccountExceedLimit,
  });

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<void> upgrade() async {
    ExternalUrl.shared.launchWalletHomepage();
  }

  @override
  Future<void> link() async {
    ExternalUrl.shared.launchWalletHomepage();
  }
}
