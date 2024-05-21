// Tables can mix-in common definitions if needed
import 'package:drift/drift.dart';

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
