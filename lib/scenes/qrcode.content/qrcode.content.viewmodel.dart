import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/qrcode.content/qrcode.content.coordinator.dart';

enum QRcodeType {
  bitcoinAddress,
}

abstract class QRcodeContentViewModel
    extends ViewModel<QRcodeContentCoordinator> {
  QRcodeContentViewModel(
    super.coordinator,
    this.qRcodeType,
    this.data,
  );

  final QRcodeType qRcodeType;
  final String data;
}

class QRcodeContentViewModelImpl extends QRcodeContentViewModel {
  QRcodeContentViewModelImpl(
    super.coordinator,
    super.qRcodeType,
    super.data,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}
