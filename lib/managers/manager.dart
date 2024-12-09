abstract class Manager {
  Future<void> init();
  Future<void> login(String userID);
  Future<void> reload();
  Future<void> dispose();
  Future<void> logout();
  Priority getPriority();
}

enum Priority {
  level1,
  level2,
  level3,
  level4,
  level5,
}
