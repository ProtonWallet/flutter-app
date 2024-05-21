// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _usedSpaceMeta =
      const VerificationMeta('usedSpace');
  @override
  late final GeneratedColumn<int> usedSpace = GeneratedColumn<int>(
      'used_space', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<int> credit = GeneratedColumn<int>(
      'credit', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createTimeMeta =
      const VerificationMeta('createTime');
  @override
  late final GeneratedColumn<int> createTime = GeneratedColumn<int>(
      'create_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _maxSpaceMeta =
      const VerificationMeta('maxSpace');
  @override
  late final GeneratedColumn<int> maxSpace = GeneratedColumn<int>(
      'max_space', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _maxUploadMeta =
      const VerificationMeta('maxUpload');
  @override
  late final GeneratedColumn<int> maxUpload = GeneratedColumn<int>(
      'max_upload', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
      'role', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _privateMeta =
      const VerificationMeta('private');
  @override
  late final GeneratedColumn<bool> private = GeneratedColumn<bool>(
      'private', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("private" IN (0, 1))'));
  static const VerificationMeta _subscribedMeta =
      const VerificationMeta('subscribed');
  @override
  late final GeneratedColumn<bool> subscribed = GeneratedColumn<bool>(
      'subscribed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("subscribed" IN (0, 1))'));
  static const VerificationMeta _servicesMeta =
      const VerificationMeta('services');
  @override
  late final GeneratedColumn<bool> services = GeneratedColumn<bool>(
      'services', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("services" IN (0, 1))'));
  static const VerificationMeta _delinquentMeta =
      const VerificationMeta('delinquent');
  @override
  late final GeneratedColumn<bool> delinquent = GeneratedColumn<bool>(
      'delinquent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("delinquent" IN (0, 1))'));
  static const VerificationMeta _organizationPrivateKeyMeta =
      const VerificationMeta('organizationPrivateKey');
  @override
  late final GeneratedColumn<String> organizationPrivateKey =
      GeneratedColumn<String>('organization_private_key', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        usedSpace,
        currency,
        credit,
        createTime,
        maxSpace,
        maxUpload,
        role,
        private,
        subscribed,
        services,
        delinquent,
        organizationPrivateKey,
        email,
        displayName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_table';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('used_space')) {
      context.handle(_usedSpaceMeta,
          usedSpace.isAcceptableOrUnknown(data['used_space']!, _usedSpaceMeta));
    } else if (isInserting) {
      context.missing(_usedSpaceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('credit')) {
      context.handle(_creditMeta,
          credit.isAcceptableOrUnknown(data['credit']!, _creditMeta));
    } else if (isInserting) {
      context.missing(_creditMeta);
    }
    if (data.containsKey('create_time')) {
      context.handle(
          _createTimeMeta,
          createTime.isAcceptableOrUnknown(
              data['create_time']!, _createTimeMeta));
    } else if (isInserting) {
      context.missing(_createTimeMeta);
    }
    if (data.containsKey('max_space')) {
      context.handle(_maxSpaceMeta,
          maxSpace.isAcceptableOrUnknown(data['max_space']!, _maxSpaceMeta));
    } else if (isInserting) {
      context.missing(_maxSpaceMeta);
    }
    if (data.containsKey('max_upload')) {
      context.handle(_maxUploadMeta,
          maxUpload.isAcceptableOrUnknown(data['max_upload']!, _maxUploadMeta));
    } else if (isInserting) {
      context.missing(_maxUploadMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('private')) {
      context.handle(_privateMeta,
          private.isAcceptableOrUnknown(data['private']!, _privateMeta));
    } else if (isInserting) {
      context.missing(_privateMeta);
    }
    if (data.containsKey('subscribed')) {
      context.handle(
          _subscribedMeta,
          subscribed.isAcceptableOrUnknown(
              data['subscribed']!, _subscribedMeta));
    } else if (isInserting) {
      context.missing(_subscribedMeta);
    }
    if (data.containsKey('services')) {
      context.handle(_servicesMeta,
          services.isAcceptableOrUnknown(data['services']!, _servicesMeta));
    } else if (isInserting) {
      context.missing(_servicesMeta);
    }
    if (data.containsKey('delinquent')) {
      context.handle(
          _delinquentMeta,
          delinquent.isAcceptableOrUnknown(
              data['delinquent']!, _delinquentMeta));
    } else if (isInserting) {
      context.missing(_delinquentMeta);
    }
    if (data.containsKey('organization_private_key')) {
      context.handle(
          _organizationPrivateKeyMeta,
          organizationPrivateKey.isAcceptableOrUnknown(
              data['organization_private_key']!, _organizationPrivateKeyMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      usedSpace: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}used_space'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      credit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credit'])!,
      createTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}create_time'])!,
      maxSpace: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_space'])!,
      maxUpload: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_upload'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role'])!,
      private: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}private'])!,
      subscribed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}subscribed'])!,
      services: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}services'])!,
      delinquent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}delinquent'])!,
      organizationPrivateKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}organization_private_key']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String userId;
  final String name;
  final int usedSpace;
  final String currency;
  final int credit;
  final int createTime;
  final int maxSpace;
  final int maxUpload;
  final int role;
  final bool private;
  final bool subscribed;
  final bool services;
  final bool delinquent;
  final String? organizationPrivateKey;
  final String? email;
  final String? displayName;
  const User(
      {required this.id,
      required this.userId,
      required this.name,
      required this.usedSpace,
      required this.currency,
      required this.credit,
      required this.createTime,
      required this.maxSpace,
      required this.maxUpload,
      required this.role,
      required this.private,
      required this.subscribed,
      required this.services,
      required this.delinquent,
      this.organizationPrivateKey,
      this.email,
      this.displayName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['used_space'] = Variable<int>(usedSpace);
    map['currency'] = Variable<String>(currency);
    map['credit'] = Variable<int>(credit);
    map['create_time'] = Variable<int>(createTime);
    map['max_space'] = Variable<int>(maxSpace);
    map['max_upload'] = Variable<int>(maxUpload);
    map['role'] = Variable<int>(role);
    map['private'] = Variable<bool>(private);
    map['subscribed'] = Variable<bool>(subscribed);
    map['services'] = Variable<bool>(services);
    map['delinquent'] = Variable<bool>(delinquent);
    if (!nullToAbsent || organizationPrivateKey != null) {
      map['organization_private_key'] =
          Variable<String>(organizationPrivateKey);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      usedSpace: Value(usedSpace),
      currency: Value(currency),
      credit: Value(credit),
      createTime: Value(createTime),
      maxSpace: Value(maxSpace),
      maxUpload: Value(maxUpload),
      role: Value(role),
      private: Value(private),
      subscribed: Value(subscribed),
      services: Value(services),
      delinquent: Value(delinquent),
      organizationPrivateKey: organizationPrivateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(organizationPrivateKey),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      usedSpace: serializer.fromJson<int>(json['usedSpace']),
      currency: serializer.fromJson<String>(json['currency']),
      credit: serializer.fromJson<int>(json['credit']),
      createTime: serializer.fromJson<int>(json['createTime']),
      maxSpace: serializer.fromJson<int>(json['maxSpace']),
      maxUpload: serializer.fromJson<int>(json['maxUpload']),
      role: serializer.fromJson<int>(json['role']),
      private: serializer.fromJson<bool>(json['private']),
      subscribed: serializer.fromJson<bool>(json['subscribed']),
      services: serializer.fromJson<bool>(json['services']),
      delinquent: serializer.fromJson<bool>(json['delinquent']),
      organizationPrivateKey:
          serializer.fromJson<String?>(json['organizationPrivateKey']),
      email: serializer.fromJson<String?>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'usedSpace': serializer.toJson<int>(usedSpace),
      'currency': serializer.toJson<String>(currency),
      'credit': serializer.toJson<int>(credit),
      'createTime': serializer.toJson<int>(createTime),
      'maxSpace': serializer.toJson<int>(maxSpace),
      'maxUpload': serializer.toJson<int>(maxUpload),
      'role': serializer.toJson<int>(role),
      'private': serializer.toJson<bool>(private),
      'subscribed': serializer.toJson<bool>(subscribed),
      'services': serializer.toJson<bool>(services),
      'delinquent': serializer.toJson<bool>(delinquent),
      'organizationPrivateKey':
          serializer.toJson<String?>(organizationPrivateKey),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String?>(displayName),
    };
  }

  User copyWith(
          {int? id,
          String? userId,
          String? name,
          int? usedSpace,
          String? currency,
          int? credit,
          int? createTime,
          int? maxSpace,
          int? maxUpload,
          int? role,
          bool? private,
          bool? subscribed,
          bool? services,
          bool? delinquent,
          Value<String?> organizationPrivateKey = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> displayName = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        usedSpace: usedSpace ?? this.usedSpace,
        currency: currency ?? this.currency,
        credit: credit ?? this.credit,
        createTime: createTime ?? this.createTime,
        maxSpace: maxSpace ?? this.maxSpace,
        maxUpload: maxUpload ?? this.maxUpload,
        role: role ?? this.role,
        private: private ?? this.private,
        subscribed: subscribed ?? this.subscribed,
        services: services ?? this.services,
        delinquent: delinquent ?? this.delinquent,
        organizationPrivateKey: organizationPrivateKey.present
            ? organizationPrivateKey.value
            : this.organizationPrivateKey,
        email: email.present ? email.value : this.email,
        displayName: displayName.present ? displayName.value : this.displayName,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('usedSpace: $usedSpace, ')
          ..write('currency: $currency, ')
          ..write('credit: $credit, ')
          ..write('createTime: $createTime, ')
          ..write('maxSpace: $maxSpace, ')
          ..write('maxUpload: $maxUpload, ')
          ..write('role: $role, ')
          ..write('private: $private, ')
          ..write('subscribed: $subscribed, ')
          ..write('services: $services, ')
          ..write('delinquent: $delinquent, ')
          ..write('organizationPrivateKey: $organizationPrivateKey, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      name,
      usedSpace,
      currency,
      credit,
      createTime,
      maxSpace,
      maxUpload,
      role,
      private,
      subscribed,
      services,
      delinquent,
      organizationPrivateKey,
      email,
      displayName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.usedSpace == this.usedSpace &&
          other.currency == this.currency &&
          other.credit == this.credit &&
          other.createTime == this.createTime &&
          other.maxSpace == this.maxSpace &&
          other.maxUpload == this.maxUpload &&
          other.role == this.role &&
          other.private == this.private &&
          other.subscribed == this.subscribed &&
          other.services == this.services &&
          other.delinquent == this.delinquent &&
          other.organizationPrivateKey == this.organizationPrivateKey &&
          other.email == this.email &&
          other.displayName == this.displayName);
}

class UsersTableCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<int> usedSpace;
  final Value<String> currency;
  final Value<int> credit;
  final Value<int> createTime;
  final Value<int> maxSpace;
  final Value<int> maxUpload;
  final Value<int> role;
  final Value<bool> private;
  final Value<bool> subscribed;
  final Value<bool> services;
  final Value<bool> delinquent;
  final Value<String?> organizationPrivateKey;
  final Value<String?> email;
  final Value<String?> displayName;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.usedSpace = const Value.absent(),
    this.currency = const Value.absent(),
    this.credit = const Value.absent(),
    this.createTime = const Value.absent(),
    this.maxSpace = const Value.absent(),
    this.maxUpload = const Value.absent(),
    this.role = const Value.absent(),
    this.private = const Value.absent(),
    this.subscribed = const Value.absent(),
    this.services = const Value.absent(),
    this.delinquent = const Value.absent(),
    this.organizationPrivateKey = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String name,
    required int usedSpace,
    required String currency,
    required int credit,
    required int createTime,
    required int maxSpace,
    required int maxUpload,
    required int role,
    required bool private,
    required bool subscribed,
    required bool services,
    required bool delinquent,
    this.organizationPrivateKey = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
  })  : userId = Value(userId),
        name = Value(name),
        usedSpace = Value(usedSpace),
        currency = Value(currency),
        credit = Value(credit),
        createTime = Value(createTime),
        maxSpace = Value(maxSpace),
        maxUpload = Value(maxUpload),
        role = Value(role),
        private = Value(private),
        subscribed = Value(subscribed),
        services = Value(services),
        delinquent = Value(delinquent);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? usedSpace,
    Expression<String>? currency,
    Expression<int>? credit,
    Expression<int>? createTime,
    Expression<int>? maxSpace,
    Expression<int>? maxUpload,
    Expression<int>? role,
    Expression<bool>? private,
    Expression<bool>? subscribed,
    Expression<bool>? services,
    Expression<bool>? delinquent,
    Expression<String>? organizationPrivateKey,
    Expression<String>? email,
    Expression<String>? displayName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (usedSpace != null) 'used_space': usedSpace,
      if (currency != null) 'currency': currency,
      if (credit != null) 'credit': credit,
      if (createTime != null) 'create_time': createTime,
      if (maxSpace != null) 'max_space': maxSpace,
      if (maxUpload != null) 'max_upload': maxUpload,
      if (role != null) 'role': role,
      if (private != null) 'private': private,
      if (subscribed != null) 'subscribed': subscribed,
      if (services != null) 'services': services,
      if (delinquent != null) 'delinquent': delinquent,
      if (organizationPrivateKey != null)
        'organization_private_key': organizationPrivateKey,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
    });
  }

  UsersTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<int>? usedSpace,
      Value<String>? currency,
      Value<int>? credit,
      Value<int>? createTime,
      Value<int>? maxSpace,
      Value<int>? maxUpload,
      Value<int>? role,
      Value<bool>? private,
      Value<bool>? subscribed,
      Value<bool>? services,
      Value<bool>? delinquent,
      Value<String?>? organizationPrivateKey,
      Value<String?>? email,
      Value<String?>? displayName}) {
    return UsersTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      usedSpace: usedSpace ?? this.usedSpace,
      currency: currency ?? this.currency,
      credit: credit ?? this.credit,
      createTime: createTime ?? this.createTime,
      maxSpace: maxSpace ?? this.maxSpace,
      maxUpload: maxUpload ?? this.maxUpload,
      role: role ?? this.role,
      private: private ?? this.private,
      subscribed: subscribed ?? this.subscribed,
      services: services ?? this.services,
      delinquent: delinquent ?? this.delinquent,
      organizationPrivateKey:
          organizationPrivateKey ?? this.organizationPrivateKey,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (usedSpace.present) {
      map['used_space'] = Variable<int>(usedSpace.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (credit.present) {
      map['credit'] = Variable<int>(credit.value);
    }
    if (createTime.present) {
      map['create_time'] = Variable<int>(createTime.value);
    }
    if (maxSpace.present) {
      map['max_space'] = Variable<int>(maxSpace.value);
    }
    if (maxUpload.present) {
      map['max_upload'] = Variable<int>(maxUpload.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (private.present) {
      map['private'] = Variable<bool>(private.value);
    }
    if (subscribed.present) {
      map['subscribed'] = Variable<bool>(subscribed.value);
    }
    if (services.present) {
      map['services'] = Variable<bool>(services.value);
    }
    if (delinquent.present) {
      map['delinquent'] = Variable<bool>(delinquent.value);
    }
    if (organizationPrivateKey.present) {
      map['organization_private_key'] =
          Variable<String>(organizationPrivateKey.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('usedSpace: $usedSpace, ')
          ..write('currency: $currency, ')
          ..write('credit: $credit, ')
          ..write('createTime: $createTime, ')
          ..write('maxSpace: $maxSpace, ')
          ..write('maxUpload: $maxUpload, ')
          ..write('role: $role, ')
          ..write('private: $private, ')
          ..write('subscribed: $subscribed, ')
          ..write('services: $services, ')
          ..write('delinquent: $delinquent, ')
          ..write('organizationPrivateKey: $organizationPrivateKey, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }
}

class $UserKeysTableTable extends UserKeysTable
    with TableInfo<$UserKeysTableTable, UserKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserKeysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  @override
  late final GeneratedColumn<String> keyId = GeneratedColumn<String>(
      'key_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users_table (user_id)'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _privateKeyMeta =
      const VerificationMeta('privateKey');
  @override
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
      'private_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fingerprintMeta =
      const VerificationMeta('fingerprint');
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
      'fingerprint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _primaryMeta =
      const VerificationMeta('primary');
  @override
  late final GeneratedColumn<bool> primary = GeneratedColumn<bool>(
      'primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("primary" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [keyId, userId, version, privateKey, token, fingerprint, primary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_keys_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key_id')) {
      context.handle(
          _keyIdMeta, keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta));
    } else if (isInserting) {
      context.missing(_keyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('private_key')) {
      context.handle(
          _privateKeyMeta,
          privateKey.isAcceptableOrUnknown(
              data['private_key']!, _privateKeyMeta));
    } else if (isInserting) {
      context.missing(_privateKeyMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
          _fingerprintMeta,
          fingerprint.isAcceptableOrUnknown(
              data['fingerprint']!, _fingerprintMeta));
    }
    if (data.containsKey('primary')) {
      context.handle(_primaryMeta,
          primary.isAcceptableOrUnknown(data['primary']!, _primaryMeta));
    } else if (isInserting) {
      context.missing(_primaryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {keyId, userId};
  @override
  UserKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserKey(
      keyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      privateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}private_key'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token']),
      fingerprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fingerprint']),
      primary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}primary'])!,
    );
  }

  @override
  $UserKeysTableTable createAlias(String alias) {
    return $UserKeysTableTable(attachedDatabase, alias);
  }
}

class UserKey extends DataClass implements Insertable<UserKey> {
  final String keyId;
  final String userId;
  final int version;
  final String privateKey;
  final String? token;
  final String? fingerprint;
  final bool primary;
  const UserKey(
      {required this.keyId,
      required this.userId,
      required this.version,
      required this.privateKey,
      this.token,
      this.fingerprint,
      required this.primary});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key_id'] = Variable<String>(keyId);
    map['user_id'] = Variable<String>(userId);
    map['version'] = Variable<int>(version);
    map['private_key'] = Variable<String>(privateKey);
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    if (!nullToAbsent || fingerprint != null) {
      map['fingerprint'] = Variable<String>(fingerprint);
    }
    map['primary'] = Variable<bool>(primary);
    return map;
  }

  UserKeysTableCompanion toCompanion(bool nullToAbsent) {
    return UserKeysTableCompanion(
      keyId: Value(keyId),
      userId: Value(userId),
      version: Value(version),
      privateKey: Value(privateKey),
      token:
          token == null && nullToAbsent ? const Value.absent() : Value(token),
      fingerprint: fingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(fingerprint),
      primary: Value(primary),
    );
  }

  factory UserKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserKey(
      keyId: serializer.fromJson<String>(json['keyId']),
      userId: serializer.fromJson<String>(json['userId']),
      version: serializer.fromJson<int>(json['version']),
      privateKey: serializer.fromJson<String>(json['privateKey']),
      token: serializer.fromJson<String?>(json['token']),
      fingerprint: serializer.fromJson<String?>(json['fingerprint']),
      primary: serializer.fromJson<bool>(json['primary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'keyId': serializer.toJson<String>(keyId),
      'userId': serializer.toJson<String>(userId),
      'version': serializer.toJson<int>(version),
      'privateKey': serializer.toJson<String>(privateKey),
      'token': serializer.toJson<String?>(token),
      'fingerprint': serializer.toJson<String?>(fingerprint),
      'primary': serializer.toJson<bool>(primary),
    };
  }

  UserKey copyWith(
          {String? keyId,
          String? userId,
          int? version,
          String? privateKey,
          Value<String?> token = const Value.absent(),
          Value<String?> fingerprint = const Value.absent(),
          bool? primary}) =>
      UserKey(
        keyId: keyId ?? this.keyId,
        userId: userId ?? this.userId,
        version: version ?? this.version,
        privateKey: privateKey ?? this.privateKey,
        token: token.present ? token.value : this.token,
        fingerprint: fingerprint.present ? fingerprint.value : this.fingerprint,
        primary: primary ?? this.primary,
      );
  @override
  String toString() {
    return (StringBuffer('UserKey(')
          ..write('keyId: $keyId, ')
          ..write('userId: $userId, ')
          ..write('version: $version, ')
          ..write('privateKey: $privateKey, ')
          ..write('token: $token, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('primary: $primary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      keyId, userId, version, privateKey, token, fingerprint, primary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserKey &&
          other.keyId == this.keyId &&
          other.userId == this.userId &&
          other.version == this.version &&
          other.privateKey == this.privateKey &&
          other.token == this.token &&
          other.fingerprint == this.fingerprint &&
          other.primary == this.primary);
}

class UserKeysTableCompanion extends UpdateCompanion<UserKey> {
  final Value<String> keyId;
  final Value<String> userId;
  final Value<int> version;
  final Value<String> privateKey;
  final Value<String?> token;
  final Value<String?> fingerprint;
  final Value<bool> primary;
  final Value<int> rowid;
  const UserKeysTableCompanion({
    this.keyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.version = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.token = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.primary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserKeysTableCompanion.insert({
    required String keyId,
    required String userId,
    required int version,
    required String privateKey,
    this.token = const Value.absent(),
    this.fingerprint = const Value.absent(),
    required bool primary,
    this.rowid = const Value.absent(),
  })  : keyId = Value(keyId),
        userId = Value(userId),
        version = Value(version),
        privateKey = Value(privateKey),
        primary = Value(primary);
  static Insertable<UserKey> custom({
    Expression<String>? keyId,
    Expression<String>? userId,
    Expression<int>? version,
    Expression<String>? privateKey,
    Expression<String>? token,
    Expression<String>? fingerprint,
    Expression<bool>? primary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (keyId != null) 'key_id': keyId,
      if (userId != null) 'user_id': userId,
      if (version != null) 'version': version,
      if (privateKey != null) 'private_key': privateKey,
      if (token != null) 'token': token,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (primary != null) 'primary': primary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserKeysTableCompanion copyWith(
      {Value<String>? keyId,
      Value<String>? userId,
      Value<int>? version,
      Value<String>? privateKey,
      Value<String?>? token,
      Value<String?>? fingerprint,
      Value<bool>? primary,
      Value<int>? rowid}) {
    return UserKeysTableCompanion(
      keyId: keyId ?? this.keyId,
      userId: userId ?? this.userId,
      version: version ?? this.version,
      privateKey: privateKey ?? this.privateKey,
      token: token ?? this.token,
      fingerprint: fingerprint ?? this.fingerprint,
      primary: primary ?? this.primary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (keyId.present) {
      map['key_id'] = Variable<String>(keyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (primary.present) {
      map['primary'] = Variable<bool>(primary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserKeysTableCompanion(')
          ..write('keyId: $keyId, ')
          ..write('userId: $userId, ')
          ..write('version: $version, ')
          ..write('privateKey: $privateKey, ')
          ..write('token: $token, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('primary: $primary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $UserKeysTableTable userKeysTable = $UserKeysTableTable(this);
  late final Index userIdIndex = Index(
      'user_id_index', 'CREATE INDEX user_id_index ON users_table (user_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [usersTable, userKeysTable, userIdIndex];
}

typedef $$UsersTableTableInsertCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  required String userId,
  required String name,
  required int usedSpace,
  required String currency,
  required int credit,
  required int createTime,
  required int maxSpace,
  required int maxUpload,
  required int role,
  required bool private,
  required bool subscribed,
  required bool services,
  required bool delinquent,
  Value<String?> organizationPrivateKey,
  Value<String?> email,
  Value<String?> displayName,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> name,
  Value<int> usedSpace,
  Value<String> currency,
  Value<int> credit,
  Value<int> createTime,
  Value<int> maxSpace,
  Value<int> maxUpload,
  Value<int> role,
  Value<bool> private,
  Value<bool> subscribed,
  Value<bool> services,
  Value<bool> delinquent,
  Value<String?> organizationPrivateKey,
  Value<String?> email,
  Value<String?> displayName,
});

class $$UsersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTableTable,
    User,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableProcessedTableManager,
    $$UsersTableTableInsertCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder> {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UsersTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UsersTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$UsersTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> usedSpace = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> credit = const Value.absent(),
            Value<int> createTime = const Value.absent(),
            Value<int> maxSpace = const Value.absent(),
            Value<int> maxUpload = const Value.absent(),
            Value<int> role = const Value.absent(),
            Value<bool> private = const Value.absent(),
            Value<bool> subscribed = const Value.absent(),
            Value<bool> services = const Value.absent(),
            Value<bool> delinquent = const Value.absent(),
            Value<String?> organizationPrivateKey = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
          }) =>
              UsersTableCompanion(
            id: id,
            userId: userId,
            name: name,
            usedSpace: usedSpace,
            currency: currency,
            credit: credit,
            createTime: createTime,
            maxSpace: maxSpace,
            maxUpload: maxUpload,
            role: role,
            private: private,
            subscribed: subscribed,
            services: services,
            delinquent: delinquent,
            organizationPrivateKey: organizationPrivateKey,
            email: email,
            displayName: displayName,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String name,
            required int usedSpace,
            required String currency,
            required int credit,
            required int createTime,
            required int maxSpace,
            required int maxUpload,
            required int role,
            required bool private,
            required bool subscribed,
            required bool services,
            required bool delinquent,
            Value<String?> organizationPrivateKey = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
          }) =>
              UsersTableCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            usedSpace: usedSpace,
            currency: currency,
            credit: credit,
            createTime: createTime,
            maxSpace: maxSpace,
            maxUpload: maxUpload,
            role: role,
            private: private,
            subscribed: subscribed,
            services: services,
            delinquent: delinquent,
            organizationPrivateKey: organizationPrivateKey,
            email: email,
            displayName: displayName,
          ),
        ));
}

class $$UsersTableTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $UsersTableTable,
    User,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableProcessedTableManager,
    $$UsersTableTableInsertCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder> {
  $$UsersTableTableProcessedTableManager(super.$state);
}

class $$UsersTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get usedSpace => $state.composableBuilder(
      column: $state.table.usedSpace,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get credit => $state.composableBuilder(
      column: $state.table.credit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createTime => $state.composableBuilder(
      column: $state.table.createTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get maxSpace => $state.composableBuilder(
      column: $state.table.maxSpace,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get maxUpload => $state.composableBuilder(
      column: $state.table.maxUpload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get private => $state.composableBuilder(
      column: $state.table.private,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get subscribed => $state.composableBuilder(
      column: $state.table.subscribed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get services => $state.composableBuilder(
      column: $state.table.services,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get delinquent => $state.composableBuilder(
      column: $state.table.delinquent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get organizationPrivateKey => $state.composableBuilder(
      column: $state.table.organizationPrivateKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter userKeysTableRefs(
      ComposableFilter Function($$UserKeysTableTableFilterComposer f) f) {
    final $$UserKeysTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.userKeysTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder, parentComposers) =>
            $$UserKeysTableTableFilterComposer(ComposerState($state.db,
                $state.db.userKeysTable, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$UsersTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get usedSpace => $state.composableBuilder(
      column: $state.table.usedSpace,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get credit => $state.composableBuilder(
      column: $state.table.credit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createTime => $state.composableBuilder(
      column: $state.table.createTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get maxSpace => $state.composableBuilder(
      column: $state.table.maxSpace,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get maxUpload => $state.composableBuilder(
      column: $state.table.maxUpload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get private => $state.composableBuilder(
      column: $state.table.private,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get subscribed => $state.composableBuilder(
      column: $state.table.subscribed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get services => $state.composableBuilder(
      column: $state.table.services,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get delinquent => $state.composableBuilder(
      column: $state.table.delinquent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get organizationPrivateKey =>
      $state.composableBuilder(
          column: $state.table.organizationPrivateKey,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UserKeysTableTableInsertCompanionBuilder = UserKeysTableCompanion
    Function({
  required String keyId,
  required String userId,
  required int version,
  required String privateKey,
  Value<String?> token,
  Value<String?> fingerprint,
  required bool primary,
  Value<int> rowid,
});
typedef $$UserKeysTableTableUpdateCompanionBuilder = UserKeysTableCompanion
    Function({
  Value<String> keyId,
  Value<String> userId,
  Value<int> version,
  Value<String> privateKey,
  Value<String?> token,
  Value<String?> fingerprint,
  Value<bool> primary,
  Value<int> rowid,
});

class $$UserKeysTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserKeysTableTable,
    UserKey,
    $$UserKeysTableTableFilterComposer,
    $$UserKeysTableTableOrderingComposer,
    $$UserKeysTableTableProcessedTableManager,
    $$UserKeysTableTableInsertCompanionBuilder,
    $$UserKeysTableTableUpdateCompanionBuilder> {
  $$UserKeysTableTableTableManager(_$AppDatabase db, $UserKeysTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserKeysTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserKeysTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$UserKeysTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> keyId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> privateKey = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<String?> fingerprint = const Value.absent(),
            Value<bool> primary = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserKeysTableCompanion(
            keyId: keyId,
            userId: userId,
            version: version,
            privateKey: privateKey,
            token: token,
            fingerprint: fingerprint,
            primary: primary,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String keyId,
            required String userId,
            required int version,
            required String privateKey,
            Value<String?> token = const Value.absent(),
            Value<String?> fingerprint = const Value.absent(),
            required bool primary,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserKeysTableCompanion.insert(
            keyId: keyId,
            userId: userId,
            version: version,
            privateKey: privateKey,
            token: token,
            fingerprint: fingerprint,
            primary: primary,
            rowid: rowid,
          ),
        ));
}

class $$UserKeysTableTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $UserKeysTableTable,
    UserKey,
    $$UserKeysTableTableFilterComposer,
    $$UserKeysTableTableOrderingComposer,
    $$UserKeysTableTableProcessedTableManager,
    $$UserKeysTableTableInsertCompanionBuilder,
    $$UserKeysTableTableUpdateCompanionBuilder> {
  $$UserKeysTableTableProcessedTableManager(super.$state);
}

class $$UserKeysTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserKeysTableTable> {
  $$UserKeysTableTableFilterComposer(super.$state);
  ColumnFilters<String> get keyId => $state.composableBuilder(
      column: $state.table.keyId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get privateKey => $state.composableBuilder(
      column: $state.table.privateKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get token => $state.composableBuilder(
      column: $state.table.token,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fingerprint => $state.composableBuilder(
      column: $state.table.fingerprint,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get primary => $state.composableBuilder(
      column: $state.table.primary,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$UsersTableTableFilterComposer get userId {
    final $$UsersTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.usersTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder, parentComposers) =>
            $$UsersTableTableFilterComposer(ComposerState($state.db,
                $state.db.usersTable, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$UserKeysTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserKeysTableTable> {
  $$UserKeysTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get keyId => $state.composableBuilder(
      column: $state.table.keyId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get privateKey => $state.composableBuilder(
      column: $state.table.privateKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get token => $state.composableBuilder(
      column: $state.table.token,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fingerprint => $state.composableBuilder(
      column: $state.table.fingerprint,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get primary => $state.composableBuilder(
      column: $state.table.primary,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$UsersTableTableOrderingComposer get userId {
    final $$UsersTableTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.usersTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder, parentComposers) =>
            $$UsersTableTableOrderingComposer(ComposerState($state.db,
                $state.db.usersTable, joinBuilder, parentComposers)));
    return composer;
  }
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$UserKeysTableTableTableManager get userKeysTable =>
      $$UserKeysTableTableTableManager(_db, _db.userKeysTable);
}
