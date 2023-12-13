import 'dart:async';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/local_notification.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(super.coordinator);

  int selectedPage = 0;

  void updateSelected(int index);
  void updateSats(String sats);
  Future<void> syncWallet();

  String sats = '0';

  bool isSyncing = false;
  void udpateSyncStatus(bool syncing);
  int unconfirmed = 0;
  int confirmed = 0;

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
  Blockchain? blockchain;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
  }

  @override
  Future<void> loadData() async {
    //restore wallet  this will need to be in global initialisation
    final aliceMnemonic = await Mnemonic.fromString(
        'certain sense kiss guide crumble hint transfer crime much stereo warm coral');
    final aliceDescriptor = await _lib.createDescriptor(aliceMnemonic);
    _wallet = await _lib.restoreWallet(aliceDescriptor);
    blockchain ??= await _lib.initializeBlockchain(false);
    _wallet.getBalance().then((value) => {
          logger.i('balance: ${value.total}'),
          sats = value.total.toString(),
          datasourceChangedStreamController.sink.add(this)
        });
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
  void updateSats(String sats) {
    sats = sats;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> syncWallet() async {
    udpateSyncStatus(true);

    await _lib.sync(blockchain!, _wallet);
    var balance = await _wallet.getBalance();
    logger.i('balance: ${balance.total}');
    await updateBalance();
    udpateSyncStatus(false);
    // Use it later
    // LocalNotification.show(
    //     LocalNotification.SYNC_WALLET,
    //     "Local Notification",
    //     "Sync wallet success!\nbalance: ${balance.total}"
    // );
  }

  Future<void> updateBalance() async {
    var balance = await _wallet.getBalance();
    logger.i('balance: ${balance.total}');

    var unconfirmedList = await _lib.getUnConfirmedTransactions(_wallet);
    unconfirmed = unconfirmedList.length;

    var confirmedList = await _lib.getConfirmedTransactions(_wallet);
    confirmed = confirmedList.length;
    udpateSyncStatus(false);
  }

  @override
  void udpateSyncStatus(bool syncing) {
    isSyncing = syncing;
    datasourceChangedStreamController.sink.add(this);
  }
}
