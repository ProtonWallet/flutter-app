import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';

// import 'package:wallet/models/drift/user.keys.queries.dart';
// import 'package:wallet/models/drift/users.queries.dart';
// import 'package:wallet/rust/api/api_service/proton_users_client.dart';

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

  ProtonUser? protonUser;

  ProtonWalletUser({
    this.enabled2FA = false,
    this.enabledRecovery = false,
  });
}

class UserDataProvider extends DataProvider {
  final AppDatabase appDatabase;
  // late List<WalletUser> users;
  late ProtonWalletUser user;

  /// didn't support multi user yet

  // late ProtonUsersClient _protonUsersClient;
  // late UserQueries _userQueries;
  // late UserKeysQueries _userKeysQueries;

  UserDataProvider({
    required this.appDatabase,
  }) {
    // _userQueries = UserQueries(appDatabase);
    // _userKeysQueries = UserKeysQueries(appDatabase);
    // users = [
    //   WalletUser(),
    // ];
    user = ProtonWalletUser();
  }

  StreamController<DataUpdated> dataUpdateController =
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

  Future<ProtonUser> getUser() async {
    throw UnimplementedError('getUserData is not implemented');
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
