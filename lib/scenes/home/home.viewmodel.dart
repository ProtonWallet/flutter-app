import 'dart:async';

import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(super.coordinator);

  int selectedPage = 0;
  String mnemonicString = 'No Wallet';

  void updateSelected(int index);
  void updateMnemonic(String mnemonic);
  void incrementCounter();
  Future<void> updateStringValue();

  String sats = '0';

  @override
  bool get keepAlive => true;
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
  }

  @override
  Future<void> loadData() async {
    //restore wallet
    final aliceMnemonic = await Mnemonic.fromString(
        'certain sense kiss guide crumble hint transfer crime much stereo warm coral');
    final aliceDescriptor = await _lib.createDescriptor(aliceMnemonic);
    _wallet = await _lib.restoreWallet(aliceDescriptor);

    var ballance = await _wallet.getBalance();

    sats = ballance.total.toString();

    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void updateMnemonic(String mnemonic) {
    mnemonicString = mnemonic;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void incrementCounter() {}

  @override
  Future<void> updateStringValue() async {
    var mnemonic = await Mnemonic.create(WordCount.Words12);
    logger.d(mnemonic.asString());
    updateMnemonic(mnemonic.asString());
  }
}
