import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/user.keys.queries.dart';
import 'package:wallet/models/drift/users.queries.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';

class UserDataProvider implements DataProvider {
  final AppDatabase appDatabase;

  //
  late ProtonUsersClient _protonUsersClient;

  //
  late UserQueries _userQueries;
  late UserKeysQueries _userKeysQueries;

  UserDataProvider({required this.appDatabase}) {
    _userQueries = UserQueries(appDatabase);
    _userKeysQueries = UserKeysQueries(appDatabase);
  }

  @override
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<ProtonUser> getUser() async {
    throw UnimplementedError('getUserData is not implemented');
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}
