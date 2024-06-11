abstract class BaseDao<T> {
  Future<int> insert(T item);
  Future<T> findById(int id);
  Future<List<T>> findAll();
  Future<void> update(T item);
  Future<void> delete(int id);
  Future<void> deleteByServerID(String id);
}
