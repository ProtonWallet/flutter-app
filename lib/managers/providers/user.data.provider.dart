import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/user.keys.queries.dart';
import 'package:wallet/models/drift/users.queries.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';

class UserDataProvider {
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

  Future<ProtonUser> getUser() async {
    throw UnimplementedError('getUserData is not implemented');
  }
}
