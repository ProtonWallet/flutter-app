import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/bve.privacy/bve.privacy.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/bve.privacy/bve.privacy.viewmodel.dart';

class BvEPrivacyCoordinator extends Coordinator {
  late ViewBase widget;
  final bool isPrimaryAccount;

  BvEPrivacyCoordinator({
    required this.isPrimaryAccount,
  });

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = BvEPrivacyViewModelImpl(
      this,
      isPrimaryAccount: isPrimaryAccount,
    );
    widget = BvEPrivacyView(
      viewModel,
    );
    return widget;
  }
}
