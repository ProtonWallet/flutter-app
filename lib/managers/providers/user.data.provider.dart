import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/user.keys.queries.dart';
import 'package:wallet/models/drift/users.queries.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';

class TwoFaUpdated extends DataUpdated<bool> {
  TwoFaUpdated({required bool updatedData}) : super(updatedData);
}

class RecoveryUpdated extends DataUpdated<bool> {
  RecoveryUpdated({required bool updatedData}) : super(updatedData);
}

class ShowWalletRecoveryUpdated extends DataUpdated<bool> {
  ShowWalletRecoveryUpdated({required bool updatedData}) : super(updatedData);
}

class ProtonWalletUser {
  bool enabled2FA;
  bool enabledRecovery;

  DriftProtonUser? protonUser;

  ProtonWalletUser({
    this.enabled2FA = false,
    this.enabledRecovery = false,
  });
}

class UserDataProvider extends DataProvider {
  late ProtonWalletUser user;

  final ProtonUsersClient protonUsersClient;
  final UserQueries userQueries;
  final UserKeysQueries userKeysQueries;

  UserDataProvider(this.protonUsersClient,
      this.userQueries,
      this.userKeysQueries,) {
    user = ProtonWalletUser();
  }

  final StreamController<DataUpdated> dataUpdateController =
  StreamController<DataUpdated>();

  void enabled2FA(enable) {
    user.enabled2FA = enable;
    emitState(TwoFaUpdated(updatedData: enable));
  }

  void enabledRecovery(enable) {
    user.enabledRecovery = enable;
    emitState(RecoveryUpdated(updatedData: enable));
  }

  void enabledShowWalletRecovery(enable) {
    emitState(ShowWalletRecoveryUpdated(updatedData: enable));
  }

  Future<List<DriftUserKey>> getUserKeys(String userID) async {
    var userKeys = await userKeysQueries.getUseKeys(userID);
    if (userKeys.isNotEmpty) {
      return userKeys;
    }
    await fetchFromServer(userID);
    userKeys = await userKeysQueries.getUseKeys(userID);
    if (userKeys.isNotEmpty) {
      return userKeys;
    }
    return [];
  }

  Future<DriftProtonUser> getUser() async {
    throw UnimplementedError('getUserData is not implemented');
  }

  Future<void> fetchFromServer(String userID) async {
    final userinfo = await protonUsersClient.getUserInfo();

    if (userinfo.id != userID) {
      logger.e('User ID does not match');
      const Assert('User ID does not match');
    }

    userQueries.insertOrUpdateItem(DriftProtonUser(
        id: 0,
        userId: userinfo.id,
        name: userinfo.name ?? "",
        usedSpace: userinfo.usedSpace,
        currency: userinfo.currency,
        credit: userinfo.credit,
        createTime: userinfo.createTime,
        maxSpace: userinfo.maxSpace,
        maxUpload: userinfo.maxUpload,
        role: userinfo.role,
        private: userinfo.private,
        subscribed: userinfo.subscribed,
        services: userinfo.services,
        delinquent: userinfo.delinquent,
        organizationPrivateKey: userinfo.organizationPrivateKey,
        email: userinfo.email,
        displayName: userinfo.displayName));
    final keys = userinfo.keys;
    if (keys != null) {
      for (var key in keys) {
        userKeysQueries.insertOrUpdateItem(DriftUserKey(
          keyId: key.id,
          userId: userID,
          version: key.version,
          privateKey: key.privateKey,
          token: key.token,
          fingerprint: key.fingerprint,
          recoverySecret: key.recoverySecret,
          recoverySecretSignature: key.recoverySecretSignature,
          primary: key.primary,
        ));
      }
    }
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
