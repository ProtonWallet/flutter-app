abstract class Manager {
  Future<void> init();
  Future<void> login(String userID);
  Future<void> dispose();
  Future<void> logout();
}
