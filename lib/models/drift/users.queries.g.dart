// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.queries.dart';

// ignore_for_file: type=lint
mixin _$UserQueriesMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  UserQueriesManager get managers => UserQueriesManager(this);
}

class UserQueriesManager {
  final _$UserQueriesMixin _db;
  UserQueriesManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
}
