import 'package:wallet/managers/manager.dart';

// wallet account. could have multiple accounts in one wallet
class WalletAccountManager implements Manager {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> login(String userID) async {}
}
