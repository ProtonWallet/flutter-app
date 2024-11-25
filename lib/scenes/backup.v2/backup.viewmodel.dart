import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupBackupViewModel extends ViewModel<SetupBackupCoordinator> {
  SetupBackupViewModel(super.coordinator, this.walletID);

  final String walletID;

  List<Item> itemList = [];
  String strMnemonic = "";
  bool inIntroduce = true;

  void setBackup();

  void setIntroduce({required bool introduce});
}

class SetupBackupViewModelImpl extends SetupBackupViewModel {
  final WalletManager walletManager;
  final WalletsDataProvider walletsDataProvider;
  final UserDataProvider userDataProvider;
  final String userID;

  SetupBackupViewModelImpl(
    super.coordinator,
    super.walletID,
    this.walletsDataProvider,
    this.userDataProvider,
    this.userID,
    this.walletManager,
  );

  @override
  Future<void> loadData() async {
    strMnemonic = await walletManager.getMnemonicWithID(walletID);
    strMnemonic.split(" ").forEachIndexed((index, element) {
      itemList.add(Item(
        title: element,
        index: index,
      ));
    });
    sinkAddSafe();
  }

  @override
  Future<void> setBackup() async {
    final WalletModel walletModel =
        await DBHelper.walletDao!.findByServerID(walletID);
    walletModel.showWalletRecovery = 0;
    walletsDataProvider.disableShowWalletRecovery(walletModel.walletID);
    walletsDataProvider.insertOrUpdateWallet(
      userID: userID,
      name: walletModel.name,
      encryptedMnemonic: "",
      passphrase: walletModel.passphrase,
      imported: walletModel.imported,
      priority: walletModel.priority,
      status: walletModel.status,
      type: walletModel.type,
      walletID: walletModel.walletID,
      publickey: walletModel.publicKey.base64encode(),
      fingerprint: walletModel.fingerprint ?? "",
      showWalletRecovery: walletModel.showWalletRecovery,
      migrationRequired: walletModel.migrationRequired,
      legacy: walletModel.legacy,
    );
    userDataProvider.enabledShowWalletRecovery(false);
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void setIntroduce({required bool introduce}) {
    inIntroduce = introduce;
    sinkAddSafe();
  }
}
