import 'package:drift/drift.dart';

// @DataClassName('ProtonContact')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get uid => text().withLength(min: 1, max: 100)();
  IntColumn get size => integer()();
  IntColumn get createTime => integer()();
  IntColumn get modifyTime => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// @DataClassName('ContactEmail')
class ContactEmails extends Table {
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get email => text().nullable()();

  @override
  Set<Column> get primaryKey => {contactId, email};
}

// @DataClassName('Label')
class Labels extends Table {
  TextColumn get id => text()();
  TextColumn get contactId => text().references(Contacts, #id)();

  @override
  Set<Column> get primaryKey => {id, contactId};
}

// @DataClassName('Card')
class Cards extends Table {
  TextColumn get contactId => text().references(Contacts, #id)();
  IntColumn get type => integer()();
  TextColumn get data => text().nullable()();
  TextColumn get signature => text().nullable()();

  @override
  Set<Column> get primaryKey => {contactId, type};
}
