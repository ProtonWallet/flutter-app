import 'dart:convert';

import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/crypto/wallet_key_helper.dart';

/// Define the Bloc
class WalletNameBloc {
  final WalletKeysProvider walletKeysProvider;
  final WalletClient walletClient;
  final AccountDao accountDao;

  /// initialize the bloc with the initial state
  WalletNameBloc(
    this.walletKeysProvider,
    this.walletClient,
    this.accountDao,
  );

  ///### None block functions
  Future<void> updateWalletName(WalletModel walletModel, String newName) async {
    final walletID = walletModel.walletID;
    final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
      walletID,
    );

    final encryptedName = FrbWalletKeyHelper.encrypt(
      base64SecureKey: unlockedWalletKey.toBase64(),
      plaintext: newName,
    );

    await walletClient.updateWalletName(
      walletId: walletID,
      newName: encryptedName,
    );
  }

  Future<void> updateAccountLabel(
    WalletModel walletModel,
    AccountModel accountModel,
    String newName,
  ) async {
    final walletID = walletModel.walletID;
    final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
      walletID,
    );

    final newLabel = FrbWalletKeyHelper.decrypt(
      base64SecureKey: unlockedWalletKey.toBase64(),
      encryptText: newName,
    );

    final walletAccount = await walletClient.updateWalletAccountLabel(
      walletId: walletID,
      walletAccountId: accountModel.accountID,
      newLabel: newLabel,
    );

    accountModel.label = base64Decode(walletAccount.label);
    accountModel.labelDecrypt = newName;
    await accountDao.update(accountModel);
  }
}
