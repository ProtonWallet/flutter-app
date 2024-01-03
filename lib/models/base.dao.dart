import 'package:sqflite/sqflite.dart';

abstract class BaseDao<T> {
  final Database db;
  final String tableName;

  BaseDao(this.db, this.tableName);
  Future<int> insert(T item);
  Future<T> findById(int id);
  Future<List<T>> findAll();
  Future<void> update(T item);
  Future<void> delete(int id);
  Future<void> initTable();
}