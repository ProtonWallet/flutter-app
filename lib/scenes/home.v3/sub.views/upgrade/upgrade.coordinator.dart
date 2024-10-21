import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.viewmodel.dart';

class UpgradeCoordinator extends Coordinator {
  late ViewBase widget;
  final bool isWalletAccountExceedLimit;

  UpgradeCoordinator({
    required this.isWalletAccountExceedLimit,
  });

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = UpgradeViewModelImpl(
      this,
      isWalletAccountExceedLimit: isWalletAccountExceedLimit,
    );
    widget = UpgradeView(
      viewModel,
    );
    return widget;
  }
}
