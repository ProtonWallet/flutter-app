import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';

// import 'package:wallet/models/drift/user.keys.queries.dart';
// import 'package:wallet/models/drift/users.queries.dart';
// import 'package:wallet/rust/api/api_service/proton_users_client.dart';

class WalletUser {
  bool enabled2FA;
  bool enabledRecovery;

  ProtonUser? protonUser;

  WalletUser({
    this.enabled2FA = false,
    this.enabledRecovery = false,
  });
}

class UserDataProvider extends DataProvider {
  final AppDatabase appDatabase;
  // late List<WalletUser> users;
  late WalletUser user;

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
    user = WalletUser();
  }

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  void enabled2FA(enable) {
    user.enabled2FA = enable;
    dataUpdateController.add(DataUpdated("user update enabled2FA"));
  }

  void enabledRecovery(enable) {
    user.enabledRecovery = enable;
    dataUpdateController.add(DataUpdated("user update enabledRecovery"));
  }

  Future<ProtonUser> getUser() async {
    throw UnimplementedError('getUserData is not implemented');
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
