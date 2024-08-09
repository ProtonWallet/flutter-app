// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, DriftProtonUser> {
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
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _usedSpaceMeta =
      const VerificationMeta('usedSpace');
  @override
  late final GeneratedColumn<BigInt> usedSpace = GeneratedColumn<BigInt>(
      'used_space', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
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
  late final GeneratedColumn<BigInt> createTime = GeneratedColumn<BigInt>(
      'create_time', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _maxSpaceMeta =
      const VerificationMeta('maxSpace');
  @override
  late final GeneratedColumn<BigInt> maxSpace = GeneratedColumn<BigInt>(
      'max_space', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _maxUploadMeta =
      const VerificationMeta('maxUpload');
  @override
  late final GeneratedColumn<BigInt> maxUpload = GeneratedColumn<BigInt>(
      'max_upload', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
      'role', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _privateMeta =
      const VerificationMeta('private');
  @override
  late final GeneratedColumn<int> private = GeneratedColumn<int>(
      'private', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _subscribedMeta =
      const VerificationMeta('subscribed');
  @override
  late final GeneratedColumn<int> subscribed = GeneratedColumn<int>(
      'subscribed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _servicesMeta =
      const VerificationMeta('services');
  @override
  late final GeneratedColumn<int> services = GeneratedColumn<int>(
      'services', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _delinquentMeta =
      const VerificationMeta('delinquent');
  @override
  late final GeneratedColumn<int> delinquent = GeneratedColumn<int>(
      'delinquent', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  VerificationContext validateIntegrity(Insertable<DriftProtonUser> instance,
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
  DriftProtonUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftProtonUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      usedSpace: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}used_space'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      credit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credit'])!,
      createTime: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}create_time'])!,
      maxSpace: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}max_space'])!,
      maxUpload: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}max_upload'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role'])!,
      private: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}private'])!,
      subscribed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subscribed'])!,
      services: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}services'])!,
      delinquent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delinquent'])!,
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

class DriftProtonUser extends DataClass implements Insertable<DriftProtonUser> {
  final int id;
  final String userId;
  final String name;
  final BigInt usedSpace;
  final String currency;
  final int credit;
  final BigInt createTime;
  final BigInt maxSpace;
  final BigInt maxUpload;
  final int role;
  final int private;
  final int subscribed;
  final int services;
  final int delinquent;
  final String? organizationPrivateKey;
  final String? email;
  final String? displayName;
  const DriftProtonUser(
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
    map['used_space'] = Variable<BigInt>(usedSpace);
    map['currency'] = Variable<String>(currency);
    map['credit'] = Variable<int>(credit);
    map['create_time'] = Variable<BigInt>(createTime);
    map['max_space'] = Variable<BigInt>(maxSpace);
    map['max_upload'] = Variable<BigInt>(maxUpload);
    map['role'] = Variable<int>(role);
    map['private'] = Variable<int>(private);
    map['subscribed'] = Variable<int>(subscribed);
    map['services'] = Variable<int>(services);
    map['delinquent'] = Variable<int>(delinquent);
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

  factory DriftProtonUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftProtonUser(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      usedSpace: serializer.fromJson<BigInt>(json['usedSpace']),
      currency: serializer.fromJson<String>(json['currency']),
      credit: serializer.fromJson<int>(json['credit']),
      createTime: serializer.fromJson<BigInt>(json['createTime']),
      maxSpace: serializer.fromJson<BigInt>(json['maxSpace']),
      maxUpload: serializer.fromJson<BigInt>(json['maxUpload']),
      role: serializer.fromJson<int>(json['role']),
      private: serializer.fromJson<int>(json['private']),
      subscribed: serializer.fromJson<int>(json['subscribed']),
      services: serializer.fromJson<int>(json['services']),
      delinquent: serializer.fromJson<int>(json['delinquent']),
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
      'usedSpace': serializer.toJson<BigInt>(usedSpace),
      'currency': serializer.toJson<String>(currency),
      'credit': serializer.toJson<int>(credit),
      'createTime': serializer.toJson<BigInt>(createTime),
      'maxSpace': serializer.toJson<BigInt>(maxSpace),
      'maxUpload': serializer.toJson<BigInt>(maxUpload),
      'role': serializer.toJson<int>(role),
      'private': serializer.toJson<int>(private),
      'subscribed': serializer.toJson<int>(subscribed),
      'services': serializer.toJson<int>(services),
      'delinquent': serializer.toJson<int>(delinquent),
      'organizationPrivateKey':
          serializer.toJson<String?>(organizationPrivateKey),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String?>(displayName),
    };
  }

  DriftProtonUser copyWith(
          {int? id,
          String? userId,
          String? name,
          BigInt? usedSpace,
          String? currency,
          int? credit,
          BigInt? createTime,
          BigInt? maxSpace,
          BigInt? maxUpload,
          int? role,
          int? private,
          int? subscribed,
          int? services,
          int? delinquent,
          Value<String?> organizationPrivateKey = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> displayName = const Value.absent()}) =>
      DriftProtonUser(
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
  DriftProtonUser copyWithCompanion(UsersTableCompanion data) {
    return DriftProtonUser(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      usedSpace: data.usedSpace.present ? data.usedSpace.value : this.usedSpace,
      currency: data.currency.present ? data.currency.value : this.currency,
      credit: data.credit.present ? data.credit.value : this.credit,
      createTime:
          data.createTime.present ? data.createTime.value : this.createTime,
      maxSpace: data.maxSpace.present ? data.maxSpace.value : this.maxSpace,
      maxUpload: data.maxUpload.present ? data.maxUpload.value : this.maxUpload,
      role: data.role.present ? data.role.value : this.role,
      private: data.private.present ? data.private.value : this.private,
      subscribed:
          data.subscribed.present ? data.subscribed.value : this.subscribed,
      services: data.services.present ? data.services.value : this.services,
      delinquent:
          data.delinquent.present ? data.delinquent.value : this.delinquent,
      organizationPrivateKey: data.organizationPrivateKey.present
          ? data.organizationPrivateKey.value
          : this.organizationPrivateKey,
      email: data.email.present ? data.email.value : this.email,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftProtonUser(')
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
      (other is DriftProtonUser &&
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

class UsersTableCompanion extends UpdateCompanion<DriftProtonUser> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<BigInt> usedSpace;
  final Value<String> currency;
  final Value<int> credit;
  final Value<BigInt> createTime;
  final Value<BigInt> maxSpace;
  final Value<BigInt> maxUpload;
  final Value<int> role;
  final Value<int> private;
  final Value<int> subscribed;
  final Value<int> services;
  final Value<int> delinquent;
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
    required BigInt usedSpace,
    required String currency,
    required int credit,
    required BigInt createTime,
    required BigInt maxSpace,
    required BigInt maxUpload,
    required int role,
    required int private,
    required int subscribed,
    required int services,
    required int delinquent,
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
  static Insertable<DriftProtonUser> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<BigInt>? usedSpace,
    Expression<String>? currency,
    Expression<int>? credit,
    Expression<BigInt>? createTime,
    Expression<BigInt>? maxSpace,
    Expression<BigInt>? maxUpload,
    Expression<int>? role,
    Expression<int>? private,
    Expression<int>? subscribed,
    Expression<int>? services,
    Expression<int>? delinquent,
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
      Value<BigInt>? usedSpace,
      Value<String>? currency,
      Value<int>? credit,
      Value<BigInt>? createTime,
      Value<BigInt>? maxSpace,
      Value<BigInt>? maxUpload,
      Value<int>? role,
      Value<int>? private,
      Value<int>? subscribed,
      Value<int>? services,
      Value<int>? delinquent,
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
      map['used_space'] = Variable<BigInt>(usedSpace.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (credit.present) {
      map['credit'] = Variable<int>(credit.value);
    }
    if (createTime.present) {
      map['create_time'] = Variable<BigInt>(createTime.value);
    }
    if (maxSpace.present) {
      map['max_space'] = Variable<BigInt>(maxSpace.value);
    }
    if (maxUpload.present) {
      map['max_upload'] = Variable<BigInt>(maxUpload.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (private.present) {
      map['private'] = Variable<int>(private.value);
    }
    if (subscribed.present) {
      map['subscribed'] = Variable<int>(subscribed.value);
    }
    if (services.present) {
      map['services'] = Variable<int>(services.value);
    }
    if (delinquent.present) {
      map['delinquent'] = Variable<int>(delinquent.value);
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
    with TableInfo<$UserKeysTableTable, DriftUserKey> {
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
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _recoverySecretMeta =
      const VerificationMeta('recoverySecret');
  @override
  late final GeneratedColumn<String> recoverySecret = GeneratedColumn<String>(
      'recovery_secret', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recoverySecretSignatureMeta =
      const VerificationMeta('recoverySecretSignature');
  @override
  late final GeneratedColumn<String> recoverySecretSignature =
      GeneratedColumn<String>('recovery_secret_signature', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _primaryMeta =
      const VerificationMeta('primary');
  @override
  late final GeneratedColumn<int> primary = GeneratedColumn<int>(
      'primary', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        keyId,
        userId,
        version,
        privateKey,
        token,
        fingerprint,
        recoverySecret,
        recoverySecretSignature,
        primary
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_keys_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftUserKey> instance,
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
    if (data.containsKey('recovery_secret')) {
      context.handle(
          _recoverySecretMeta,
          recoverySecret.isAcceptableOrUnknown(
              data['recovery_secret']!, _recoverySecretMeta));
    }
    if (data.containsKey('recovery_secret_signature')) {
      context.handle(
          _recoverySecretSignatureMeta,
          recoverySecretSignature.isAcceptableOrUnknown(
              data['recovery_secret_signature']!,
              _recoverySecretSignatureMeta));
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
  DriftUserKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftUserKey(
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
      recoverySecret: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recovery_secret']),
      recoverySecretSignature: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recovery_secret_signature']),
      primary: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}primary'])!,
    );
  }

  @override
  $UserKeysTableTable createAlias(String alias) {
    return $UserKeysTableTable(attachedDatabase, alias);
  }
}

class DriftUserKey extends DataClass implements Insertable<DriftUserKey> {
  final String keyId;
  final String userId;
  final int version;
  final String privateKey;
  final String? token;
  final String? fingerprint;
  final String? recoverySecret;
  final String? recoverySecretSignature;
  final int primary;
  const DriftUserKey(
      {required this.keyId,
      required this.userId,
      required this.version,
      required this.privateKey,
      this.token,
      this.fingerprint,
      this.recoverySecret,
      this.recoverySecretSignature,
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
    if (!nullToAbsent || recoverySecret != null) {
      map['recovery_secret'] = Variable<String>(recoverySecret);
    }
    if (!nullToAbsent || recoverySecretSignature != null) {
      map['recovery_secret_signature'] =
          Variable<String>(recoverySecretSignature);
    }
    map['primary'] = Variable<int>(primary);
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
      recoverySecret: recoverySecret == null && nullToAbsent
          ? const Value.absent()
          : Value(recoverySecret),
      recoverySecretSignature: recoverySecretSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(recoverySecretSignature),
      primary: Value(primary),
    );
  }

  factory DriftUserKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftUserKey(
      keyId: serializer.fromJson<String>(json['keyId']),
      userId: serializer.fromJson<String>(json['userId']),
      version: serializer.fromJson<int>(json['version']),
      privateKey: serializer.fromJson<String>(json['privateKey']),
      token: serializer.fromJson<String?>(json['token']),
      fingerprint: serializer.fromJson<String?>(json['fingerprint']),
      recoverySecret: serializer.fromJson<String?>(json['recoverySecret']),
      recoverySecretSignature:
          serializer.fromJson<String?>(json['recoverySecretSignature']),
      primary: serializer.fromJson<int>(json['primary']),
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
      'recoverySecret': serializer.toJson<String?>(recoverySecret),
      'recoverySecretSignature':
          serializer.toJson<String?>(recoverySecretSignature),
      'primary': serializer.toJson<int>(primary),
    };
  }

  DriftUserKey copyWith(
          {String? keyId,
          String? userId,
          int? version,
          String? privateKey,
          Value<String?> token = const Value.absent(),
          Value<String?> fingerprint = const Value.absent(),
          Value<String?> recoverySecret = const Value.absent(),
          Value<String?> recoverySecretSignature = const Value.absent(),
          int? primary}) =>
      DriftUserKey(
        keyId: keyId ?? this.keyId,
        userId: userId ?? this.userId,
        version: version ?? this.version,
        privateKey: privateKey ?? this.privateKey,
        token: token.present ? token.value : this.token,
        fingerprint: fingerprint.present ? fingerprint.value : this.fingerprint,
        recoverySecret:
            recoverySecret.present ? recoverySecret.value : this.recoverySecret,
        recoverySecretSignature: recoverySecretSignature.present
            ? recoverySecretSignature.value
            : this.recoverySecretSignature,
        primary: primary ?? this.primary,
      );
  DriftUserKey copyWithCompanion(UserKeysTableCompanion data) {
    return DriftUserKey(
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      version: data.version.present ? data.version.value : this.version,
      privateKey:
          data.privateKey.present ? data.privateKey.value : this.privateKey,
      token: data.token.present ? data.token.value : this.token,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      recoverySecret: data.recoverySecret.present
          ? data.recoverySecret.value
          : this.recoverySecret,
      recoverySecretSignature: data.recoverySecretSignature.present
          ? data.recoverySecretSignature.value
          : this.recoverySecretSignature,
      primary: data.primary.present ? data.primary.value : this.primary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftUserKey(')
          ..write('keyId: $keyId, ')
          ..write('userId: $userId, ')
          ..write('version: $version, ')
          ..write('privateKey: $privateKey, ')
          ..write('token: $token, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('recoverySecret: $recoverySecret, ')
          ..write('recoverySecretSignature: $recoverySecretSignature, ')
          ..write('primary: $primary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(keyId, userId, version, privateKey, token,
      fingerprint, recoverySecret, recoverySecretSignature, primary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftUserKey &&
          other.keyId == this.keyId &&
          other.userId == this.userId &&
          other.version == this.version &&
          other.privateKey == this.privateKey &&
          other.token == this.token &&
          other.fingerprint == this.fingerprint &&
          other.recoverySecret == this.recoverySecret &&
          other.recoverySecretSignature == this.recoverySecretSignature &&
          other.primary == this.primary);
}

class UserKeysTableCompanion extends UpdateCompanion<DriftUserKey> {
  final Value<String> keyId;
  final Value<String> userId;
  final Value<int> version;
  final Value<String> privateKey;
  final Value<String?> token;
  final Value<String?> fingerprint;
  final Value<String?> recoverySecret;
  final Value<String?> recoverySecretSignature;
  final Value<int> primary;
  final Value<int> rowid;
  const UserKeysTableCompanion({
    this.keyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.version = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.token = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.recoverySecret = const Value.absent(),
    this.recoverySecretSignature = const Value.absent(),
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
    this.recoverySecret = const Value.absent(),
    this.recoverySecretSignature = const Value.absent(),
    required int primary,
    this.rowid = const Value.absent(),
  })  : keyId = Value(keyId),
        userId = Value(userId),
        version = Value(version),
        privateKey = Value(privateKey),
        primary = Value(primary);
  static Insertable<DriftUserKey> custom({
    Expression<String>? keyId,
    Expression<String>? userId,
    Expression<int>? version,
    Expression<String>? privateKey,
    Expression<String>? token,
    Expression<String>? fingerprint,
    Expression<String>? recoverySecret,
    Expression<String>? recoverySecretSignature,
    Expression<int>? primary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (keyId != null) 'key_id': keyId,
      if (userId != null) 'user_id': userId,
      if (version != null) 'version': version,
      if (privateKey != null) 'private_key': privateKey,
      if (token != null) 'token': token,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (recoverySecret != null) 'recovery_secret': recoverySecret,
      if (recoverySecretSignature != null)
        'recovery_secret_signature': recoverySecretSignature,
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
      Value<String?>? recoverySecret,
      Value<String?>? recoverySecretSignature,
      Value<int>? primary,
      Value<int>? rowid}) {
    return UserKeysTableCompanion(
      keyId: keyId ?? this.keyId,
      userId: userId ?? this.userId,
      version: version ?? this.version,
      privateKey: privateKey ?? this.privateKey,
      token: token ?? this.token,
      fingerprint: fingerprint ?? this.fingerprint,
      recoverySecret: recoverySecret ?? this.recoverySecret,
      recoverySecretSignature:
          recoverySecretSignature ?? this.recoverySecretSignature,
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
    if (recoverySecret.present) {
      map['recovery_secret'] = Variable<String>(recoverySecret.value);
    }
    if (recoverySecretSignature.present) {
      map['recovery_secret_signature'] =
          Variable<String>(recoverySecretSignature.value);
    }
    if (primary.present) {
      map['primary'] = Variable<int>(primary.value);
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
          ..write('recoverySecret: $recoverySecret, ')
          ..write('recoverySecretSignature: $recoverySecretSignature, ')
          ..write('primary: $primary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletUserSettingsTableTable extends WalletUserSettingsTable
    with TableInfo<$WalletUserSettingsTableTable, WalletUserSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletUserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bitcoinUnitMeta =
      const VerificationMeta('bitcoinUnit');
  @override
  late final GeneratedColumn<String> bitcoinUnit = GeneratedColumn<String>(
      'bitcoin_unit', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fiatCurrencyMeta =
      const VerificationMeta('fiatCurrency');
  @override
  late final GeneratedColumn<String> fiatCurrency = GeneratedColumn<String>(
      'fiat_currency', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _hideEmptyUsedAddressesMeta =
      const VerificationMeta('hideEmptyUsedAddresses');
  @override
  late final GeneratedColumn<bool> hideEmptyUsedAddresses =
      GeneratedColumn<bool>('hide_empty_used_addresses', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("hide_empty_used_addresses" IN (0, 1))'));
  static const VerificationMeta _showWalletRecoveryMeta =
      const VerificationMeta('showWalletRecovery');
  @override
  late final GeneratedColumn<bool> showWalletRecovery = GeneratedColumn<bool>(
      'show_wallet_recovery', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_wallet_recovery" IN (0, 1))'));
  static const VerificationMeta _twoFactorAmountThresholdMeta =
      const VerificationMeta('twoFactorAmountThreshold');
  @override
  late final GeneratedColumn<double> twoFactorAmountThreshold =
      GeneratedColumn<double>('two_factor_amount_threshold', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _receiveInviterNotificationMeta =
      const VerificationMeta('receiveInviterNotification');
  @override
  late final GeneratedColumn<bool> receiveInviterNotification =
      GeneratedColumn<bool>('receive_inviter_notification', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("receive_inviter_notification" IN (0, 1))'));
  static const VerificationMeta _receiveEmailIntegrationNotificationMeta =
      const VerificationMeta('receiveEmailIntegrationNotification');
  @override
  late final GeneratedColumn<bool> receiveEmailIntegrationNotification =
      GeneratedColumn<bool>(
          'receive_email_integration_notification', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("receive_email_integration_notification" IN (0, 1))'));
  static const VerificationMeta _walletCreatedMeta =
      const VerificationMeta('walletCreated');
  @override
  late final GeneratedColumn<bool> walletCreated = GeneratedColumn<bool>(
      'wallet_created', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("wallet_created" IN (0, 1))'));
  static const VerificationMeta _acceptTermsAndConditionsMeta =
      const VerificationMeta('acceptTermsAndConditions');
  @override
  late final GeneratedColumn<bool> acceptTermsAndConditions =
      GeneratedColumn<bool>(
          'accept_terms_and_conditions', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("accept_terms_and_conditions" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        bitcoinUnit,
        fiatCurrency,
        hideEmptyUsedAddresses,
        showWalletRecovery,
        twoFactorAmountThreshold,
        receiveInviterNotification,
        receiveEmailIntegrationNotification,
        walletCreated,
        acceptTermsAndConditions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_user_settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<WalletUserSettings> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bitcoin_unit')) {
      context.handle(
          _bitcoinUnitMeta,
          bitcoinUnit.isAcceptableOrUnknown(
              data['bitcoin_unit']!, _bitcoinUnitMeta));
    } else if (isInserting) {
      context.missing(_bitcoinUnitMeta);
    }
    if (data.containsKey('fiat_currency')) {
      context.handle(
          _fiatCurrencyMeta,
          fiatCurrency.isAcceptableOrUnknown(
              data['fiat_currency']!, _fiatCurrencyMeta));
    } else if (isInserting) {
      context.missing(_fiatCurrencyMeta);
    }
    if (data.containsKey('hide_empty_used_addresses')) {
      context.handle(
          _hideEmptyUsedAddressesMeta,
          hideEmptyUsedAddresses.isAcceptableOrUnknown(
              data['hide_empty_used_addresses']!, _hideEmptyUsedAddressesMeta));
    } else if (isInserting) {
      context.missing(_hideEmptyUsedAddressesMeta);
    }
    if (data.containsKey('show_wallet_recovery')) {
      context.handle(
          _showWalletRecoveryMeta,
          showWalletRecovery.isAcceptableOrUnknown(
              data['show_wallet_recovery']!, _showWalletRecoveryMeta));
    } else if (isInserting) {
      context.missing(_showWalletRecoveryMeta);
    }
    if (data.containsKey('two_factor_amount_threshold')) {
      context.handle(
          _twoFactorAmountThresholdMeta,
          twoFactorAmountThreshold.isAcceptableOrUnknown(
              data['two_factor_amount_threshold']!,
              _twoFactorAmountThresholdMeta));
    } else if (isInserting) {
      context.missing(_twoFactorAmountThresholdMeta);
    }
    if (data.containsKey('receive_inviter_notification')) {
      context.handle(
          _receiveInviterNotificationMeta,
          receiveInviterNotification.isAcceptableOrUnknown(
              data['receive_inviter_notification']!,
              _receiveInviterNotificationMeta));
    } else if (isInserting) {
      context.missing(_receiveInviterNotificationMeta);
    }
    if (data.containsKey('receive_email_integration_notification')) {
      context.handle(
          _receiveEmailIntegrationNotificationMeta,
          receiveEmailIntegrationNotification.isAcceptableOrUnknown(
              data['receive_email_integration_notification']!,
              _receiveEmailIntegrationNotificationMeta));
    } else if (isInserting) {
      context.missing(_receiveEmailIntegrationNotificationMeta);
    }
    if (data.containsKey('wallet_created')) {
      context.handle(
          _walletCreatedMeta,
          walletCreated.isAcceptableOrUnknown(
              data['wallet_created']!, _walletCreatedMeta));
    } else if (isInserting) {
      context.missing(_walletCreatedMeta);
    }
    if (data.containsKey('accept_terms_and_conditions')) {
      context.handle(
          _acceptTermsAndConditionsMeta,
          acceptTermsAndConditions.isAcceptableOrUnknown(
              data['accept_terms_and_conditions']!,
              _acceptTermsAndConditionsMeta));
    } else if (isInserting) {
      context.missing(_acceptTermsAndConditionsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  WalletUserSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletUserSettings(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      bitcoinUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bitcoin_unit'])!,
      fiatCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fiat_currency'])!,
      hideEmptyUsedAddresses: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}hide_empty_used_addresses'])!,
      showWalletRecovery: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_wallet_recovery'])!,
      twoFactorAmountThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}two_factor_amount_threshold'])!,
      receiveInviterNotification: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}receive_inviter_notification'])!,
      receiveEmailIntegrationNotification: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}receive_email_integration_notification'])!,
      walletCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}wallet_created'])!,
      acceptTermsAndConditions: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}accept_terms_and_conditions'])!,
    );
  }

  @override
  $WalletUserSettingsTableTable createAlias(String alias) {
    return $WalletUserSettingsTableTable(attachedDatabase, alias);
  }
}

class WalletUserSettings extends DataClass
    implements Insertable<WalletUserSettings> {
  final String userId;
  final String bitcoinUnit;
  final String fiatCurrency;
  final bool hideEmptyUsedAddresses;
  final bool showWalletRecovery;
  final double twoFactorAmountThreshold;
  final bool receiveInviterNotification;
  final bool receiveEmailIntegrationNotification;
  final bool walletCreated;
  final bool acceptTermsAndConditions;
  const WalletUserSettings(
      {required this.userId,
      required this.bitcoinUnit,
      required this.fiatCurrency,
      required this.hideEmptyUsedAddresses,
      required this.showWalletRecovery,
      required this.twoFactorAmountThreshold,
      required this.receiveInviterNotification,
      required this.receiveEmailIntegrationNotification,
      required this.walletCreated,
      required this.acceptTermsAndConditions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['bitcoin_unit'] = Variable<String>(bitcoinUnit);
    map['fiat_currency'] = Variable<String>(fiatCurrency);
    map['hide_empty_used_addresses'] = Variable<bool>(hideEmptyUsedAddresses);
    map['show_wallet_recovery'] = Variable<bool>(showWalletRecovery);
    map['two_factor_amount_threshold'] =
        Variable<double>(twoFactorAmountThreshold);
    map['receive_inviter_notification'] =
        Variable<bool>(receiveInviterNotification);
    map['receive_email_integration_notification'] =
        Variable<bool>(receiveEmailIntegrationNotification);
    map['wallet_created'] = Variable<bool>(walletCreated);
    map['accept_terms_and_conditions'] =
        Variable<bool>(acceptTermsAndConditions);
    return map;
  }

  WalletUserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return WalletUserSettingsTableCompanion(
      userId: Value(userId),
      bitcoinUnit: Value(bitcoinUnit),
      fiatCurrency: Value(fiatCurrency),
      hideEmptyUsedAddresses: Value(hideEmptyUsedAddresses),
      showWalletRecovery: Value(showWalletRecovery),
      twoFactorAmountThreshold: Value(twoFactorAmountThreshold),
      receiveInviterNotification: Value(receiveInviterNotification),
      receiveEmailIntegrationNotification:
          Value(receiveEmailIntegrationNotification),
      walletCreated: Value(walletCreated),
      acceptTermsAndConditions: Value(acceptTermsAndConditions),
    );
  }

  factory WalletUserSettings.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletUserSettings(
      userId: serializer.fromJson<String>(json['userId']),
      bitcoinUnit: serializer.fromJson<String>(json['bitcoinUnit']),
      fiatCurrency: serializer.fromJson<String>(json['fiatCurrency']),
      hideEmptyUsedAddresses:
          serializer.fromJson<bool>(json['hideEmptyUsedAddresses']),
      showWalletRecovery: serializer.fromJson<bool>(json['showWalletRecovery']),
      twoFactorAmountThreshold:
          serializer.fromJson<double>(json['twoFactorAmountThreshold']),
      receiveInviterNotification:
          serializer.fromJson<bool>(json['receiveInviterNotification']),
      receiveEmailIntegrationNotification: serializer
          .fromJson<bool>(json['receiveEmailIntegrationNotification']),
      walletCreated: serializer.fromJson<bool>(json['walletCreated']),
      acceptTermsAndConditions:
          serializer.fromJson<bool>(json['acceptTermsAndConditions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'bitcoinUnit': serializer.toJson<String>(bitcoinUnit),
      'fiatCurrency': serializer.toJson<String>(fiatCurrency),
      'hideEmptyUsedAddresses': serializer.toJson<bool>(hideEmptyUsedAddresses),
      'showWalletRecovery': serializer.toJson<bool>(showWalletRecovery),
      'twoFactorAmountThreshold':
          serializer.toJson<double>(twoFactorAmountThreshold),
      'receiveInviterNotification':
          serializer.toJson<bool>(receiveInviterNotification),
      'receiveEmailIntegrationNotification':
          serializer.toJson<bool>(receiveEmailIntegrationNotification),
      'walletCreated': serializer.toJson<bool>(walletCreated),
      'acceptTermsAndConditions':
          serializer.toJson<bool>(acceptTermsAndConditions),
    };
  }

  WalletUserSettings copyWith(
          {String? userId,
          String? bitcoinUnit,
          String? fiatCurrency,
          bool? hideEmptyUsedAddresses,
          bool? showWalletRecovery,
          double? twoFactorAmountThreshold,
          bool? receiveInviterNotification,
          bool? receiveEmailIntegrationNotification,
          bool? walletCreated,
          bool? acceptTermsAndConditions}) =>
      WalletUserSettings(
        userId: userId ?? this.userId,
        bitcoinUnit: bitcoinUnit ?? this.bitcoinUnit,
        fiatCurrency: fiatCurrency ?? this.fiatCurrency,
        hideEmptyUsedAddresses:
            hideEmptyUsedAddresses ?? this.hideEmptyUsedAddresses,
        showWalletRecovery: showWalletRecovery ?? this.showWalletRecovery,
        twoFactorAmountThreshold:
            twoFactorAmountThreshold ?? this.twoFactorAmountThreshold,
        receiveInviterNotification:
            receiveInviterNotification ?? this.receiveInviterNotification,
        receiveEmailIntegrationNotification:
            receiveEmailIntegrationNotification ??
                this.receiveEmailIntegrationNotification,
        walletCreated: walletCreated ?? this.walletCreated,
        acceptTermsAndConditions:
            acceptTermsAndConditions ?? this.acceptTermsAndConditions,
      );
  WalletUserSettings copyWithCompanion(WalletUserSettingsTableCompanion data) {
    return WalletUserSettings(
      userId: data.userId.present ? data.userId.value : this.userId,
      bitcoinUnit:
          data.bitcoinUnit.present ? data.bitcoinUnit.value : this.bitcoinUnit,
      fiatCurrency: data.fiatCurrency.present
          ? data.fiatCurrency.value
          : this.fiatCurrency,
      hideEmptyUsedAddresses: data.hideEmptyUsedAddresses.present
          ? data.hideEmptyUsedAddresses.value
          : this.hideEmptyUsedAddresses,
      showWalletRecovery: data.showWalletRecovery.present
          ? data.showWalletRecovery.value
          : this.showWalletRecovery,
      twoFactorAmountThreshold: data.twoFactorAmountThreshold.present
          ? data.twoFactorAmountThreshold.value
          : this.twoFactorAmountThreshold,
      receiveInviterNotification: data.receiveInviterNotification.present
          ? data.receiveInviterNotification.value
          : this.receiveInviterNotification,
      receiveEmailIntegrationNotification:
          data.receiveEmailIntegrationNotification.present
              ? data.receiveEmailIntegrationNotification.value
              : this.receiveEmailIntegrationNotification,
      walletCreated: data.walletCreated.present
          ? data.walletCreated.value
          : this.walletCreated,
      acceptTermsAndConditions: data.acceptTermsAndConditions.present
          ? data.acceptTermsAndConditions.value
          : this.acceptTermsAndConditions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletUserSettings(')
          ..write('userId: $userId, ')
          ..write('bitcoinUnit: $bitcoinUnit, ')
          ..write('fiatCurrency: $fiatCurrency, ')
          ..write('hideEmptyUsedAddresses: $hideEmptyUsedAddresses, ')
          ..write('showWalletRecovery: $showWalletRecovery, ')
          ..write('twoFactorAmountThreshold: $twoFactorAmountThreshold, ')
          ..write('receiveInviterNotification: $receiveInviterNotification, ')
          ..write(
              'receiveEmailIntegrationNotification: $receiveEmailIntegrationNotification, ')
          ..write('walletCreated: $walletCreated, ')
          ..write('acceptTermsAndConditions: $acceptTermsAndConditions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      bitcoinUnit,
      fiatCurrency,
      hideEmptyUsedAddresses,
      showWalletRecovery,
      twoFactorAmountThreshold,
      receiveInviterNotification,
      receiveEmailIntegrationNotification,
      walletCreated,
      acceptTermsAndConditions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletUserSettings &&
          other.userId == this.userId &&
          other.bitcoinUnit == this.bitcoinUnit &&
          other.fiatCurrency == this.fiatCurrency &&
          other.hideEmptyUsedAddresses == this.hideEmptyUsedAddresses &&
          other.showWalletRecovery == this.showWalletRecovery &&
          other.twoFactorAmountThreshold == this.twoFactorAmountThreshold &&
          other.receiveInviterNotification == this.receiveInviterNotification &&
          other.receiveEmailIntegrationNotification ==
              this.receiveEmailIntegrationNotification &&
          other.walletCreated == this.walletCreated &&
          other.acceptTermsAndConditions == this.acceptTermsAndConditions);
}

class WalletUserSettingsTableCompanion
    extends UpdateCompanion<WalletUserSettings> {
  final Value<String> userId;
  final Value<String> bitcoinUnit;
  final Value<String> fiatCurrency;
  final Value<bool> hideEmptyUsedAddresses;
  final Value<bool> showWalletRecovery;
  final Value<double> twoFactorAmountThreshold;
  final Value<bool> receiveInviterNotification;
  final Value<bool> receiveEmailIntegrationNotification;
  final Value<bool> walletCreated;
  final Value<bool> acceptTermsAndConditions;
  final Value<int> rowid;
  const WalletUserSettingsTableCompanion({
    this.userId = const Value.absent(),
    this.bitcoinUnit = const Value.absent(),
    this.fiatCurrency = const Value.absent(),
    this.hideEmptyUsedAddresses = const Value.absent(),
    this.showWalletRecovery = const Value.absent(),
    this.twoFactorAmountThreshold = const Value.absent(),
    this.receiveInviterNotification = const Value.absent(),
    this.receiveEmailIntegrationNotification = const Value.absent(),
    this.walletCreated = const Value.absent(),
    this.acceptTermsAndConditions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletUserSettingsTableCompanion.insert({
    required String userId,
    required String bitcoinUnit,
    required String fiatCurrency,
    required bool hideEmptyUsedAddresses,
    required bool showWalletRecovery,
    required double twoFactorAmountThreshold,
    required bool receiveInviterNotification,
    required bool receiveEmailIntegrationNotification,
    required bool walletCreated,
    required bool acceptTermsAndConditions,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        bitcoinUnit = Value(bitcoinUnit),
        fiatCurrency = Value(fiatCurrency),
        hideEmptyUsedAddresses = Value(hideEmptyUsedAddresses),
        showWalletRecovery = Value(showWalletRecovery),
        twoFactorAmountThreshold = Value(twoFactorAmountThreshold),
        receiveInviterNotification = Value(receiveInviterNotification),
        receiveEmailIntegrationNotification =
            Value(receiveEmailIntegrationNotification),
        walletCreated = Value(walletCreated),
        acceptTermsAndConditions = Value(acceptTermsAndConditions);
  static Insertable<WalletUserSettings> custom({
    Expression<String>? userId,
    Expression<String>? bitcoinUnit,
    Expression<String>? fiatCurrency,
    Expression<bool>? hideEmptyUsedAddresses,
    Expression<bool>? showWalletRecovery,
    Expression<double>? twoFactorAmountThreshold,
    Expression<bool>? receiveInviterNotification,
    Expression<bool>? receiveEmailIntegrationNotification,
    Expression<bool>? walletCreated,
    Expression<bool>? acceptTermsAndConditions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (bitcoinUnit != null) 'bitcoin_unit': bitcoinUnit,
      if (fiatCurrency != null) 'fiat_currency': fiatCurrency,
      if (hideEmptyUsedAddresses != null)
        'hide_empty_used_addresses': hideEmptyUsedAddresses,
      if (showWalletRecovery != null)
        'show_wallet_recovery': showWalletRecovery,
      if (twoFactorAmountThreshold != null)
        'two_factor_amount_threshold': twoFactorAmountThreshold,
      if (receiveInviterNotification != null)
        'receive_inviter_notification': receiveInviterNotification,
      if (receiveEmailIntegrationNotification != null)
        'receive_email_integration_notification':
            receiveEmailIntegrationNotification,
      if (walletCreated != null) 'wallet_created': walletCreated,
      if (acceptTermsAndConditions != null)
        'accept_terms_and_conditions': acceptTermsAndConditions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletUserSettingsTableCompanion copyWith(
      {Value<String>? userId,
      Value<String>? bitcoinUnit,
      Value<String>? fiatCurrency,
      Value<bool>? hideEmptyUsedAddresses,
      Value<bool>? showWalletRecovery,
      Value<double>? twoFactorAmountThreshold,
      Value<bool>? receiveInviterNotification,
      Value<bool>? receiveEmailIntegrationNotification,
      Value<bool>? walletCreated,
      Value<bool>? acceptTermsAndConditions,
      Value<int>? rowid}) {
    return WalletUserSettingsTableCompanion(
      userId: userId ?? this.userId,
      bitcoinUnit: bitcoinUnit ?? this.bitcoinUnit,
      fiatCurrency: fiatCurrency ?? this.fiatCurrency,
      hideEmptyUsedAddresses:
          hideEmptyUsedAddresses ?? this.hideEmptyUsedAddresses,
      showWalletRecovery: showWalletRecovery ?? this.showWalletRecovery,
      twoFactorAmountThreshold:
          twoFactorAmountThreshold ?? this.twoFactorAmountThreshold,
      receiveInviterNotification:
          receiveInviterNotification ?? this.receiveInviterNotification,
      receiveEmailIntegrationNotification:
          receiveEmailIntegrationNotification ??
              this.receiveEmailIntegrationNotification,
      walletCreated: walletCreated ?? this.walletCreated,
      acceptTermsAndConditions:
          acceptTermsAndConditions ?? this.acceptTermsAndConditions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bitcoinUnit.present) {
      map['bitcoin_unit'] = Variable<String>(bitcoinUnit.value);
    }
    if (fiatCurrency.present) {
      map['fiat_currency'] = Variable<String>(fiatCurrency.value);
    }
    if (hideEmptyUsedAddresses.present) {
      map['hide_empty_used_addresses'] =
          Variable<bool>(hideEmptyUsedAddresses.value);
    }
    if (showWalletRecovery.present) {
      map['show_wallet_recovery'] = Variable<bool>(showWalletRecovery.value);
    }
    if (twoFactorAmountThreshold.present) {
      map['two_factor_amount_threshold'] =
          Variable<double>(twoFactorAmountThreshold.value);
    }
    if (receiveInviterNotification.present) {
      map['receive_inviter_notification'] =
          Variable<bool>(receiveInviterNotification.value);
    }
    if (receiveEmailIntegrationNotification.present) {
      map['receive_email_integration_notification'] =
          Variable<bool>(receiveEmailIntegrationNotification.value);
    }
    if (walletCreated.present) {
      map['wallet_created'] = Variable<bool>(walletCreated.value);
    }
    if (acceptTermsAndConditions.present) {
      map['accept_terms_and_conditions'] =
          Variable<bool>(acceptTermsAndConditions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletUserSettingsTableCompanion(')
          ..write('userId: $userId, ')
          ..write('bitcoinUnit: $bitcoinUnit, ')
          ..write('fiatCurrency: $fiatCurrency, ')
          ..write('hideEmptyUsedAddresses: $hideEmptyUsedAddresses, ')
          ..write('showWalletRecovery: $showWalletRecovery, ')
          ..write('twoFactorAmountThreshold: $twoFactorAmountThreshold, ')
          ..write('receiveInviterNotification: $receiveInviterNotification, ')
          ..write(
              'receiveEmailIntegrationNotification: $receiveEmailIntegrationNotification, ')
          ..write('walletCreated: $walletCreated, ')
          ..write('acceptTermsAndConditions: $acceptTermsAndConditions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $UserKeysTableTable userKeysTable = $UserKeysTableTable(this);
  late final $WalletUserSettingsTableTable walletUserSettingsTable =
      $WalletUserSettingsTableTable(this);
  late final Index userIdIndex = Index(
      'user_id_index', 'CREATE INDEX user_id_index ON users_table (user_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [usersTable, userKeysTable, walletUserSettingsTable, userIdIndex];
}

typedef $$UsersTableTableCreateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  required String userId,
  required String name,
  required BigInt usedSpace,
  required String currency,
  required int credit,
  required BigInt createTime,
  required BigInt maxSpace,
  required BigInt maxUpload,
  required int role,
  required int private,
  required int subscribed,
  required int services,
  required int delinquent,
  Value<String?> organizationPrivateKey,
  Value<String?> email,
  Value<String?> displayName,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> name,
  Value<BigInt> usedSpace,
  Value<String> currency,
  Value<int> credit,
  Value<BigInt> createTime,
  Value<BigInt> maxSpace,
  Value<BigInt> maxUpload,
  Value<int> role,
  Value<int> private,
  Value<int> subscribed,
  Value<int> services,
  Value<int> delinquent,
  Value<String?> organizationPrivateKey,
  Value<String?> email,
  Value<String?> displayName,
});

class $$UsersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTableTable,
    DriftProtonUser,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder> {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UsersTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UsersTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<BigInt> usedSpace = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> credit = const Value.absent(),
            Value<BigInt> createTime = const Value.absent(),
            Value<BigInt> maxSpace = const Value.absent(),
            Value<BigInt> maxUpload = const Value.absent(),
            Value<int> role = const Value.absent(),
            Value<int> private = const Value.absent(),
            Value<int> subscribed = const Value.absent(),
            Value<int> services = const Value.absent(),
            Value<int> delinquent = const Value.absent(),
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
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String name,
            required BigInt usedSpace,
            required String currency,
            required int credit,
            required BigInt createTime,
            required BigInt maxSpace,
            required BigInt maxUpload,
            required int role,
            required int private,
            required int subscribed,
            required int services,
            required int delinquent,
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

  ColumnFilters<BigInt> get usedSpace => $state.composableBuilder(
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

  ColumnFilters<BigInt> get createTime => $state.composableBuilder(
      column: $state.table.createTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<BigInt> get maxSpace => $state.composableBuilder(
      column: $state.table.maxSpace,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<BigInt> get maxUpload => $state.composableBuilder(
      column: $state.table.maxUpload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get private => $state.composableBuilder(
      column: $state.table.private,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get subscribed => $state.composableBuilder(
      column: $state.table.subscribed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get services => $state.composableBuilder(
      column: $state.table.services,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get delinquent => $state.composableBuilder(
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

  ColumnOrderings<BigInt> get usedSpace => $state.composableBuilder(
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

  ColumnOrderings<BigInt> get createTime => $state.composableBuilder(
      column: $state.table.createTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<BigInt> get maxSpace => $state.composableBuilder(
      column: $state.table.maxSpace,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<BigInt> get maxUpload => $state.composableBuilder(
      column: $state.table.maxUpload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get private => $state.composableBuilder(
      column: $state.table.private,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get subscribed => $state.composableBuilder(
      column: $state.table.subscribed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get services => $state.composableBuilder(
      column: $state.table.services,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get delinquent => $state.composableBuilder(
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

typedef $$UserKeysTableTableCreateCompanionBuilder = UserKeysTableCompanion
    Function({
  required String keyId,
  required String userId,
  required int version,
  required String privateKey,
  Value<String?> token,
  Value<String?> fingerprint,
  Value<String?> recoverySecret,
  Value<String?> recoverySecretSignature,
  required int primary,
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
  Value<String?> recoverySecret,
  Value<String?> recoverySecretSignature,
  Value<int> primary,
  Value<int> rowid,
});

class $$UserKeysTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserKeysTableTable,
    DriftUserKey,
    $$UserKeysTableTableFilterComposer,
    $$UserKeysTableTableOrderingComposer,
    $$UserKeysTableTableCreateCompanionBuilder,
    $$UserKeysTableTableUpdateCompanionBuilder> {
  $$UserKeysTableTableTableManager(_$AppDatabase db, $UserKeysTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserKeysTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserKeysTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> keyId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> privateKey = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<String?> fingerprint = const Value.absent(),
            Value<String?> recoverySecret = const Value.absent(),
            Value<String?> recoverySecretSignature = const Value.absent(),
            Value<int> primary = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserKeysTableCompanion(
            keyId: keyId,
            userId: userId,
            version: version,
            privateKey: privateKey,
            token: token,
            fingerprint: fingerprint,
            recoverySecret: recoverySecret,
            recoverySecretSignature: recoverySecretSignature,
            primary: primary,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String keyId,
            required String userId,
            required int version,
            required String privateKey,
            Value<String?> token = const Value.absent(),
            Value<String?> fingerprint = const Value.absent(),
            Value<String?> recoverySecret = const Value.absent(),
            Value<String?> recoverySecretSignature = const Value.absent(),
            required int primary,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserKeysTableCompanion.insert(
            keyId: keyId,
            userId: userId,
            version: version,
            privateKey: privateKey,
            token: token,
            fingerprint: fingerprint,
            recoverySecret: recoverySecret,
            recoverySecretSignature: recoverySecretSignature,
            primary: primary,
            rowid: rowid,
          ),
        ));
}

class $$UserKeysTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserKeysTableTable> {
  $$UserKeysTableTableFilterComposer(super.$state);
  ColumnFilters<String> get keyId => $state.composableBuilder(
      column: $state.table.keyId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
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

  ColumnFilters<String> get recoverySecret => $state.composableBuilder(
      column: $state.table.recoverySecret,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recoverySecretSignature => $state.composableBuilder(
      column: $state.table.recoverySecretSignature,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get primary => $state.composableBuilder(
      column: $state.table.primary,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserKeysTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserKeysTableTable> {
  $$UserKeysTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get keyId => $state.composableBuilder(
      column: $state.table.keyId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
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

  ColumnOrderings<String> get recoverySecret => $state.composableBuilder(
      column: $state.table.recoverySecret,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recoverySecretSignature =>
      $state.composableBuilder(
          column: $state.table.recoverySecretSignature,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get primary => $state.composableBuilder(
      column: $state.table.primary,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WalletUserSettingsTableTableCreateCompanionBuilder
    = WalletUserSettingsTableCompanion Function({
  required String userId,
  required String bitcoinUnit,
  required String fiatCurrency,
  required bool hideEmptyUsedAddresses,
  required bool showWalletRecovery,
  required double twoFactorAmountThreshold,
  required bool receiveInviterNotification,
  required bool receiveEmailIntegrationNotification,
  required bool walletCreated,
  required bool acceptTermsAndConditions,
  Value<int> rowid,
});
typedef $$WalletUserSettingsTableTableUpdateCompanionBuilder
    = WalletUserSettingsTableCompanion Function({
  Value<String> userId,
  Value<String> bitcoinUnit,
  Value<String> fiatCurrency,
  Value<bool> hideEmptyUsedAddresses,
  Value<bool> showWalletRecovery,
  Value<double> twoFactorAmountThreshold,
  Value<bool> receiveInviterNotification,
  Value<bool> receiveEmailIntegrationNotification,
  Value<bool> walletCreated,
  Value<bool> acceptTermsAndConditions,
  Value<int> rowid,
});

class $$WalletUserSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WalletUserSettingsTableTable,
    WalletUserSettings,
    $$WalletUserSettingsTableTableFilterComposer,
    $$WalletUserSettingsTableTableOrderingComposer,
    $$WalletUserSettingsTableTableCreateCompanionBuilder,
    $$WalletUserSettingsTableTableUpdateCompanionBuilder> {
  $$WalletUserSettingsTableTableTableManager(
      _$AppDatabase db, $WalletUserSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$WalletUserSettingsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$WalletUserSettingsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> bitcoinUnit = const Value.absent(),
            Value<String> fiatCurrency = const Value.absent(),
            Value<bool> hideEmptyUsedAddresses = const Value.absent(),
            Value<bool> showWalletRecovery = const Value.absent(),
            Value<double> twoFactorAmountThreshold = const Value.absent(),
            Value<bool> receiveInviterNotification = const Value.absent(),
            Value<bool> receiveEmailIntegrationNotification =
                const Value.absent(),
            Value<bool> walletCreated = const Value.absent(),
            Value<bool> acceptTermsAndConditions = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WalletUserSettingsTableCompanion(
            userId: userId,
            bitcoinUnit: bitcoinUnit,
            fiatCurrency: fiatCurrency,
            hideEmptyUsedAddresses: hideEmptyUsedAddresses,
            showWalletRecovery: showWalletRecovery,
            twoFactorAmountThreshold: twoFactorAmountThreshold,
            receiveInviterNotification: receiveInviterNotification,
            receiveEmailIntegrationNotification:
                receiveEmailIntegrationNotification,
            walletCreated: walletCreated,
            acceptTermsAndConditions: acceptTermsAndConditions,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String bitcoinUnit,
            required String fiatCurrency,
            required bool hideEmptyUsedAddresses,
            required bool showWalletRecovery,
            required double twoFactorAmountThreshold,
            required bool receiveInviterNotification,
            required bool receiveEmailIntegrationNotification,
            required bool walletCreated,
            required bool acceptTermsAndConditions,
            Value<int> rowid = const Value.absent(),
          }) =>
              WalletUserSettingsTableCompanion.insert(
            userId: userId,
            bitcoinUnit: bitcoinUnit,
            fiatCurrency: fiatCurrency,
            hideEmptyUsedAddresses: hideEmptyUsedAddresses,
            showWalletRecovery: showWalletRecovery,
            twoFactorAmountThreshold: twoFactorAmountThreshold,
            receiveInviterNotification: receiveInviterNotification,
            receiveEmailIntegrationNotification:
                receiveEmailIntegrationNotification,
            walletCreated: walletCreated,
            acceptTermsAndConditions: acceptTermsAndConditions,
            rowid: rowid,
          ),
        ));
}

class $$WalletUserSettingsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WalletUserSettingsTableTable> {
  $$WalletUserSettingsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bitcoinUnit => $state.composableBuilder(
      column: $state.table.bitcoinUnit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fiatCurrency => $state.composableBuilder(
      column: $state.table.fiatCurrency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get hideEmptyUsedAddresses => $state.composableBuilder(
      column: $state.table.hideEmptyUsedAddresses,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get showWalletRecovery => $state.composableBuilder(
      column: $state.table.showWalletRecovery,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get twoFactorAmountThreshold =>
      $state.composableBuilder(
          column: $state.table.twoFactorAmountThreshold,
          builder: (column, joinBuilders) =>
              ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get receiveInviterNotification =>
      $state.composableBuilder(
          column: $state.table.receiveInviterNotification,
          builder: (column, joinBuilders) =>
              ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get receiveEmailIntegrationNotification =>
      $state.composableBuilder(
          column: $state.table.receiveEmailIntegrationNotification,
          builder: (column, joinBuilders) =>
              ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get walletCreated => $state.composableBuilder(
      column: $state.table.walletCreated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get acceptTermsAndConditions => $state.composableBuilder(
      column: $state.table.acceptTermsAndConditions,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WalletUserSettingsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WalletUserSettingsTableTable> {
  $$WalletUserSettingsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bitcoinUnit => $state.composableBuilder(
      column: $state.table.bitcoinUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fiatCurrency => $state.composableBuilder(
      column: $state.table.fiatCurrency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get hideEmptyUsedAddresses => $state.composableBuilder(
      column: $state.table.hideEmptyUsedAddresses,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get showWalletRecovery => $state.composableBuilder(
      column: $state.table.showWalletRecovery,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get twoFactorAmountThreshold =>
      $state.composableBuilder(
          column: $state.table.twoFactorAmountThreshold,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get receiveInviterNotification =>
      $state.composableBuilder(
          column: $state.table.receiveInviterNotification,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get receiveEmailIntegrationNotification =>
      $state.composableBuilder(
          column: $state.table.receiveEmailIntegrationNotification,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get walletCreated => $state.composableBuilder(
      column: $state.table.walletCreated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get acceptTermsAndConditions =>
      $state.composableBuilder(
          column: $state.table.acceptTermsAndConditions,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$UserKeysTableTableTableManager get userKeysTable =>
      $$UserKeysTableTableTableManager(_db, _db.userKeysTable);
  $$WalletUserSettingsTableTableTableManager get walletUserSettingsTable =>
      $$WalletUserSettingsTableTableTableManager(
          _db, _db.walletUserSettingsTable);
}
