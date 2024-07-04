abstract class BaseDao<T> {
  Future<int> insert(T item);
  Future<T> findById(int id);
  Future<T> findByServerID(String serverID);
  Future<void> update(T item);
  Future<void> delete(int id);
  Future<void> deleteByServerID(String serverID);
}
