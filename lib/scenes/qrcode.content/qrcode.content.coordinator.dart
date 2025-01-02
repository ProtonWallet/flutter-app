import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/qrcode.content/qrcode.content.view.dart';
import 'package:wallet/scenes/qrcode.content/qrcode.content.viewmodel.dart';

class QRcodeContentCoordinator extends Coordinator {
  late ViewBase widget;
  final QRcodeType qRcodeType;
  final String data;

  QRcodeContentCoordinator(
    this.qRcodeType,
    this.data,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = QRcodeContentViewModelImpl(
      this,
      qRcodeType,
      data,
    );
    widget = QRcodeContentView(
      viewModel,
    );
    return widget;
  }
}
