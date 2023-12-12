import 'dart:async';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class ReceiveViewModel extends ViewModel {
  ReceiveViewModel(super.coordinator);

  String address = "";
}

class ReceiveViewModelImpl extends ReceiveViewModel {
  ReceiveViewModelImpl(super.coordinator);

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;
  final datasourceChangedStreamController =
      StreamController<ReceiveViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    //restore wallet
    final aliceMnemonic = await Mnemonic.fromString(
        'certain sense kiss guide crumble hint transfer crime much stereo warm coral');
    final aliceDescriptor = await _lib.createDescriptor(aliceMnemonic);
    _wallet = await _lib.restoreWallet(aliceDescriptor);
    getAddress();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  void getAddress() async {
    var addressinfo = await _lib.getAddress(_wallet);
    address = addressinfo.address;
    datasourceChangedStreamController.add(this);
  }
}
