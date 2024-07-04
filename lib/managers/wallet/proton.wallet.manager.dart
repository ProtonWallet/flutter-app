import 'package:wallet/managers/manager.dart';

class ProtonWalletManager implements Manager {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> login(String userID) async {}

  @override
  Future<void> logout() async {}

  void destroy() {}
}
