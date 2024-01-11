import 'package:sqflite/sqflite.dart';

class Migration{
  int startVersion;
  int endVersion;
  late void Function(Database db) migrate;
  Migration(this.startVersion, this.endVersion, this.migrate);
}