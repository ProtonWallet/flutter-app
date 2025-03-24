import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/message.sign/message.sign.view.dart';
import 'package:wallet/scenes/message.sign/message.sign.viewmodel.dart';

class MessageSignCoordinator extends Coordinator {
  late ViewBase widget;
  final String address;
  final FrbAccount account;

  MessageSignCoordinator({
    required this.address,
    required this.account,
  });

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = MessageSignViewModelImpl(
      this,
      address,
      account,
    );
    widget = MessageSignView(
      viewModel,
    );
    return widget;
  }
}
