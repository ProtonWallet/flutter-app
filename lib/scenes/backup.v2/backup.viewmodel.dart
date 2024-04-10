import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/backup.v2/backup.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupBackupViewModel extends ViewModel<SetupBackupCoordinator> {
  SetupBackupViewModel(super.coordinator, this.walletID);

  List<Item> itemList = [];
  int walletID;
  String strMnemonic = "";
  void setBackup();
}

class SetupBackupViewModelImpl extends SetupBackupViewModel {
  SetupBackupViewModelImpl(super.coordinator, super.walletID);

  final datasourceChangedStreamController =
      StreamController<SetupBackupViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    strMnemonic = await WalletManager.getMnemonicWithID(walletID);
    strMnemonic.split(" ").forEachIndexed((index, element) {
      itemList.add(Item(
        title: element,
        index: index,
      ));
    });
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void setBackup() async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String serverWalletID = walletModel.serverWalletID;
    preferences.setBool("todo_hadBackup_$serverWalletID", true);
  }

  @override
  void move(NavigationIdentifier to) {}
}
