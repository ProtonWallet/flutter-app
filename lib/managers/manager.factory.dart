import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.dart';

class ManagerFactory {
  static final ManagerFactory _instance = ManagerFactory._internal();
  factory ManagerFactory() => _instance;
  ManagerFactory._internal();

  final Map<Type, Manager> _managers = {};

  void register<T extends Manager>(T manager) {
    if (_managers.containsKey(T)) {
      logger.d('Manager of type $T is already registered.');
      return;
    }
    _managers[T] = manager;
  }

  T get<T extends Manager>() {
    final manager = _managers[T];
    if (manager == null) {
      throw Exception('Manager of type $T is not registered.');
    }
    return manager as T;
  }

  void unregister<T extends Manager>() {
    if (!_managers.containsKey(T)) {
      logger.d('Manager of type $T is not registered.');
      return;
    }
    _managers.remove(T);
  }

  Future<void> init() async {
    for (var entry in _managers.entries) {
      await entry.value.init();
    }
  }

  Future<void> dispose() async {
    for (var entry in _managers.entries) {
      await entry.value.dispose();
    }
    _managers.clear();
  }

  Future<void> login(String userID) async {
    for (var entry in _managers.entries) {
      await entry.value.login(userID);
    }
  }

  Future<void> logout() async {
    for (var entry in _managers.entries) {
      await entry.value.logout();
    }
  }
}
