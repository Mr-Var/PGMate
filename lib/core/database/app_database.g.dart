// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PgProfilesTable extends PgProfiles with TableInfo<$PgProfilesTable, PgProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PgProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta('ownerName');
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerPhoneMeta = const VerificationMeta('ownerPhone');
  @override
  late final GeneratedColumn<String> ownerPhone = GeneratedColumn<String>(
    'owner_phone',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 15),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
    'upi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultRentDueDayMeta = const VerificationMeta('defaultRentDueDay');
  @override
  late final GeneratedColumn<int> defaultRentDueDay = GeneratedColumn<int>(
    'default_rent_due_day',
    aliasedName,
    false,
    check: () => ComparableExpr(defaultRentDueDay).isBetweenValues(1, 28),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    ownerName,
    ownerPhone,
    upiId,
    defaultRentDueDay,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pg_profile';
  @override
  VerificationContext validateIntegrity(Insertable<PgProfile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta, address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(_ownerNameMeta, ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta));
    } else if (isInserting) {
      context.missing(_ownerNameMeta);
    }
    if (data.containsKey('owner_phone')) {
      context.handle(_ownerPhoneMeta, ownerPhone.isAcceptableOrUnknown(data['owner_phone']!, _ownerPhoneMeta));
    } else if (isInserting) {
      context.missing(_ownerPhoneMeta);
    }
    if (data.containsKey('upi_id')) {
      context.handle(_upiIdMeta, upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta));
    }
    if (data.containsKey('default_rent_due_day')) {
      context.handle(
        _defaultRentDueDayMeta,
        defaultRentDueDay.isAcceptableOrUnknown(data['default_rent_due_day']!, _defaultRentDueDayMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PgProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PgProfile(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      ownerName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}owner_name'])!,
      ownerPhone: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}owner_phone'])!,
      upiId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}upi_id']),
      defaultRentDueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_rent_due_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PgProfilesTable createAlias(String alias) {
    return $PgProfilesTable(attachedDatabase, alias);
  }
}

class PgProfile extends DataClass implements Insertable<PgProfile> {
  final int id;
  final String name;
  final String address;
  final String ownerName;
  final String ownerPhone;
  final String? upiId;
  final int defaultRentDueDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PgProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    this.upiId,
    required this.defaultRentDueDay,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['owner_name'] = Variable<String>(ownerName);
    map['owner_phone'] = Variable<String>(ownerPhone);
    if (!nullToAbsent || upiId != null) {
      map['upi_id'] = Variable<String>(upiId);
    }
    map['default_rent_due_day'] = Variable<int>(defaultRentDueDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PgProfilesCompanion toCompanion(bool nullToAbsent) {
    return PgProfilesCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      ownerName: Value(ownerName),
      ownerPhone: Value(ownerPhone),
      upiId: upiId == null && nullToAbsent ? const Value.absent() : Value(upiId),
      defaultRentDueDay: Value(defaultRentDueDay),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PgProfile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PgProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      ownerName: serializer.fromJson<String>(json['ownerName']),
      ownerPhone: serializer.fromJson<String>(json['ownerPhone']),
      upiId: serializer.fromJson<String?>(json['upiId']),
      defaultRentDueDay: serializer.fromJson<int>(json['defaultRentDueDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'ownerName': serializer.toJson<String>(ownerName),
      'ownerPhone': serializer.toJson<String>(ownerPhone),
      'upiId': serializer.toJson<String?>(upiId),
      'defaultRentDueDay': serializer.toJson<int>(defaultRentDueDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PgProfile copyWith({
    int? id,
    String? name,
    String? address,
    String? ownerName,
    String? ownerPhone,
    Value<String?> upiId = const Value.absent(),
    int? defaultRentDueDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PgProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    ownerName: ownerName ?? this.ownerName,
    ownerPhone: ownerPhone ?? this.ownerPhone,
    upiId: upiId.present ? upiId.value : this.upiId,
    defaultRentDueDay: defaultRentDueDay ?? this.defaultRentDueDay,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PgProfile copyWithCompanion(PgProfilesCompanion data) {
    return PgProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      ownerPhone: data.ownerPhone.present ? data.ownerPhone.value : this.ownerPhone,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      defaultRentDueDay: data.defaultRentDueDay.present ? data.defaultRentDueDay.value : this.defaultRentDueDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PgProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerPhone: $ownerPhone, ')
          ..write('upiId: $upiId, ')
          ..write('defaultRentDueDay: $defaultRentDueDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, ownerName, ownerPhone, upiId, defaultRentDueDay, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PgProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.ownerName == this.ownerName &&
          other.ownerPhone == this.ownerPhone &&
          other.upiId == this.upiId &&
          other.defaultRentDueDay == this.defaultRentDueDay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PgProfilesCompanion extends UpdateCompanion<PgProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> address;
  final Value<String> ownerName;
  final Value<String> ownerPhone;
  final Value<String?> upiId;
  final Value<int> defaultRentDueDay;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PgProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.ownerPhone = const Value.absent(),
    this.upiId = const Value.absent(),
    this.defaultRentDueDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PgProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String address,
    required String ownerName,
    required String ownerPhone,
    this.upiId = const Value.absent(),
    this.defaultRentDueDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       address = Value(address),
       ownerName = Value(ownerName),
       ownerPhone = Value(ownerPhone);
  static Insertable<PgProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? ownerName,
    Expression<String>? ownerPhone,
    Expression<String>? upiId,
    Expression<int>? defaultRentDueDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerPhone != null) 'owner_phone': ownerPhone,
      if (upiId != null) 'upi_id': upiId,
      if (defaultRentDueDay != null) 'default_rent_due_day': defaultRentDueDay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PgProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? address,
    Value<String>? ownerName,
    Value<String>? ownerPhone,
    Value<String?>? upiId,
    Value<int>? defaultRentDueDay,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PgProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      upiId: upiId ?? this.upiId,
      defaultRentDueDay: defaultRentDueDay ?? this.defaultRentDueDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (ownerPhone.present) {
      map['owner_phone'] = Variable<String>(ownerPhone.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (defaultRentDueDay.present) {
      map['default_rent_due_day'] = Variable<int>(defaultRentDueDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PgProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerPhone: $ownerPhone, ')
          ..write('upiId: $upiId, ')
          ..write('defaultRentDueDay: $defaultRentDueDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta('roomNumber');
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
    'room_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _floorMeta = const VerificationMeta('floor');
  @override
  late final GeneratedColumn<int> floor = GeneratedColumn<int>(
    'floor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentPaiseMeta = const VerificationMeta('rentPaise');
  @override
  late final GeneratedColumn<int> rentPaise = GeneratedColumn<int>(
    'rent_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(rentPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, roomNumber, floor, rentPaise, notes, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_number')) {
      context.handle(_roomNumberMeta, roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta));
    } else if (isInserting) {
      context.missing(_roomNumberMeta);
    }
    if (data.containsKey('floor')) {
      context.handle(_floorMeta, floor.isAcceptableOrUnknown(data['floor']!, _floorMeta));
    } else if (isInserting) {
      context.missing(_floorMeta);
    }
    if (data.containsKey('rent_paise')) {
      context.handle(_rentPaiseMeta, rentPaise.isAcceptableOrUnknown(data['rent_paise']!, _rentPaiseMeta));
    } else if (isInserting) {
      context.missing(_rentPaiseMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta, isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      roomNumber: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}room_number'])!,
      floor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}floor'])!,
      rentPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rent_paise'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isActive: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final int id;
  final String roomNumber;
  final int floor;

  /// Default monthly rent per bed in this room, in paise.
  final int rentPaise;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Room({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.rentPaise,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room_number'] = Variable<String>(roomNumber);
    map['floor'] = Variable<int>(floor);
    map['rent_paise'] = Variable<int>(rentPaise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      roomNumber: Value(roomNumber),
      floor: Value(floor),
      rentPaise: Value(rentPaise),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<int>(json['id']),
      roomNumber: serializer.fromJson<String>(json['roomNumber']),
      floor: serializer.fromJson<int>(json['floor']),
      rentPaise: serializer.fromJson<int>(json['rentPaise']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roomNumber': serializer.toJson<String>(roomNumber),
      'floor': serializer.toJson<int>(floor),
      'rentPaise': serializer.toJson<int>(rentPaise),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Room copyWith({
    int? id,
    String? roomNumber,
    int? floor,
    int? rentPaise,
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Room(
    id: id ?? this.id,
    roomNumber: roomNumber ?? this.roomNumber,
    floor: floor ?? this.floor,
    rentPaise: rentPaise ?? this.rentPaise,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      roomNumber: data.roomNumber.present ? data.roomNumber.value : this.roomNumber,
      floor: data.floor.present ? data.floor.value : this.floor,
      rentPaise: data.rentPaise.present ? data.rentPaise.value : this.rentPaise,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('floor: $floor, ')
          ..write('rentPaise: $rentPaise, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomNumber, floor, rentPaise, notes, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.roomNumber == this.roomNumber &&
          other.floor == this.floor &&
          other.rentPaise == this.rentPaise &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<int> id;
  final Value<String> roomNumber;
  final Value<int> floor;
  final Value<int> rentPaise;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.floor = const Value.absent(),
    this.rentPaise = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.id = const Value.absent(),
    required String roomNumber,
    required int floor,
    required int rentPaise,
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : roomNumber = Value(roomNumber),
       floor = Value(floor),
       rentPaise = Value(rentPaise);
  static Insertable<Room> custom({
    Expression<int>? id,
    Expression<String>? roomNumber,
    Expression<int>? floor,
    Expression<int>? rentPaise,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomNumber != null) 'room_number': roomNumber,
      if (floor != null) 'floor': floor,
      if (rentPaise != null) 'rent_paise': rentPaise,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RoomsCompanion copyWith({
    Value<int>? id,
    Value<String>? roomNumber,
    Value<int>? floor,
    Value<int>? rentPaise,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      rentPaise: rentPaise ?? this.rentPaise,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (floor.present) {
      map['floor'] = Variable<int>(floor.value);
    }
    if (rentPaise.present) {
      map['rent_paise'] = Variable<int>(rentPaise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('floor: $floor, ')
          ..write('rentPaise: $rentPaise, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BedsTable extends Beds with TableInfo<$BedsTable, Bed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES rooms (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BedStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(BedStatus.available.name),
  ).withConverter<BedStatus>($BedsTable.$converterstatus);
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, roomId, label, status, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beds';
  @override
  VerificationContext validateIntegrity(Insertable<Bed> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta, roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta, isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {roomId, label},
  ];
  @override
  Bed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bed(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      roomId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      status: $BedsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      isActive: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BedsTable createAlias(String alias) {
    return $BedsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BedStatus, String, String> $converterstatus = const EnumNameConverter<BedStatus>(
    BedStatus.values,
  );
}

class Bed extends DataClass implements Insertable<Bed> {
  final int id;
  final int roomId;
  final String label;
  final BedStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Bed({
    required this.id,
    required this.roomId,
    required this.label,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room_id'] = Variable<int>(roomId);
    map['label'] = Variable<String>(label);
    {
      map['status'] = Variable<String>($BedsTable.$converterstatus.toSql(status));
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BedsCompanion toCompanion(bool nullToAbsent) {
    return BedsCompanion(
      id: Value(id),
      roomId: Value(roomId),
      label: Value(label),
      status: Value(status),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Bed.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bed(
      id: serializer.fromJson<int>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      label: serializer.fromJson<String>(json['label']),
      status: $BedsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roomId': serializer.toJson<int>(roomId),
      'label': serializer.toJson<String>(label),
      'status': serializer.toJson<String>($BedsTable.$converterstatus.toJson(status)),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Bed copyWith({
    int? id,
    int? roomId,
    String? label,
    BedStatus? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Bed(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    label: label ?? this.label,
    status: status ?? this.status,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Bed copyWithCompanion(BedsCompanion data) {
    return Bed(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      label: data.label.present ? data.label.value : this.label,
      status: data.status.present ? data.status.value : this.status,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bed(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, label, status, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bed &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.label == this.label &&
          other.status == this.status &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BedsCompanion extends UpdateCompanion<Bed> {
  final Value<int> id;
  final Value<int> roomId;
  final Value<String> label;
  final Value<BedStatus> status;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BedsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BedsCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required String label,
    this.status = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : roomId = Value(roomId),
       label = Value(label);
  static Insertable<Bed> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<String>? label,
    Expression<String>? status,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BedsCompanion copyWith({
    Value<int>? id,
    Value<int>? roomId,
    Value<String>? label,
    Value<BedStatus>? status,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BedsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      label: label ?? this.label,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($BedsTable.$converterstatus.toSql(status.value));
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BedsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TenantsTable extends Tenants with TableInfo<$TenantsTable, Tenant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 15),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Gender, String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Gender>($TenantsTable.$convertergender);
  static const VerificationMeta _photoPathMeta = const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idProofTypeMeta = const VerificationMeta('idProofType');
  @override
  late final GeneratedColumn<String> idProofType = GeneratedColumn<String>(
    'id_proof_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idProofNumberMeta = const VerificationMeta('idProofNumber');
  @override
  late final GeneratedColumn<String> idProofNumber = GeneratedColumn<String>(
    'id_proof_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idProofPathMeta = const VerificationMeta('idProofPath');
  @override
  late final GeneratedColumn<String> idProofPath = GeneratedColumn<String>(
    'id_proof_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactNameMeta = const VerificationMeta('emergencyContactName');
  @override
  late final GeneratedColumn<String> emergencyContactName = GeneratedColumn<String>(
    'emergency_contact_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactPhoneMeta = const VerificationMeta('emergencyContactPhone');
  @override
  late final GeneratedColumn<String> emergencyContactPhone = GeneratedColumn<String>(
    'emergency_contact_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occupationMeta = const VerificationMeta('occupation');
  @override
  late final GeneratedColumn<String> occupation = GeneratedColumn<String>(
    'occupation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joiningDateMeta = const VerificationMeta('joiningDate');
  @override
  late final GeneratedColumn<DateTime> joiningDate = GeneratedColumn<DateTime>(
    'joining_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyRentPaiseMeta = const VerificationMeta('monthlyRentPaise');
  @override
  late final GeneratedColumn<int> monthlyRentPaise = GeneratedColumn<int>(
    'monthly_rent_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(monthlyRentPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _securityDepositPaiseMeta = const VerificationMeta('securityDepositPaise');
  @override
  late final GeneratedColumn<int> securityDepositPaise = GeneratedColumn<int>(
    'security_deposit_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(securityDepositPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _advancePaiseMeta = const VerificationMeta('advancePaise');
  @override
  late final GeneratedColumn<int> advancePaise = GeneratedColumn<int>(
    'advance_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(advancePaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rentDueDayMeta = const VerificationMeta('rentDueDay');
  @override
  late final GeneratedColumn<int> rentDueDay = GeneratedColumn<int>(
    'rent_due_day',
    aliasedName,
    false,
    check: () => ComparableExpr(rentDueDay).isBetweenValues(1, 28),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TenantStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TenantStatus.newTenant.name),
  ).withConverter<TenantStatus>($TenantsTable.$converterstatus);
  static const VerificationMeta _noticeDateMeta = const VerificationMeta('noticeDate');
  @override
  late final GeneratedColumn<DateTime> noticeDate = GeneratedColumn<DateTime>(
    'notice_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedCheckoutDateMeta = const VerificationMeta('expectedCheckoutDate');
  @override
  late final GeneratedColumn<DateTime> expectedCheckoutDate = GeneratedColumn<DateTime>(
    'expected_checkout_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkoutDateMeta = const VerificationMeta('checkoutDate');
  @override
  late final GeneratedColumn<DateTime> checkoutDate = GeneratedColumn<DateTime>(
    'checkout_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositAdjustedPaiseMeta = const VerificationMeta('depositAdjustedPaise');
  @override
  late final GeneratedColumn<int> depositAdjustedPaise = GeneratedColumn<int>(
    'deposit_adjusted_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _depositRefundedPaiseMeta = const VerificationMeta('depositRefundedPaise');
  @override
  late final GeneratedColumn<int> depositRefundedPaise = GeneratedColumn<int>(
    'deposit_refunded_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _checkoutNotesMeta = const VerificationMeta('checkoutNotes');
  @override
  late final GeneratedColumn<String> checkoutNotes = GeneratedColumn<String>(
    'checkout_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    phone,
    email,
    gender,
    photoPath,
    idProofType,
    idProofNumber,
    idProofPath,
    emergencyContactName,
    emergencyContactPhone,
    occupation,
    joiningDate,
    monthlyRentPaise,
    securityDepositPaise,
    advancePaise,
    rentDueDay,
    status,
    noticeDate,
    expectedCheckoutDate,
    checkoutDate,
    depositAdjustedPaise,
    depositRefundedPaise,
    checkoutNotes,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenants';
  @override
  VerificationContext validateIntegrity(Insertable<Tenant> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta, fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(_phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(_emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta, photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('id_proof_type')) {
      context.handle(_idProofTypeMeta, idProofType.isAcceptableOrUnknown(data['id_proof_type']!, _idProofTypeMeta));
    }
    if (data.containsKey('id_proof_number')) {
      context.handle(
        _idProofNumberMeta,
        idProofNumber.isAcceptableOrUnknown(data['id_proof_number']!, _idProofNumberMeta),
      );
    }
    if (data.containsKey('id_proof_path')) {
      context.handle(_idProofPathMeta, idProofPath.isAcceptableOrUnknown(data['id_proof_path']!, _idProofPathMeta));
    }
    if (data.containsKey('emergency_contact_name')) {
      context.handle(
        _emergencyContactNameMeta,
        emergencyContactName.isAcceptableOrUnknown(data['emergency_contact_name']!, _emergencyContactNameMeta),
      );
    }
    if (data.containsKey('emergency_contact_phone')) {
      context.handle(
        _emergencyContactPhoneMeta,
        emergencyContactPhone.isAcceptableOrUnknown(data['emergency_contact_phone']!, _emergencyContactPhoneMeta),
      );
    }
    if (data.containsKey('occupation')) {
      context.handle(_occupationMeta, occupation.isAcceptableOrUnknown(data['occupation']!, _occupationMeta));
    }
    if (data.containsKey('joining_date')) {
      context.handle(_joiningDateMeta, joiningDate.isAcceptableOrUnknown(data['joining_date']!, _joiningDateMeta));
    } else if (isInserting) {
      context.missing(_joiningDateMeta);
    }
    if (data.containsKey('monthly_rent_paise')) {
      context.handle(
        _monthlyRentPaiseMeta,
        monthlyRentPaise.isAcceptableOrUnknown(data['monthly_rent_paise']!, _monthlyRentPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_monthlyRentPaiseMeta);
    }
    if (data.containsKey('security_deposit_paise')) {
      context.handle(
        _securityDepositPaiseMeta,
        securityDepositPaise.isAcceptableOrUnknown(data['security_deposit_paise']!, _securityDepositPaiseMeta),
      );
    }
    if (data.containsKey('advance_paise')) {
      context.handle(_advancePaiseMeta, advancePaise.isAcceptableOrUnknown(data['advance_paise']!, _advancePaiseMeta));
    }
    if (data.containsKey('rent_due_day')) {
      context.handle(_rentDueDayMeta, rentDueDay.isAcceptableOrUnknown(data['rent_due_day']!, _rentDueDayMeta));
    } else if (isInserting) {
      context.missing(_rentDueDayMeta);
    }
    if (data.containsKey('notice_date')) {
      context.handle(_noticeDateMeta, noticeDate.isAcceptableOrUnknown(data['notice_date']!, _noticeDateMeta));
    }
    if (data.containsKey('expected_checkout_date')) {
      context.handle(
        _expectedCheckoutDateMeta,
        expectedCheckoutDate.isAcceptableOrUnknown(data['expected_checkout_date']!, _expectedCheckoutDateMeta),
      );
    }
    if (data.containsKey('checkout_date')) {
      context.handle(_checkoutDateMeta, checkoutDate.isAcceptableOrUnknown(data['checkout_date']!, _checkoutDateMeta));
    }
    if (data.containsKey('deposit_adjusted_paise')) {
      context.handle(
        _depositAdjustedPaiseMeta,
        depositAdjustedPaise.isAcceptableOrUnknown(data['deposit_adjusted_paise']!, _depositAdjustedPaiseMeta),
      );
    }
    if (data.containsKey('deposit_refunded_paise')) {
      context.handle(
        _depositRefundedPaiseMeta,
        depositRefundedPaise.isAcceptableOrUnknown(data['deposit_refunded_paise']!, _depositRefundedPaiseMeta),
      );
    }
    if (data.containsKey('checkout_notes')) {
      context.handle(
        _checkoutNotesMeta,
        checkoutNotes.isAcceptableOrUnknown(data['checkout_notes']!, _checkoutNotesMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tenant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tenant(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      phone: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}email']),
      gender: $TenantsTable.$convertergender.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      ),
      photoPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      idProofType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id_proof_type']),
      idProofNumber: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id_proof_number']),
      idProofPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id_proof_path']),
      emergencyContactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact_name'],
      ),
      emergencyContactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact_phone'],
      ),
      occupation: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}occupation']),
      joiningDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}joining_date'])!,
      monthlyRentPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_rent_paise'],
      )!,
      securityDepositPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}security_deposit_paise'],
      )!,
      advancePaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}advance_paise'])!,
      rentDueDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rent_due_day'])!,
      status: $TenantsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      noticeDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}notice_date']),
      expectedCheckoutDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_checkout_date'],
      ),
      checkoutDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}checkout_date']),
      depositAdjustedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit_adjusted_paise'],
      )!,
      depositRefundedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit_refunded_paise'],
      )!,
      checkoutNotes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}checkout_notes']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TenantsTable createAlias(String alias) {
    return $TenantsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Gender, String, String> $convertergender = const EnumNameConverter<Gender>(Gender.values);
  static JsonTypeConverter2<TenantStatus, String, String> $converterstatus = const EnumNameConverter<TenantStatus>(
    TenantStatus.values,
  );
}

class Tenant extends DataClass implements Insertable<Tenant> {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final Gender gender;

  /// Path relative to the app's private documents directory.
  final String? photoPath;
  final String? idProofType;
  final String? idProofNumber;
  final String? idProofPath;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? occupation;
  final DateTime joiningDate;
  final int monthlyRentPaise;
  final int securityDepositPaise;
  final int advancePaise;
  final int rentDueDay;
  final TenantStatus status;
  final DateTime? noticeDate;
  final DateTime? expectedCheckoutDate;
  final DateTime? checkoutDate;

  /// Part of the deposit used to settle dues at checkout.
  final int depositAdjustedPaise;

  /// Part of the deposit returned to the tenant at checkout.
  final int depositRefundedPaise;
  final String? checkoutNotes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tenant({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.gender,
    this.photoPath,
    this.idProofType,
    this.idProofNumber,
    this.idProofPath,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.occupation,
    required this.joiningDate,
    required this.monthlyRentPaise,
    required this.securityDepositPaise,
    required this.advancePaise,
    required this.rentDueDay,
    required this.status,
    this.noticeDate,
    this.expectedCheckoutDate,
    this.checkoutDate,
    required this.depositAdjustedPaise,
    required this.depositRefundedPaise,
    this.checkoutNotes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    {
      map['gender'] = Variable<String>($TenantsTable.$convertergender.toSql(gender));
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || idProofType != null) {
      map['id_proof_type'] = Variable<String>(idProofType);
    }
    if (!nullToAbsent || idProofNumber != null) {
      map['id_proof_number'] = Variable<String>(idProofNumber);
    }
    if (!nullToAbsent || idProofPath != null) {
      map['id_proof_path'] = Variable<String>(idProofPath);
    }
    if (!nullToAbsent || emergencyContactName != null) {
      map['emergency_contact_name'] = Variable<String>(emergencyContactName);
    }
    if (!nullToAbsent || emergencyContactPhone != null) {
      map['emergency_contact_phone'] = Variable<String>(emergencyContactPhone);
    }
    if (!nullToAbsent || occupation != null) {
      map['occupation'] = Variable<String>(occupation);
    }
    map['joining_date'] = Variable<DateTime>(joiningDate);
    map['monthly_rent_paise'] = Variable<int>(monthlyRentPaise);
    map['security_deposit_paise'] = Variable<int>(securityDepositPaise);
    map['advance_paise'] = Variable<int>(advancePaise);
    map['rent_due_day'] = Variable<int>(rentDueDay);
    {
      map['status'] = Variable<String>($TenantsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || noticeDate != null) {
      map['notice_date'] = Variable<DateTime>(noticeDate);
    }
    if (!nullToAbsent || expectedCheckoutDate != null) {
      map['expected_checkout_date'] = Variable<DateTime>(expectedCheckoutDate);
    }
    if (!nullToAbsent || checkoutDate != null) {
      map['checkout_date'] = Variable<DateTime>(checkoutDate);
    }
    map['deposit_adjusted_paise'] = Variable<int>(depositAdjustedPaise);
    map['deposit_refunded_paise'] = Variable<int>(depositRefundedPaise);
    if (!nullToAbsent || checkoutNotes != null) {
      map['checkout_notes'] = Variable<String>(checkoutNotes);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TenantsCompanion toCompanion(bool nullToAbsent) {
    return TenantsCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phone: Value(phone),
      email: email == null && nullToAbsent ? const Value.absent() : Value(email),
      gender: Value(gender),
      photoPath: photoPath == null && nullToAbsent ? const Value.absent() : Value(photoPath),
      idProofType: idProofType == null && nullToAbsent ? const Value.absent() : Value(idProofType),
      idProofNumber: idProofNumber == null && nullToAbsent ? const Value.absent() : Value(idProofNumber),
      idProofPath: idProofPath == null && nullToAbsent ? const Value.absent() : Value(idProofPath),
      emergencyContactName: emergencyContactName == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContactName),
      emergencyContactPhone: emergencyContactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContactPhone),
      occupation: occupation == null && nullToAbsent ? const Value.absent() : Value(occupation),
      joiningDate: Value(joiningDate),
      monthlyRentPaise: Value(monthlyRentPaise),
      securityDepositPaise: Value(securityDepositPaise),
      advancePaise: Value(advancePaise),
      rentDueDay: Value(rentDueDay),
      status: Value(status),
      noticeDate: noticeDate == null && nullToAbsent ? const Value.absent() : Value(noticeDate),
      expectedCheckoutDate: expectedCheckoutDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCheckoutDate),
      checkoutDate: checkoutDate == null && nullToAbsent ? const Value.absent() : Value(checkoutDate),
      depositAdjustedPaise: Value(depositAdjustedPaise),
      depositRefundedPaise: Value(depositRefundedPaise),
      checkoutNotes: checkoutNotes == null && nullToAbsent ? const Value.absent() : Value(checkoutNotes),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tenant.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tenant(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      gender: $TenantsTable.$convertergender.fromJson(serializer.fromJson<String>(json['gender'])),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      idProofType: serializer.fromJson<String?>(json['idProofType']),
      idProofNumber: serializer.fromJson<String?>(json['idProofNumber']),
      idProofPath: serializer.fromJson<String?>(json['idProofPath']),
      emergencyContactName: serializer.fromJson<String?>(json['emergencyContactName']),
      emergencyContactPhone: serializer.fromJson<String?>(json['emergencyContactPhone']),
      occupation: serializer.fromJson<String?>(json['occupation']),
      joiningDate: serializer.fromJson<DateTime>(json['joiningDate']),
      monthlyRentPaise: serializer.fromJson<int>(json['monthlyRentPaise']),
      securityDepositPaise: serializer.fromJson<int>(json['securityDepositPaise']),
      advancePaise: serializer.fromJson<int>(json['advancePaise']),
      rentDueDay: serializer.fromJson<int>(json['rentDueDay']),
      status: $TenantsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      noticeDate: serializer.fromJson<DateTime?>(json['noticeDate']),
      expectedCheckoutDate: serializer.fromJson<DateTime?>(json['expectedCheckoutDate']),
      checkoutDate: serializer.fromJson<DateTime?>(json['checkoutDate']),
      depositAdjustedPaise: serializer.fromJson<int>(json['depositAdjustedPaise']),
      depositRefundedPaise: serializer.fromJson<int>(json['depositRefundedPaise']),
      checkoutNotes: serializer.fromJson<String?>(json['checkoutNotes']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'gender': serializer.toJson<String>($TenantsTable.$convertergender.toJson(gender)),
      'photoPath': serializer.toJson<String?>(photoPath),
      'idProofType': serializer.toJson<String?>(idProofType),
      'idProofNumber': serializer.toJson<String?>(idProofNumber),
      'idProofPath': serializer.toJson<String?>(idProofPath),
      'emergencyContactName': serializer.toJson<String?>(emergencyContactName),
      'emergencyContactPhone': serializer.toJson<String?>(emergencyContactPhone),
      'occupation': serializer.toJson<String?>(occupation),
      'joiningDate': serializer.toJson<DateTime>(joiningDate),
      'monthlyRentPaise': serializer.toJson<int>(monthlyRentPaise),
      'securityDepositPaise': serializer.toJson<int>(securityDepositPaise),
      'advancePaise': serializer.toJson<int>(advancePaise),
      'rentDueDay': serializer.toJson<int>(rentDueDay),
      'status': serializer.toJson<String>($TenantsTable.$converterstatus.toJson(status)),
      'noticeDate': serializer.toJson<DateTime?>(noticeDate),
      'expectedCheckoutDate': serializer.toJson<DateTime?>(expectedCheckoutDate),
      'checkoutDate': serializer.toJson<DateTime?>(checkoutDate),
      'depositAdjustedPaise': serializer.toJson<int>(depositAdjustedPaise),
      'depositRefundedPaise': serializer.toJson<int>(depositRefundedPaise),
      'checkoutNotes': serializer.toJson<String?>(checkoutNotes),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tenant copyWith({
    int? id,
    String? fullName,
    String? phone,
    Value<String?> email = const Value.absent(),
    Gender? gender,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> idProofType = const Value.absent(),
    Value<String?> idProofNumber = const Value.absent(),
    Value<String?> idProofPath = const Value.absent(),
    Value<String?> emergencyContactName = const Value.absent(),
    Value<String?> emergencyContactPhone = const Value.absent(),
    Value<String?> occupation = const Value.absent(),
    DateTime? joiningDate,
    int? monthlyRentPaise,
    int? securityDepositPaise,
    int? advancePaise,
    int? rentDueDay,
    TenantStatus? status,
    Value<DateTime?> noticeDate = const Value.absent(),
    Value<DateTime?> expectedCheckoutDate = const Value.absent(),
    Value<DateTime?> checkoutDate = const Value.absent(),
    int? depositAdjustedPaise,
    int? depositRefundedPaise,
    Value<String?> checkoutNotes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tenant(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    email: email.present ? email.value : this.email,
    gender: gender ?? this.gender,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    idProofType: idProofType.present ? idProofType.value : this.idProofType,
    idProofNumber: idProofNumber.present ? idProofNumber.value : this.idProofNumber,
    idProofPath: idProofPath.present ? idProofPath.value : this.idProofPath,
    emergencyContactName: emergencyContactName.present ? emergencyContactName.value : this.emergencyContactName,
    emergencyContactPhone: emergencyContactPhone.present ? emergencyContactPhone.value : this.emergencyContactPhone,
    occupation: occupation.present ? occupation.value : this.occupation,
    joiningDate: joiningDate ?? this.joiningDate,
    monthlyRentPaise: monthlyRentPaise ?? this.monthlyRentPaise,
    securityDepositPaise: securityDepositPaise ?? this.securityDepositPaise,
    advancePaise: advancePaise ?? this.advancePaise,
    rentDueDay: rentDueDay ?? this.rentDueDay,
    status: status ?? this.status,
    noticeDate: noticeDate.present ? noticeDate.value : this.noticeDate,
    expectedCheckoutDate: expectedCheckoutDate.present ? expectedCheckoutDate.value : this.expectedCheckoutDate,
    checkoutDate: checkoutDate.present ? checkoutDate.value : this.checkoutDate,
    depositAdjustedPaise: depositAdjustedPaise ?? this.depositAdjustedPaise,
    depositRefundedPaise: depositRefundedPaise ?? this.depositRefundedPaise,
    checkoutNotes: checkoutNotes.present ? checkoutNotes.value : this.checkoutNotes,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tenant copyWithCompanion(TenantsCompanion data) {
    return Tenant(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      gender: data.gender.present ? data.gender.value : this.gender,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      idProofType: data.idProofType.present ? data.idProofType.value : this.idProofType,
      idProofNumber: data.idProofNumber.present ? data.idProofNumber.value : this.idProofNumber,
      idProofPath: data.idProofPath.present ? data.idProofPath.value : this.idProofPath,
      emergencyContactName: data.emergencyContactName.present
          ? data.emergencyContactName.value
          : this.emergencyContactName,
      emergencyContactPhone: data.emergencyContactPhone.present
          ? data.emergencyContactPhone.value
          : this.emergencyContactPhone,
      occupation: data.occupation.present ? data.occupation.value : this.occupation,
      joiningDate: data.joiningDate.present ? data.joiningDate.value : this.joiningDate,
      monthlyRentPaise: data.monthlyRentPaise.present ? data.monthlyRentPaise.value : this.monthlyRentPaise,
      securityDepositPaise: data.securityDepositPaise.present
          ? data.securityDepositPaise.value
          : this.securityDepositPaise,
      advancePaise: data.advancePaise.present ? data.advancePaise.value : this.advancePaise,
      rentDueDay: data.rentDueDay.present ? data.rentDueDay.value : this.rentDueDay,
      status: data.status.present ? data.status.value : this.status,
      noticeDate: data.noticeDate.present ? data.noticeDate.value : this.noticeDate,
      expectedCheckoutDate: data.expectedCheckoutDate.present
          ? data.expectedCheckoutDate.value
          : this.expectedCheckoutDate,
      checkoutDate: data.checkoutDate.present ? data.checkoutDate.value : this.checkoutDate,
      depositAdjustedPaise: data.depositAdjustedPaise.present
          ? data.depositAdjustedPaise.value
          : this.depositAdjustedPaise,
      depositRefundedPaise: data.depositRefundedPaise.present
          ? data.depositRefundedPaise.value
          : this.depositRefundedPaise,
      checkoutNotes: data.checkoutNotes.present ? data.checkoutNotes.value : this.checkoutNotes,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tenant(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('gender: $gender, ')
          ..write('photoPath: $photoPath, ')
          ..write('idProofType: $idProofType, ')
          ..write('idProofNumber: $idProofNumber, ')
          ..write('idProofPath: $idProofPath, ')
          ..write('emergencyContactName: $emergencyContactName, ')
          ..write('emergencyContactPhone: $emergencyContactPhone, ')
          ..write('occupation: $occupation, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('monthlyRentPaise: $monthlyRentPaise, ')
          ..write('securityDepositPaise: $securityDepositPaise, ')
          ..write('advancePaise: $advancePaise, ')
          ..write('rentDueDay: $rentDueDay, ')
          ..write('status: $status, ')
          ..write('noticeDate: $noticeDate, ')
          ..write('expectedCheckoutDate: $expectedCheckoutDate, ')
          ..write('checkoutDate: $checkoutDate, ')
          ..write('depositAdjustedPaise: $depositAdjustedPaise, ')
          ..write('depositRefundedPaise: $depositRefundedPaise, ')
          ..write('checkoutNotes: $checkoutNotes, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    fullName,
    phone,
    email,
    gender,
    photoPath,
    idProofType,
    idProofNumber,
    idProofPath,
    emergencyContactName,
    emergencyContactPhone,
    occupation,
    joiningDate,
    monthlyRentPaise,
    securityDepositPaise,
    advancePaise,
    rentDueDay,
    status,
    noticeDate,
    expectedCheckoutDate,
    checkoutDate,
    depositAdjustedPaise,
    depositRefundedPaise,
    checkoutNotes,
    notes,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tenant &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.gender == this.gender &&
          other.photoPath == this.photoPath &&
          other.idProofType == this.idProofType &&
          other.idProofNumber == this.idProofNumber &&
          other.idProofPath == this.idProofPath &&
          other.emergencyContactName == this.emergencyContactName &&
          other.emergencyContactPhone == this.emergencyContactPhone &&
          other.occupation == this.occupation &&
          other.joiningDate == this.joiningDate &&
          other.monthlyRentPaise == this.monthlyRentPaise &&
          other.securityDepositPaise == this.securityDepositPaise &&
          other.advancePaise == this.advancePaise &&
          other.rentDueDay == this.rentDueDay &&
          other.status == this.status &&
          other.noticeDate == this.noticeDate &&
          other.expectedCheckoutDate == this.expectedCheckoutDate &&
          other.checkoutDate == this.checkoutDate &&
          other.depositAdjustedPaise == this.depositAdjustedPaise &&
          other.depositRefundedPaise == this.depositRefundedPaise &&
          other.checkoutNotes == this.checkoutNotes &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TenantsCompanion extends UpdateCompanion<Tenant> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String> phone;
  final Value<String?> email;
  final Value<Gender> gender;
  final Value<String?> photoPath;
  final Value<String?> idProofType;
  final Value<String?> idProofNumber;
  final Value<String?> idProofPath;
  final Value<String?> emergencyContactName;
  final Value<String?> emergencyContactPhone;
  final Value<String?> occupation;
  final Value<DateTime> joiningDate;
  final Value<int> monthlyRentPaise;
  final Value<int> securityDepositPaise;
  final Value<int> advancePaise;
  final Value<int> rentDueDay;
  final Value<TenantStatus> status;
  final Value<DateTime?> noticeDate;
  final Value<DateTime?> expectedCheckoutDate;
  final Value<DateTime?> checkoutDate;
  final Value<int> depositAdjustedPaise;
  final Value<int> depositRefundedPaise;
  final Value<String?> checkoutNotes;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TenantsCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.gender = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.idProofType = const Value.absent(),
    this.idProofNumber = const Value.absent(),
    this.idProofPath = const Value.absent(),
    this.emergencyContactName = const Value.absent(),
    this.emergencyContactPhone = const Value.absent(),
    this.occupation = const Value.absent(),
    this.joiningDate = const Value.absent(),
    this.monthlyRentPaise = const Value.absent(),
    this.securityDepositPaise = const Value.absent(),
    this.advancePaise = const Value.absent(),
    this.rentDueDay = const Value.absent(),
    this.status = const Value.absent(),
    this.noticeDate = const Value.absent(),
    this.expectedCheckoutDate = const Value.absent(),
    this.checkoutDate = const Value.absent(),
    this.depositAdjustedPaise = const Value.absent(),
    this.depositRefundedPaise = const Value.absent(),
    this.checkoutNotes = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TenantsCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    required String phone,
    this.email = const Value.absent(),
    required Gender gender,
    this.photoPath = const Value.absent(),
    this.idProofType = const Value.absent(),
    this.idProofNumber = const Value.absent(),
    this.idProofPath = const Value.absent(),
    this.emergencyContactName = const Value.absent(),
    this.emergencyContactPhone = const Value.absent(),
    this.occupation = const Value.absent(),
    required DateTime joiningDate,
    required int monthlyRentPaise,
    this.securityDepositPaise = const Value.absent(),
    this.advancePaise = const Value.absent(),
    required int rentDueDay,
    this.status = const Value.absent(),
    this.noticeDate = const Value.absent(),
    this.expectedCheckoutDate = const Value.absent(),
    this.checkoutDate = const Value.absent(),
    this.depositAdjustedPaise = const Value.absent(),
    this.depositRefundedPaise = const Value.absent(),
    this.checkoutNotes = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : fullName = Value(fullName),
       phone = Value(phone),
       gender = Value(gender),
       joiningDate = Value(joiningDate),
       monthlyRentPaise = Value(monthlyRentPaise),
       rentDueDay = Value(rentDueDay);
  static Insertable<Tenant> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? gender,
    Expression<String>? photoPath,
    Expression<String>? idProofType,
    Expression<String>? idProofNumber,
    Expression<String>? idProofPath,
    Expression<String>? emergencyContactName,
    Expression<String>? emergencyContactPhone,
    Expression<String>? occupation,
    Expression<DateTime>? joiningDate,
    Expression<int>? monthlyRentPaise,
    Expression<int>? securityDepositPaise,
    Expression<int>? advancePaise,
    Expression<int>? rentDueDay,
    Expression<String>? status,
    Expression<DateTime>? noticeDate,
    Expression<DateTime>? expectedCheckoutDate,
    Expression<DateTime>? checkoutDate,
    Expression<int>? depositAdjustedPaise,
    Expression<int>? depositRefundedPaise,
    Expression<String>? checkoutNotes,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (photoPath != null) 'photo_path': photoPath,
      if (idProofType != null) 'id_proof_type': idProofType,
      if (idProofNumber != null) 'id_proof_number': idProofNumber,
      if (idProofPath != null) 'id_proof_path': idProofPath,
      if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
      if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
      if (occupation != null) 'occupation': occupation,
      if (joiningDate != null) 'joining_date': joiningDate,
      if (monthlyRentPaise != null) 'monthly_rent_paise': monthlyRentPaise,
      if (securityDepositPaise != null) 'security_deposit_paise': securityDepositPaise,
      if (advancePaise != null) 'advance_paise': advancePaise,
      if (rentDueDay != null) 'rent_due_day': rentDueDay,
      if (status != null) 'status': status,
      if (noticeDate != null) 'notice_date': noticeDate,
      if (expectedCheckoutDate != null) 'expected_checkout_date': expectedCheckoutDate,
      if (checkoutDate != null) 'checkout_date': checkoutDate,
      if (depositAdjustedPaise != null) 'deposit_adjusted_paise': depositAdjustedPaise,
      if (depositRefundedPaise != null) 'deposit_refunded_paise': depositRefundedPaise,
      if (checkoutNotes != null) 'checkout_notes': checkoutNotes,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TenantsCompanion copyWith({
    Value<int>? id,
    Value<String>? fullName,
    Value<String>? phone,
    Value<String?>? email,
    Value<Gender>? gender,
    Value<String?>? photoPath,
    Value<String?>? idProofType,
    Value<String?>? idProofNumber,
    Value<String?>? idProofPath,
    Value<String?>? emergencyContactName,
    Value<String?>? emergencyContactPhone,
    Value<String?>? occupation,
    Value<DateTime>? joiningDate,
    Value<int>? monthlyRentPaise,
    Value<int>? securityDepositPaise,
    Value<int>? advancePaise,
    Value<int>? rentDueDay,
    Value<TenantStatus>? status,
    Value<DateTime?>? noticeDate,
    Value<DateTime?>? expectedCheckoutDate,
    Value<DateTime?>? checkoutDate,
    Value<int>? depositAdjustedPaise,
    Value<int>? depositRefundedPaise,
    Value<String?>? checkoutNotes,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TenantsCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      photoPath: photoPath ?? this.photoPath,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      idProofPath: idProofPath ?? this.idProofPath,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      occupation: occupation ?? this.occupation,
      joiningDate: joiningDate ?? this.joiningDate,
      monthlyRentPaise: monthlyRentPaise ?? this.monthlyRentPaise,
      securityDepositPaise: securityDepositPaise ?? this.securityDepositPaise,
      advancePaise: advancePaise ?? this.advancePaise,
      rentDueDay: rentDueDay ?? this.rentDueDay,
      status: status ?? this.status,
      noticeDate: noticeDate ?? this.noticeDate,
      expectedCheckoutDate: expectedCheckoutDate ?? this.expectedCheckoutDate,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      depositAdjustedPaise: depositAdjustedPaise ?? this.depositAdjustedPaise,
      depositRefundedPaise: depositRefundedPaise ?? this.depositRefundedPaise,
      checkoutNotes: checkoutNotes ?? this.checkoutNotes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>($TenantsTable.$convertergender.toSql(gender.value));
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (idProofType.present) {
      map['id_proof_type'] = Variable<String>(idProofType.value);
    }
    if (idProofNumber.present) {
      map['id_proof_number'] = Variable<String>(idProofNumber.value);
    }
    if (idProofPath.present) {
      map['id_proof_path'] = Variable<String>(idProofPath.value);
    }
    if (emergencyContactName.present) {
      map['emergency_contact_name'] = Variable<String>(emergencyContactName.value);
    }
    if (emergencyContactPhone.present) {
      map['emergency_contact_phone'] = Variable<String>(emergencyContactPhone.value);
    }
    if (occupation.present) {
      map['occupation'] = Variable<String>(occupation.value);
    }
    if (joiningDate.present) {
      map['joining_date'] = Variable<DateTime>(joiningDate.value);
    }
    if (monthlyRentPaise.present) {
      map['monthly_rent_paise'] = Variable<int>(monthlyRentPaise.value);
    }
    if (securityDepositPaise.present) {
      map['security_deposit_paise'] = Variable<int>(securityDepositPaise.value);
    }
    if (advancePaise.present) {
      map['advance_paise'] = Variable<int>(advancePaise.value);
    }
    if (rentDueDay.present) {
      map['rent_due_day'] = Variable<int>(rentDueDay.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($TenantsTable.$converterstatus.toSql(status.value));
    }
    if (noticeDate.present) {
      map['notice_date'] = Variable<DateTime>(noticeDate.value);
    }
    if (expectedCheckoutDate.present) {
      map['expected_checkout_date'] = Variable<DateTime>(expectedCheckoutDate.value);
    }
    if (checkoutDate.present) {
      map['checkout_date'] = Variable<DateTime>(checkoutDate.value);
    }
    if (depositAdjustedPaise.present) {
      map['deposit_adjusted_paise'] = Variable<int>(depositAdjustedPaise.value);
    }
    if (depositRefundedPaise.present) {
      map['deposit_refunded_paise'] = Variable<int>(depositRefundedPaise.value);
    }
    if (checkoutNotes.present) {
      map['checkout_notes'] = Variable<String>(checkoutNotes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenantsCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('gender: $gender, ')
          ..write('photoPath: $photoPath, ')
          ..write('idProofType: $idProofType, ')
          ..write('idProofNumber: $idProofNumber, ')
          ..write('idProofPath: $idProofPath, ')
          ..write('emergencyContactName: $emergencyContactName, ')
          ..write('emergencyContactPhone: $emergencyContactPhone, ')
          ..write('occupation: $occupation, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('monthlyRentPaise: $monthlyRentPaise, ')
          ..write('securityDepositPaise: $securityDepositPaise, ')
          ..write('advancePaise: $advancePaise, ')
          ..write('rentDueDay: $rentDueDay, ')
          ..write('status: $status, ')
          ..write('noticeDate: $noticeDate, ')
          ..write('expectedCheckoutDate: $expectedCheckoutDate, ')
          ..write('checkoutDate: $checkoutDate, ')
          ..write('depositAdjustedPaise: $depositAdjustedPaise, ')
          ..write('depositRefundedPaise: $depositRefundedPaise, ')
          ..write('checkoutNotes: $checkoutNotes, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AllocationsTable extends Allocations with TableInfo<$AllocationsTable, Allocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<int> tenantId = GeneratedColumn<int>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tenants (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _bedIdMeta = const VerificationMeta('bedId');
  @override
  late final GeneratedColumn<int> bedId = GeneratedColumn<int>(
    'bed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES beds (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _rentPaiseMeta = const VerificationMeta('rentPaise');
  @override
  late final GeneratedColumn<int> rentPaise = GeneratedColumn<int>(
    'rent_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(rentPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endReasonMeta = const VerificationMeta('endReason');
  @override
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
    'end_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    bedId,
    startDate,
    endDate,
    isActive,
    rentPaise,
    endReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocations';
  @override
  VerificationContext validateIntegrity(Insertable<Allocation> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta, tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('bed_id')) {
      context.handle(_bedIdMeta, bedId.isAcceptableOrUnknown(data['bed_id']!, _bedIdMeta));
    } else if (isInserting) {
      context.missing(_bedIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta, isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('rent_paise')) {
      context.handle(_rentPaiseMeta, rentPaise.isAcceptableOrUnknown(data['rent_paise']!, _rentPaiseMeta));
    } else if (isInserting) {
      context.missing(_rentPaiseMeta);
    }
    if (data.containsKey('end_reason')) {
      context.handle(_endReasonMeta, endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Allocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Allocation(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tenant_id'])!,
      bedId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}bed_id'])!,
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      isActive: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      rentPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rent_paise'])!,
      endReason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}end_reason']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AllocationsTable createAlias(String alias) {
    return $AllocationsTable(attachedDatabase, alias);
  }
}

class Allocation extends DataClass implements Insertable<Allocation> {
  final int id;
  final int tenantId;
  final int bedId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int rentPaise;
  final String? endReason;
  final DateTime createdAt;
  const Allocation({
    required this.id,
    required this.tenantId,
    required this.bedId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.rentPaise,
    this.endReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tenant_id'] = Variable<int>(tenantId);
    map['bed_id'] = Variable<int>(bedId);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['rent_paise'] = Variable<int>(rentPaise);
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AllocationsCompanion toCompanion(bool nullToAbsent) {
    return AllocationsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      bedId: Value(bedId),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
      isActive: Value(isActive),
      rentPaise: Value(rentPaise),
      endReason: endReason == null && nullToAbsent ? const Value.absent() : Value(endReason),
      createdAt: Value(createdAt),
    );
  }

  factory Allocation.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Allocation(
      id: serializer.fromJson<int>(json['id']),
      tenantId: serializer.fromJson<int>(json['tenantId']),
      bedId: serializer.fromJson<int>(json['bedId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      rentPaise: serializer.fromJson<int>(json['rentPaise']),
      endReason: serializer.fromJson<String?>(json['endReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenantId': serializer.toJson<int>(tenantId),
      'bedId': serializer.toJson<int>(bedId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'rentPaise': serializer.toJson<int>(rentPaise),
      'endReason': serializer.toJson<String?>(endReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Allocation copyWith({
    int? id,
    int? tenantId,
    int? bedId,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
    int? rentPaise,
    Value<String?> endReason = const Value.absent(),
    DateTime? createdAt,
  }) => Allocation(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    bedId: bedId ?? this.bedId,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    rentPaise: rentPaise ?? this.rentPaise,
    endReason: endReason.present ? endReason.value : this.endReason,
    createdAt: createdAt ?? this.createdAt,
  );
  Allocation copyWithCompanion(AllocationsCompanion data) {
    return Allocation(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      bedId: data.bedId.present ? data.bedId.value : this.bedId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      rentPaise: data.rentPaise.present ? data.rentPaise.value : this.rentPaise,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Allocation(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('bedId: $bedId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('rentPaise: $rentPaise, ')
          ..write('endReason: $endReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, bedId, startDate, endDate, isActive, rentPaise, endReason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Allocation &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.bedId == this.bedId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.rentPaise == this.rentPaise &&
          other.endReason == this.endReason &&
          other.createdAt == this.createdAt);
}

class AllocationsCompanion extends UpdateCompanion<Allocation> {
  final Value<int> id;
  final Value<int> tenantId;
  final Value<int> bedId;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<int> rentPaise;
  final Value<String?> endReason;
  final Value<DateTime> createdAt;
  const AllocationsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.bedId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rentPaise = const Value.absent(),
    this.endReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int tenantId,
    required int bedId,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    required int rentPaise,
    this.endReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : tenantId = Value(tenantId),
       bedId = Value(bedId),
       startDate = Value(startDate),
       rentPaise = Value(rentPaise);
  static Insertable<Allocation> custom({
    Expression<int>? id,
    Expression<int>? tenantId,
    Expression<int>? bedId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<int>? rentPaise,
    Expression<String>? endReason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (bedId != null) 'bed_id': bedId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (rentPaise != null) 'rent_paise': rentPaise,
      if (endReason != null) 'end_reason': endReason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? tenantId,
    Value<int>? bedId,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<int>? rentPaise,
    Value<String?>? endReason,
    Value<DateTime>? createdAt,
  }) {
    return AllocationsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      bedId: bedId ?? this.bedId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      rentPaise: rentPaise ?? this.rentPaise,
      endReason: endReason ?? this.endReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<int>(tenantId.value);
    }
    if (bedId.present) {
      map['bed_id'] = Variable<int>(bedId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rentPaise.present) {
      map['rent_paise'] = Variable<int>(rentPaise.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllocationsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('bedId: $bedId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('rentPaise: $rentPaise, ')
          ..write('endReason: $endReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RentInvoicesTable extends RentInvoices with TableInfo<$RentInvoicesTable, RentInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<int> tenantId = GeneratedColumn<int>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tenants (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _allocationIdMeta = const VerificationMeta('allocationId');
  @override
  late final GeneratedColumn<int> allocationId = GeneratedColumn<int>(
    'allocation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES allocations (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _periodYearMeta = const VerificationMeta('periodYear');
  @override
  late final GeneratedColumn<int> periodYear = GeneratedColumn<int>(
    'period_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMonthMeta = const VerificationMeta('periodMonth');
  @override
  late final GeneratedColumn<int> periodMonth = GeneratedColumn<int>(
    'period_month',
    aliasedName,
    false,
    check: () => ComparableExpr(periodMonth).isBetweenValues(1, 12),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentPaiseMeta = const VerificationMeta('rentPaise');
  @override
  late final GeneratedColumn<int> rentPaise = GeneratedColumn<int>(
    'rent_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(rentPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _additionalChargesPaiseMeta = const VerificationMeta('additionalChargesPaise');
  @override
  late final GeneratedColumn<int> additionalChargesPaise = GeneratedColumn<int>(
    'additional_charges_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(additionalChargesPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountPaiseMeta = const VerificationMeta('discountPaise');
  @override
  late final GeneratedColumn<int> discountPaise = GeneratedColumn<int>(
    'discount_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(discountPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPaiseMeta = const VerificationMeta('totalPaise');
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
    'total_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(totalPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidPaiseMeta = const VerificationMeta('paidPaise');
  @override
  late final GeneratedColumn<int> paidPaise = GeneratedColumn<int>(
    'paid_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(paidPaise).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<InvoiceStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(InvoiceStatus.unpaid.name),
  ).withConverter<InvoiceStatus>($RentInvoicesTable.$converterstatus);
  static const VerificationMeta _dueDateMeta = const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isProratedMeta = const VerificationMeta('isProrated');
  @override
  late final GeneratedColumn<bool> isProrated = GeneratedColumn<bool>(
    'is_prorated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_prorated" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta('cancelledAt');
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonMeta = const VerificationMeta('cancelReason');
  @override
  late final GeneratedColumn<String> cancelReason = GeneratedColumn<String>(
    'cancel_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceNumber,
    tenantId,
    allocationId,
    periodYear,
    periodMonth,
    periodStart,
    periodEnd,
    rentPaise,
    additionalChargesPaise,
    discountPaise,
    totalPaise,
    paidPaise,
    status,
    dueDate,
    isProrated,
    notes,
    cancelledAt,
    cancelReason,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rent_invoices';
  @override
  VerificationContext validateIntegrity(Insertable<RentInvoice> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(data['invoice_number']!, _invoiceNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta, tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('allocation_id')) {
      context.handle(_allocationIdMeta, allocationId.isAcceptableOrUnknown(data['allocation_id']!, _allocationIdMeta));
    }
    if (data.containsKey('period_year')) {
      context.handle(_periodYearMeta, periodYear.isAcceptableOrUnknown(data['period_year']!, _periodYearMeta));
    } else if (isInserting) {
      context.missing(_periodYearMeta);
    }
    if (data.containsKey('period_month')) {
      context.handle(_periodMonthMeta, periodMonth.isAcceptableOrUnknown(data['period_month']!, _periodMonthMeta));
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(_periodStartMeta, periodStart.isAcceptableOrUnknown(data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta, periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('rent_paise')) {
      context.handle(_rentPaiseMeta, rentPaise.isAcceptableOrUnknown(data['rent_paise']!, _rentPaiseMeta));
    } else if (isInserting) {
      context.missing(_rentPaiseMeta);
    }
    if (data.containsKey('additional_charges_paise')) {
      context.handle(
        _additionalChargesPaiseMeta,
        additionalChargesPaise.isAcceptableOrUnknown(data['additional_charges_paise']!, _additionalChargesPaiseMeta),
      );
    }
    if (data.containsKey('discount_paise')) {
      context.handle(
        _discountPaiseMeta,
        discountPaise.isAcceptableOrUnknown(data['discount_paise']!, _discountPaiseMeta),
      );
    }
    if (data.containsKey('total_paise')) {
      context.handle(_totalPaiseMeta, totalPaise.isAcceptableOrUnknown(data['total_paise']!, _totalPaiseMeta));
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('paid_paise')) {
      context.handle(_paidPaiseMeta, paidPaise.isAcceptableOrUnknown(data['paid_paise']!, _paidPaiseMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta, dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_prorated')) {
      context.handle(_isProratedMeta, isProrated.isAcceptableOrUnknown(data['is_prorated']!, _isProratedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(_cancelledAtMeta, cancelledAt.isAcceptableOrUnknown(data['cancelled_at']!, _cancelledAtMeta));
    }
    if (data.containsKey('cancel_reason')) {
      context.handle(_cancelReasonMeta, cancelReason.isAcceptableOrUnknown(data['cancel_reason']!, _cancelReasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RentInvoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RentInvoice(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      tenantId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tenant_id'])!,
      allocationId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}allocation_id']),
      periodYear: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}period_year'])!,
      periodMonth: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}period_month'])!,
      periodStart: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}period_end'])!,
      rentPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rent_paise'])!,
      additionalChargesPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}additional_charges_paise'],
      )!,
      discountPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}discount_paise'])!,
      totalPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total_paise'])!,
      paidPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}paid_paise'])!,
      status: $RentInvoicesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      dueDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      isProrated: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_prorated'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      cancelledAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}cancelled_at']),
      cancelReason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cancel_reason']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RentInvoicesTable createAlias(String alias) {
    return $RentInvoicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InvoiceStatus, String, String> $converterstatus = const EnumNameConverter<InvoiceStatus>(
    InvoiceStatus.values,
  );
}

class RentInvoice extends DataClass implements Insertable<RentInvoice> {
  final int id;
  final String invoiceNumber;
  final int tenantId;
  final int? allocationId;
  final int periodYear;
  final int periodMonth;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int rentPaise;
  final int additionalChargesPaise;
  final int discountPaise;
  final int totalPaise;
  final int paidPaise;
  final InvoiceStatus status;
  final DateTime dueDate;
  final bool isProrated;
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RentInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.tenantId,
    this.allocationId,
    required this.periodYear,
    required this.periodMonth,
    required this.periodStart,
    required this.periodEnd,
    required this.rentPaise,
    required this.additionalChargesPaise,
    required this.discountPaise,
    required this.totalPaise,
    required this.paidPaise,
    required this.status,
    required this.dueDate,
    required this.isProrated,
    this.notes,
    this.cancelledAt,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['tenant_id'] = Variable<int>(tenantId);
    if (!nullToAbsent || allocationId != null) {
      map['allocation_id'] = Variable<int>(allocationId);
    }
    map['period_year'] = Variable<int>(periodYear);
    map['period_month'] = Variable<int>(periodMonth);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['rent_paise'] = Variable<int>(rentPaise);
    map['additional_charges_paise'] = Variable<int>(additionalChargesPaise);
    map['discount_paise'] = Variable<int>(discountPaise);
    map['total_paise'] = Variable<int>(totalPaise);
    map['paid_paise'] = Variable<int>(paidPaise);
    {
      map['status'] = Variable<String>($RentInvoicesTable.$converterstatus.toSql(status));
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['is_prorated'] = Variable<bool>(isProrated);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || cancelReason != null) {
      map['cancel_reason'] = Variable<String>(cancelReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RentInvoicesCompanion toCompanion(bool nullToAbsent) {
    return RentInvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      tenantId: Value(tenantId),
      allocationId: allocationId == null && nullToAbsent ? const Value.absent() : Value(allocationId),
      periodYear: Value(periodYear),
      periodMonth: Value(periodMonth),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      rentPaise: Value(rentPaise),
      additionalChargesPaise: Value(additionalChargesPaise),
      discountPaise: Value(discountPaise),
      totalPaise: Value(totalPaise),
      paidPaise: Value(paidPaise),
      status: Value(status),
      dueDate: Value(dueDate),
      isProrated: Value(isProrated),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      cancelledAt: cancelledAt == null && nullToAbsent ? const Value.absent() : Value(cancelledAt),
      cancelReason: cancelReason == null && nullToAbsent ? const Value.absent() : Value(cancelReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RentInvoice.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RentInvoice(
      id: serializer.fromJson<int>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      tenantId: serializer.fromJson<int>(json['tenantId']),
      allocationId: serializer.fromJson<int?>(json['allocationId']),
      periodYear: serializer.fromJson<int>(json['periodYear']),
      periodMonth: serializer.fromJson<int>(json['periodMonth']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      rentPaise: serializer.fromJson<int>(json['rentPaise']),
      additionalChargesPaise: serializer.fromJson<int>(json['additionalChargesPaise']),
      discountPaise: serializer.fromJson<int>(json['discountPaise']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      paidPaise: serializer.fromJson<int>(json['paidPaise']),
      status: $RentInvoicesTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      isProrated: serializer.fromJson<bool>(json['isProrated']),
      notes: serializer.fromJson<String?>(json['notes']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      cancelReason: serializer.fromJson<String?>(json['cancelReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'tenantId': serializer.toJson<int>(tenantId),
      'allocationId': serializer.toJson<int?>(allocationId),
      'periodYear': serializer.toJson<int>(periodYear),
      'periodMonth': serializer.toJson<int>(periodMonth),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'rentPaise': serializer.toJson<int>(rentPaise),
      'additionalChargesPaise': serializer.toJson<int>(additionalChargesPaise),
      'discountPaise': serializer.toJson<int>(discountPaise),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'paidPaise': serializer.toJson<int>(paidPaise),
      'status': serializer.toJson<String>($RentInvoicesTable.$converterstatus.toJson(status)),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'isProrated': serializer.toJson<bool>(isProrated),
      'notes': serializer.toJson<String?>(notes),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'cancelReason': serializer.toJson<String?>(cancelReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RentInvoice copyWith({
    int? id,
    String? invoiceNumber,
    int? tenantId,
    Value<int?> allocationId = const Value.absent(),
    int? periodYear,
    int? periodMonth,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? rentPaise,
    int? additionalChargesPaise,
    int? discountPaise,
    int? totalPaise,
    int? paidPaise,
    InvoiceStatus? status,
    DateTime? dueDate,
    bool? isProrated,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> cancelReason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RentInvoice(
    id: id ?? this.id,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    tenantId: tenantId ?? this.tenantId,
    allocationId: allocationId.present ? allocationId.value : this.allocationId,
    periodYear: periodYear ?? this.periodYear,
    periodMonth: periodMonth ?? this.periodMonth,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    rentPaise: rentPaise ?? this.rentPaise,
    additionalChargesPaise: additionalChargesPaise ?? this.additionalChargesPaise,
    discountPaise: discountPaise ?? this.discountPaise,
    totalPaise: totalPaise ?? this.totalPaise,
    paidPaise: paidPaise ?? this.paidPaise,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    isProrated: isProrated ?? this.isProrated,
    notes: notes.present ? notes.value : this.notes,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    cancelReason: cancelReason.present ? cancelReason.value : this.cancelReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RentInvoice copyWithCompanion(RentInvoicesCompanion data) {
    return RentInvoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present ? data.invoiceNumber.value : this.invoiceNumber,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      allocationId: data.allocationId.present ? data.allocationId.value : this.allocationId,
      periodYear: data.periodYear.present ? data.periodYear.value : this.periodYear,
      periodMonth: data.periodMonth.present ? data.periodMonth.value : this.periodMonth,
      periodStart: data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      rentPaise: data.rentPaise.present ? data.rentPaise.value : this.rentPaise,
      additionalChargesPaise: data.additionalChargesPaise.present
          ? data.additionalChargesPaise.value
          : this.additionalChargesPaise,
      discountPaise: data.discountPaise.present ? data.discountPaise.value : this.discountPaise,
      totalPaise: data.totalPaise.present ? data.totalPaise.value : this.totalPaise,
      paidPaise: data.paidPaise.present ? data.paidPaise.value : this.paidPaise,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isProrated: data.isProrated.present ? data.isProrated.value : this.isProrated,
      notes: data.notes.present ? data.notes.value : this.notes,
      cancelledAt: data.cancelledAt.present ? data.cancelledAt.value : this.cancelledAt,
      cancelReason: data.cancelReason.present ? data.cancelReason.value : this.cancelReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RentInvoice(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('tenantId: $tenantId, ')
          ..write('allocationId: $allocationId, ')
          ..write('periodYear: $periodYear, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('rentPaise: $rentPaise, ')
          ..write('additionalChargesPaise: $additionalChargesPaise, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paidPaise: $paidPaise, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('isProrated: $isProrated, ')
          ..write('notes: $notes, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    invoiceNumber,
    tenantId,
    allocationId,
    periodYear,
    periodMonth,
    periodStart,
    periodEnd,
    rentPaise,
    additionalChargesPaise,
    discountPaise,
    totalPaise,
    paidPaise,
    status,
    dueDate,
    isProrated,
    notes,
    cancelledAt,
    cancelReason,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RentInvoice &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.tenantId == this.tenantId &&
          other.allocationId == this.allocationId &&
          other.periodYear == this.periodYear &&
          other.periodMonth == this.periodMonth &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.rentPaise == this.rentPaise &&
          other.additionalChargesPaise == this.additionalChargesPaise &&
          other.discountPaise == this.discountPaise &&
          other.totalPaise == this.totalPaise &&
          other.paidPaise == this.paidPaise &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.isProrated == this.isProrated &&
          other.notes == this.notes &&
          other.cancelledAt == this.cancelledAt &&
          other.cancelReason == this.cancelReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RentInvoicesCompanion extends UpdateCompanion<RentInvoice> {
  final Value<int> id;
  final Value<String> invoiceNumber;
  final Value<int> tenantId;
  final Value<int?> allocationId;
  final Value<int> periodYear;
  final Value<int> periodMonth;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<int> rentPaise;
  final Value<int> additionalChargesPaise;
  final Value<int> discountPaise;
  final Value<int> totalPaise;
  final Value<int> paidPaise;
  final Value<InvoiceStatus> status;
  final Value<DateTime> dueDate;
  final Value<bool> isProrated;
  final Value<String?> notes;
  final Value<DateTime?> cancelledAt;
  final Value<String?> cancelReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RentInvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.allocationId = const Value.absent(),
    this.periodYear = const Value.absent(),
    this.periodMonth = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.rentPaise = const Value.absent(),
    this.additionalChargesPaise = const Value.absent(),
    this.discountPaise = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.paidPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isProrated = const Value.absent(),
    this.notes = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RentInvoicesCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceNumber,
    required int tenantId,
    this.allocationId = const Value.absent(),
    required int periodYear,
    required int periodMonth,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int rentPaise,
    this.additionalChargesPaise = const Value.absent(),
    this.discountPaise = const Value.absent(),
    required int totalPaise,
    this.paidPaise = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime dueDate,
    this.isProrated = const Value.absent(),
    this.notes = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : invoiceNumber = Value(invoiceNumber),
       tenantId = Value(tenantId),
       periodYear = Value(periodYear),
       periodMonth = Value(periodMonth),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       rentPaise = Value(rentPaise),
       totalPaise = Value(totalPaise),
       dueDate = Value(dueDate);
  static Insertable<RentInvoice> custom({
    Expression<int>? id,
    Expression<String>? invoiceNumber,
    Expression<int>? tenantId,
    Expression<int>? allocationId,
    Expression<int>? periodYear,
    Expression<int>? periodMonth,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<int>? rentPaise,
    Expression<int>? additionalChargesPaise,
    Expression<int>? discountPaise,
    Expression<int>? totalPaise,
    Expression<int>? paidPaise,
    Expression<String>? status,
    Expression<DateTime>? dueDate,
    Expression<bool>? isProrated,
    Expression<String>? notes,
    Expression<DateTime>? cancelledAt,
    Expression<String>? cancelReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (tenantId != null) 'tenant_id': tenantId,
      if (allocationId != null) 'allocation_id': allocationId,
      if (periodYear != null) 'period_year': periodYear,
      if (periodMonth != null) 'period_month': periodMonth,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (rentPaise != null) 'rent_paise': rentPaise,
      if (additionalChargesPaise != null) 'additional_charges_paise': additionalChargesPaise,
      if (discountPaise != null) 'discount_paise': discountPaise,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (paidPaise != null) 'paid_paise': paidPaise,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (isProrated != null) 'is_prorated': isProrated,
      if (notes != null) 'notes': notes,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cancelReason != null) 'cancel_reason': cancelReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RentInvoicesCompanion copyWith({
    Value<int>? id,
    Value<String>? invoiceNumber,
    Value<int>? tenantId,
    Value<int?>? allocationId,
    Value<int>? periodYear,
    Value<int>? periodMonth,
    Value<DateTime>? periodStart,
    Value<DateTime>? periodEnd,
    Value<int>? rentPaise,
    Value<int>? additionalChargesPaise,
    Value<int>? discountPaise,
    Value<int>? totalPaise,
    Value<int>? paidPaise,
    Value<InvoiceStatus>? status,
    Value<DateTime>? dueDate,
    Value<bool>? isProrated,
    Value<String?>? notes,
    Value<DateTime?>? cancelledAt,
    Value<String?>? cancelReason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RentInvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      tenantId: tenantId ?? this.tenantId,
      allocationId: allocationId ?? this.allocationId,
      periodYear: periodYear ?? this.periodYear,
      periodMonth: periodMonth ?? this.periodMonth,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      rentPaise: rentPaise ?? this.rentPaise,
      additionalChargesPaise: additionalChargesPaise ?? this.additionalChargesPaise,
      discountPaise: discountPaise ?? this.discountPaise,
      totalPaise: totalPaise ?? this.totalPaise,
      paidPaise: paidPaise ?? this.paidPaise,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isProrated: isProrated ?? this.isProrated,
      notes: notes ?? this.notes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<int>(tenantId.value);
    }
    if (allocationId.present) {
      map['allocation_id'] = Variable<int>(allocationId.value);
    }
    if (periodYear.present) {
      map['period_year'] = Variable<int>(periodYear.value);
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<int>(periodMonth.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (rentPaise.present) {
      map['rent_paise'] = Variable<int>(rentPaise.value);
    }
    if (additionalChargesPaise.present) {
      map['additional_charges_paise'] = Variable<int>(additionalChargesPaise.value);
    }
    if (discountPaise.present) {
      map['discount_paise'] = Variable<int>(discountPaise.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (paidPaise.present) {
      map['paid_paise'] = Variable<int>(paidPaise.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($RentInvoicesTable.$converterstatus.toSql(status.value));
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isProrated.present) {
      map['is_prorated'] = Variable<bool>(isProrated.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (cancelReason.present) {
      map['cancel_reason'] = Variable<String>(cancelReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('tenantId: $tenantId, ')
          ..write('allocationId: $allocationId, ')
          ..write('periodYear: $periodYear, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('rentPaise: $rentPaise, ')
          ..write('additionalChargesPaise: $additionalChargesPaise, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paidPaise: $paidPaise, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('isProrated: $isProrated, ')
          ..write('notes: $notes, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta('receiptNumber');
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
    'receipt_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<int> tenantId = GeneratedColumn<int>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tenants (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    check: () => BooleanExpressionOperators(amountPaise.equals(0)).not(),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentMethod>($PaymentsTable.$convertermethod);
  static const VerificationMeta _upiReferenceMeta = const VerificationMeta('upiReference');
  @override
  late final GeneratedColumn<String> upiReference = GeneratedColumn<String>(
    'upi_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentStatus>($PaymentsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentKind, String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(PaymentKind.payment.name),
  ).withConverter<PaymentKind>($PaymentsTable.$converterkind);
  static const VerificationMeta _reversesPaymentIdMeta = const VerificationMeta('reversesPaymentId');
  @override
  late final GeneratedColumn<int> reversesPaymentId = GeneratedColumn<int>(
    'reverses_payment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES payments (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta('verifiedAt');
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    receiptNumber,
    tenantId,
    amountPaise,
    method,
    upiReference,
    paymentDate,
    status,
    kind,
    reversesPaymentId,
    notes,
    verifiedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(data['transaction_id']!, _transactionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(data['receipt_number']!, _receiptNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptNumberMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta, tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(_amountPaiseMeta, amountPaise.isAcceptableOrUnknown(data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('upi_reference')) {
      context.handle(_upiReferenceMeta, upiReference.isAcceptableOrUnknown(data['upi_reference']!, _upiReferenceMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(_paymentDateMeta, paymentDate.isAcceptableOrUnknown(data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('reverses_payment_id')) {
      context.handle(
        _reversesPaymentIdMeta,
        reversesPaymentId.isAcceptableOrUnknown(data['reverses_payment_id']!, _reversesPaymentIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('verified_at')) {
      context.handle(_verifiedAtMeta, verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      receiptNumber: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}receipt_number'])!,
      tenantId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tenant_id'])!,
      amountPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      method: $PaymentsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      ),
      upiReference: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}upi_reference']),
      paymentDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      status: $PaymentsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      kind: $PaymentsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      ),
      reversesPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reverses_payment_id'],
      ),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      verifiedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}verified_at']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String> $convertermethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static JsonTypeConverter2<PaymentStatus, String, String> $converterstatus = const EnumNameConverter<PaymentStatus>(
    PaymentStatus.values,
  );
  static JsonTypeConverter2<PaymentKind, String, String> $converterkind = const EnumNameConverter<PaymentKind>(
    PaymentKind.values,
  );
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final String transactionId;
  final String receiptNumber;
  final int tenantId;
  final int amountPaise;
  final PaymentMethod method;

  /// UPI UTR / reference number. Unique when present (partial index).
  final String? upiReference;
  final DateTime paymentDate;
  final PaymentStatus status;
  final PaymentKind kind;
  final int? reversesPaymentId;
  final String? notes;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  const Payment({
    required this.id,
    required this.transactionId,
    required this.receiptNumber,
    required this.tenantId,
    required this.amountPaise,
    required this.method,
    this.upiReference,
    required this.paymentDate,
    required this.status,
    required this.kind,
    this.reversesPaymentId,
    this.notes,
    this.verifiedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['receipt_number'] = Variable<String>(receiptNumber);
    map['tenant_id'] = Variable<int>(tenantId);
    map['amount_paise'] = Variable<int>(amountPaise);
    {
      map['method'] = Variable<String>($PaymentsTable.$convertermethod.toSql(method));
    }
    if (!nullToAbsent || upiReference != null) {
      map['upi_reference'] = Variable<String>(upiReference);
    }
    map['payment_date'] = Variable<DateTime>(paymentDate);
    {
      map['status'] = Variable<String>($PaymentsTable.$converterstatus.toSql(status));
    }
    {
      map['kind'] = Variable<String>($PaymentsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || reversesPaymentId != null) {
      map['reverses_payment_id'] = Variable<int>(reversesPaymentId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      receiptNumber: Value(receiptNumber),
      tenantId: Value(tenantId),
      amountPaise: Value(amountPaise),
      method: Value(method),
      upiReference: upiReference == null && nullToAbsent ? const Value.absent() : Value(upiReference),
      paymentDate: Value(paymentDate),
      status: Value(status),
      kind: Value(kind),
      reversesPaymentId: reversesPaymentId == null && nullToAbsent ? const Value.absent() : Value(reversesPaymentId),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      verifiedAt: verifiedAt == null && nullToAbsent ? const Value.absent() : Value(verifiedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      receiptNumber: serializer.fromJson<String>(json['receiptNumber']),
      tenantId: serializer.fromJson<int>(json['tenantId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      method: $PaymentsTable.$convertermethod.fromJson(serializer.fromJson<String>(json['method'])),
      upiReference: serializer.fromJson<String?>(json['upiReference']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      status: $PaymentsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      kind: $PaymentsTable.$converterkind.fromJson(serializer.fromJson<String>(json['kind'])),
      reversesPaymentId: serializer.fromJson<int?>(json['reversesPaymentId']),
      notes: serializer.fromJson<String?>(json['notes']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'receiptNumber': serializer.toJson<String>(receiptNumber),
      'tenantId': serializer.toJson<int>(tenantId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'method': serializer.toJson<String>($PaymentsTable.$convertermethod.toJson(method)),
      'upiReference': serializer.toJson<String?>(upiReference),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'status': serializer.toJson<String>($PaymentsTable.$converterstatus.toJson(status)),
      'kind': serializer.toJson<String>($PaymentsTable.$converterkind.toJson(kind)),
      'reversesPaymentId': serializer.toJson<int?>(reversesPaymentId),
      'notes': serializer.toJson<String?>(notes),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    int? id,
    String? transactionId,
    String? receiptNumber,
    int? tenantId,
    int? amountPaise,
    PaymentMethod? method,
    Value<String?> upiReference = const Value.absent(),
    DateTime? paymentDate,
    PaymentStatus? status,
    PaymentKind? kind,
    Value<int?> reversesPaymentId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> verifiedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Payment(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    receiptNumber: receiptNumber ?? this.receiptNumber,
    tenantId: tenantId ?? this.tenantId,
    amountPaise: amountPaise ?? this.amountPaise,
    method: method ?? this.method,
    upiReference: upiReference.present ? upiReference.value : this.upiReference,
    paymentDate: paymentDate ?? this.paymentDate,
    status: status ?? this.status,
    kind: kind ?? this.kind,
    reversesPaymentId: reversesPaymentId.present ? reversesPaymentId.value : this.reversesPaymentId,
    notes: notes.present ? notes.value : this.notes,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present ? data.transactionId.value : this.transactionId,
      receiptNumber: data.receiptNumber.present ? data.receiptNumber.value : this.receiptNumber,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      amountPaise: data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      method: data.method.present ? data.method.value : this.method,
      upiReference: data.upiReference.present ? data.upiReference.value : this.upiReference,
      paymentDate: data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      status: data.status.present ? data.status.value : this.status,
      kind: data.kind.present ? data.kind.value : this.kind,
      reversesPaymentId: data.reversesPaymentId.present ? data.reversesPaymentId.value : this.reversesPaymentId,
      notes: data.notes.present ? data.notes.value : this.notes,
      verifiedAt: data.verifiedAt.present ? data.verifiedAt.value : this.verifiedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('tenantId: $tenantId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('method: $method, ')
          ..write('upiReference: $upiReference, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('status: $status, ')
          ..write('kind: $kind, ')
          ..write('reversesPaymentId: $reversesPaymentId, ')
          ..write('notes: $notes, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    receiptNumber,
    tenantId,
    amountPaise,
    method,
    upiReference,
    paymentDate,
    status,
    kind,
    reversesPaymentId,
    notes,
    verifiedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.receiptNumber == this.receiptNumber &&
          other.tenantId == this.tenantId &&
          other.amountPaise == this.amountPaise &&
          other.method == this.method &&
          other.upiReference == this.upiReference &&
          other.paymentDate == this.paymentDate &&
          other.status == this.status &&
          other.kind == this.kind &&
          other.reversesPaymentId == this.reversesPaymentId &&
          other.notes == this.notes &&
          other.verifiedAt == this.verifiedAt &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<String> transactionId;
  final Value<String> receiptNumber;
  final Value<int> tenantId;
  final Value<int> amountPaise;
  final Value<PaymentMethod> method;
  final Value<String?> upiReference;
  final Value<DateTime> paymentDate;
  final Value<PaymentStatus> status;
  final Value<PaymentKind> kind;
  final Value<int?> reversesPaymentId;
  final Value<String?> notes;
  final Value<DateTime?> verifiedAt;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.method = const Value.absent(),
    this.upiReference = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.status = const Value.absent(),
    this.kind = const Value.absent(),
    this.reversesPaymentId = const Value.absent(),
    this.notes = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required String receiptNumber,
    required int tenantId,
    required int amountPaise,
    required PaymentMethod method,
    this.upiReference = const Value.absent(),
    required DateTime paymentDate,
    required PaymentStatus status,
    this.kind = const Value.absent(),
    this.reversesPaymentId = const Value.absent(),
    this.notes = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : transactionId = Value(transactionId),
       receiptNumber = Value(receiptNumber),
       tenantId = Value(tenantId),
       amountPaise = Value(amountPaise),
       method = Value(method),
       paymentDate = Value(paymentDate),
       status = Value(status);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<String>? transactionId,
    Expression<String>? receiptNumber,
    Expression<int>? tenantId,
    Expression<int>? amountPaise,
    Expression<String>? method,
    Expression<String>? upiReference,
    Expression<DateTime>? paymentDate,
    Expression<String>? status,
    Expression<String>? kind,
    Expression<int>? reversesPaymentId,
    Expression<String>? notes,
    Expression<DateTime>? verifiedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (tenantId != null) 'tenant_id': tenantId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (method != null) 'method': method,
      if (upiReference != null) 'upi_reference': upiReference,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (status != null) 'status': status,
      if (kind != null) 'kind': kind,
      if (reversesPaymentId != null) 'reverses_payment_id': reversesPaymentId,
      if (notes != null) 'notes': notes,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<String>? transactionId,
    Value<String>? receiptNumber,
    Value<int>? tenantId,
    Value<int>? amountPaise,
    Value<PaymentMethod>? method,
    Value<String?>? upiReference,
    Value<DateTime>? paymentDate,
    Value<PaymentStatus>? status,
    Value<PaymentKind>? kind,
    Value<int?>? reversesPaymentId,
    Value<String?>? notes,
    Value<DateTime?>? verifiedAt,
    Value<DateTime>? createdAt,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      tenantId: tenantId ?? this.tenantId,
      amountPaise: amountPaise ?? this.amountPaise,
      method: method ?? this.method,
      upiReference: upiReference ?? this.upiReference,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      kind: kind ?? this.kind,
      reversesPaymentId: reversesPaymentId ?? this.reversesPaymentId,
      notes: notes ?? this.notes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<int>(tenantId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (method.present) {
      map['method'] = Variable<String>($PaymentsTable.$convertermethod.toSql(method.value));
    }
    if (upiReference.present) {
      map['upi_reference'] = Variable<String>(upiReference.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($PaymentsTable.$converterstatus.toSql(status.value));
    }
    if (kind.present) {
      map['kind'] = Variable<String>($PaymentsTable.$converterkind.toSql(kind.value));
    }
    if (reversesPaymentId.present) {
      map['reverses_payment_id'] = Variable<int>(reversesPaymentId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('tenantId: $tenantId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('method: $method, ')
          ..write('upiReference: $upiReference, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('status: $status, ')
          ..write('kind: $kind, ')
          ..write('reversesPaymentId: $reversesPaymentId, ')
          ..write('notes: $notes, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentAllocationsTable extends PaymentAllocations with TableInfo<$PaymentAllocationsTable, PaymentAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta('paymentId');
  @override
  late final GeneratedColumn<int> paymentId = GeneratedColumn<int>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES payments (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES rent_invoices (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, paymentId, invoiceId, amountPaise, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_allocations';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentAllocation> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payment_id')) {
      context.handle(_paymentIdMeta, paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta));
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta, invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(_amountPaiseMeta, amountPaise.isAcceptableOrUnknown(data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentAllocation(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      paymentId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}payment_id'])!,
      invoiceId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}invoice_id'])!,
      amountPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentAllocationsTable createAlias(String alias) {
    return $PaymentAllocationsTable(attachedDatabase, alias);
  }
}

class PaymentAllocation extends DataClass implements Insertable<PaymentAllocation> {
  final int id;
  final int paymentId;
  final int invoiceId;

  /// Positive for payments, negative for reversals.
  final int amountPaise;
  final DateTime createdAt;
  const PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.invoiceId,
    required this.amountPaise,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payment_id'] = Variable<int>(paymentId);
    map['invoice_id'] = Variable<int>(invoiceId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PaymentAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      invoiceId: Value(invoiceId),
      amountPaise: Value(amountPaise),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentAllocation.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentAllocation(
      id: serializer.fromJson<int>(json['id']),
      paymentId: serializer.fromJson<int>(json['paymentId']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paymentId': serializer.toJson<int>(paymentId),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentAllocation copyWith({int? id, int? paymentId, int? invoiceId, int? amountPaise, DateTime? createdAt}) =>
      PaymentAllocation(
        id: id ?? this.id,
        paymentId: paymentId ?? this.paymentId,
        invoiceId: invoiceId ?? this.invoiceId,
        amountPaise: amountPaise ?? this.amountPaise,
        createdAt: createdAt ?? this.createdAt,
      );
  PaymentAllocation copyWithCompanion(PaymentAllocationsCompanion data) {
    return PaymentAllocation(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      amountPaise: data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocation(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, paymentId, invoiceId, amountPaise, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentAllocation &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.invoiceId == this.invoiceId &&
          other.amountPaise == this.amountPaise &&
          other.createdAt == this.createdAt);
}

class PaymentAllocationsCompanion extends UpdateCompanion<PaymentAllocation> {
  final Value<int> id;
  final Value<int> paymentId;
  final Value<int> invoiceId;
  final Value<int> amountPaise;
  final Value<DateTime> createdAt;
  const PaymentAllocationsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int paymentId,
    required int invoiceId,
    required int amountPaise,
    this.createdAt = const Value.absent(),
  }) : paymentId = Value(paymentId),
       invoiceId = Value(invoiceId),
       amountPaise = Value(amountPaise);
  static Insertable<PaymentAllocation> custom({
    Expression<int>? id,
    Expression<int>? paymentId,
    Expression<int>? invoiceId,
    Expression<int>? amountPaise,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentAllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? paymentId,
    Value<int>? invoiceId,
    Value<int>? amountPaise,
    Value<DateTime>? createdAt,
  }) {
    return PaymentAllocationsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      amountPaise: amountPaise ?? this.amountPaise,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<int>(paymentId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseCategory, String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ExpenseCategory>($ExpensesTable.$convertercategory);
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    check: () => ComparableExpr(amountPaise).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentMethod>($ExpensesTable.$converterpaymentMethod);
  static const VerificationMeta _vendorMeta = const VerificationMeta('vendor');
  @override
  late final GeneratedColumn<String> vendor = GeneratedColumn<String>(
    'vendor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billPathMeta = const VerificationMeta('billPath');
  @override
  late final GeneratedColumn<String> billPath = GeneratedColumn<String>(
    'bill_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVoidedMeta = const VerificationMeta('isVoided');
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
    'is_voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_voided" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta('voidReason');
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    amountPaise,
    expenseDate,
    paymentMethod,
    vendor,
    billPath,
    notes,
    isVoided,
    voidReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(_amountPaiseMeta, amountPaise.isAcceptableOrUnknown(data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(_expenseDateMeta, expenseDate.isAcceptableOrUnknown(data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('vendor')) {
      context.handle(_vendorMeta, vendor.isAcceptableOrUnknown(data['vendor']!, _vendorMeta));
    }
    if (data.containsKey('bill_path')) {
      context.handle(_billPathMeta, billPath.isAcceptableOrUnknown(data['bill_path']!, _billPathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_voided')) {
      context.handle(_isVoidedMeta, isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta));
    }
    if (data.containsKey('void_reason')) {
      context.handle(_voidReasonMeta, voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: $ExpensesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      ),
      amountPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      expenseDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      paymentMethod: $ExpensesTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      ),
      vendor: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}vendor']),
      billPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bill_path']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isVoided: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_voided'])!,
      voidReason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}void_reason']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExpenseCategory, String, String> $convertercategory =
      const EnumNameConverter<ExpenseCategory>(ExpenseCategory.values);
  static JsonTypeConverter2<PaymentMethod, String, String> $converterpaymentMethod =
      const EnumNameConverter<PaymentMethod>(PaymentMethod.values);
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String title;
  final ExpenseCategory category;
  final int amountPaise;
  final DateTime expenseDate;
  final PaymentMethod paymentMethod;
  final String? vendor;
  final String? billPath;
  final String? notes;
  final bool isVoided;
  final String? voidReason;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amountPaise,
    required this.expenseDate,
    required this.paymentMethod,
    this.vendor,
    this.billPath,
    this.notes,
    required this.isVoided,
    this.voidReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    {
      map['category'] = Variable<String>($ExpensesTable.$convertercategory.toSql(category));
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    {
      map['payment_method'] = Variable<String>($ExpensesTable.$converterpaymentMethod.toSql(paymentMethod));
    }
    if (!nullToAbsent || vendor != null) {
      map['vendor'] = Variable<String>(vendor);
    }
    if (!nullToAbsent || billPath != null) {
      map['bill_path'] = Variable<String>(billPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      amountPaise: Value(amountPaise),
      expenseDate: Value(expenseDate),
      paymentMethod: Value(paymentMethod),
      vendor: vendor == null && nullToAbsent ? const Value.absent() : Value(vendor),
      billPath: billPath == null && nullToAbsent ? const Value.absent() : Value(billPath),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isVoided: Value(isVoided),
      voidReason: voidReason == null && nullToAbsent ? const Value.absent() : Value(voidReason),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: $ExpensesTable.$convertercategory.fromJson(serializer.fromJson<String>(json['category'])),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      paymentMethod: $ExpensesTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      vendor: serializer.fromJson<String?>(json['vendor']),
      billPath: serializer.fromJson<String?>(json['billPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>($ExpensesTable.$convertercategory.toJson(category)),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'paymentMethod': serializer.toJson<String>($ExpensesTable.$converterpaymentMethod.toJson(paymentMethod)),
      'vendor': serializer.toJson<String?>(vendor),
      'billPath': serializer.toJson<String?>(billPath),
      'notes': serializer.toJson<String?>(notes),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidReason': serializer.toJson<String?>(voidReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    int? id,
    String? title,
    ExpenseCategory? category,
    int? amountPaise,
    DateTime? expenseDate,
    PaymentMethod? paymentMethod,
    Value<String?> vendor = const Value.absent(),
    Value<String?> billPath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isVoided,
    Value<String?> voidReason = const Value.absent(),
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    amountPaise: amountPaise ?? this.amountPaise,
    expenseDate: expenseDate ?? this.expenseDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    vendor: vendor.present ? vendor.value : this.vendor,
    billPath: billPath.present ? billPath.value : this.billPath,
    notes: notes.present ? notes.value : this.notes,
    isVoided: isVoided ?? this.isVoided,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      amountPaise: data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      expenseDate: data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      paymentMethod: data.paymentMethod.present ? data.paymentMethod.value : this.paymentMethod,
      vendor: data.vendor.present ? data.vendor.value : this.vendor,
      billPath: data.billPath.present ? data.billPath.value : this.billPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidReason: data.voidReason.present ? data.voidReason.value : this.voidReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('vendor: $vendor, ')
          ..write('billPath: $billPath, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidReason: $voidReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    amountPaise,
    expenseDate,
    paymentMethod,
    vendor,
    billPath,
    notes,
    isVoided,
    voidReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.amountPaise == this.amountPaise &&
          other.expenseDate == this.expenseDate &&
          other.paymentMethod == this.paymentMethod &&
          other.vendor == this.vendor &&
          other.billPath == this.billPath &&
          other.notes == this.notes &&
          other.isVoided == this.isVoided &&
          other.voidReason == this.voidReason &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String> title;
  final Value<ExpenseCategory> category;
  final Value<int> amountPaise;
  final Value<DateTime> expenseDate;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> vendor;
  final Value<String?> billPath;
  final Value<String?> notes;
  final Value<bool> isVoided;
  final Value<String?> voidReason;
  final Value<DateTime> createdAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.vendor = const Value.absent(),
    this.billPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required ExpenseCategory category,
    required int amountPaise,
    required DateTime expenseDate,
    required PaymentMethod paymentMethod,
    this.vendor = const Value.absent(),
    this.billPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       category = Value(category),
       amountPaise = Value(amountPaise),
       expenseDate = Value(expenseDate),
       paymentMethod = Value(paymentMethod);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? amountPaise,
    Expression<DateTime>? expenseDate,
    Expression<String>? paymentMethod,
    Expression<String>? vendor,
    Expression<String>? billPath,
    Expression<String>? notes,
    Expression<bool>? isVoided,
    Expression<String>? voidReason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (vendor != null) 'vendor': vendor,
      if (billPath != null) 'bill_path': billPath,
      if (notes != null) 'notes': notes,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidReason != null) 'void_reason': voidReason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<ExpenseCategory>? category,
    Value<int>? amountPaise,
    Value<DateTime>? expenseDate,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? vendor,
    Value<String?>? billPath,
    Value<String?>? notes,
    Value<bool>? isVoided,
    Value<String?>? voidReason,
    Value<DateTime>? createdAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amountPaise: amountPaise ?? this.amountPaise,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vendor: vendor ?? this.vendor,
      billPath: billPath ?? this.billPath,
      notes: notes ?? this.notes,
      isVoided: isVoided ?? this.isVoided,
      voidReason: voidReason ?? this.voidReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>($ExpensesTable.$convertercategory.toSql(category.value));
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>($ExpensesTable.$converterpaymentMethod.toSql(paymentMethod.value));
    }
    if (vendor.present) {
      map['vendor'] = Variable<String>(vendor.value);
    }
    if (billPath.present) {
      map['bill_path'] = Variable<String>(billPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('vendor: $vendor, ')
          ..write('billPath: $billPath, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidReason: $voidReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ComplaintsTable extends Complaints with TableInfo<$ComplaintsTable, Complaint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<int> tenantId = GeneratedColumn<int>(
    'tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tenants (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES rooms (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 2000),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ComplaintPriority, String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ComplaintPriority>($ComplaintsTable.$converterpriority);
  @override
  late final GeneratedColumnWithTypeConverter<ComplaintStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ComplaintStatus.open.name),
  ).withConverter<ComplaintStatus>($ComplaintsTable.$converterstatus);
  static const VerificationMeta _imagePathsMeta = const VerificationMeta('imagePaths');
  @override
  late final GeneratedColumn<String> imagePaths = GeneratedColumn<String>(
    'image_paths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _resolutionNotesMeta = const VerificationMeta('resolutionNotes');
  @override
  late final GeneratedColumn<String> resolutionNotes = GeneratedColumn<String>(
    'resolution_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<int> expenseId = GeneratedColumn<int>(
    'expense_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES expenses (id) ON DELETE RESTRICT'),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    roomId,
    category,
    description,
    priority,
    status,
    imagePaths,
    resolutionNotes,
    expenseId,
    resolvedAt,
    closedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaints';
  @override
  VerificationContext validateIntegrity(Insertable<Complaint> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta, tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta, roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_paths')) {
      context.handle(_imagePathsMeta, imagePaths.isAcceptableOrUnknown(data['image_paths']!, _imagePathsMeta));
    }
    if (data.containsKey('resolution_notes')) {
      context.handle(
        _resolutionNotesMeta,
        resolutionNotes.isAcceptableOrUnknown(data['resolution_notes']!, _resolutionNotesMeta),
      );
    }
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta, expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    }
    if (data.containsKey('resolved_at')) {
      context.handle(_resolvedAtMeta, resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta, closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Complaint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Complaint(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tenant_id']),
      roomId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}room_id']),
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      priority: $ComplaintsTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      ),
      status: $ComplaintsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      imagePaths: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}image_paths'])!,
      resolutionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_notes'],
      ),
      expenseId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}expense_id']),
      resolvedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      closedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ComplaintsTable createAlias(String alias) {
    return $ComplaintsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ComplaintPriority, String, String> $converterpriority =
      const EnumNameConverter<ComplaintPriority>(ComplaintPriority.values);
  static JsonTypeConverter2<ComplaintStatus, String, String> $converterstatus =
      const EnumNameConverter<ComplaintStatus>(ComplaintStatus.values);
}

class Complaint extends DataClass implements Insertable<Complaint> {
  final int id;
  final int? tenantId;
  final int? roomId;
  final String category;
  final String description;
  final ComplaintPriority priority;
  final ComplaintStatus status;

  /// JSON array of private-storage relative paths.
  final String imagePaths;
  final String? resolutionNotes;
  final int? expenseId;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Complaint({
    required this.id,
    this.tenantId,
    this.roomId,
    required this.category,
    required this.description,
    required this.priority,
    required this.status,
    required this.imagePaths,
    this.resolutionNotes,
    this.expenseId,
    this.resolvedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<int>(tenantId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<int>(roomId);
    }
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    {
      map['priority'] = Variable<String>($ComplaintsTable.$converterpriority.toSql(priority));
    }
    {
      map['status'] = Variable<String>($ComplaintsTable.$converterstatus.toSql(status));
    }
    map['image_paths'] = Variable<String>(imagePaths);
    if (!nullToAbsent || resolutionNotes != null) {
      map['resolution_notes'] = Variable<String>(resolutionNotes);
    }
    if (!nullToAbsent || expenseId != null) {
      map['expense_id'] = Variable<int>(expenseId);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ComplaintsCompanion toCompanion(bool nullToAbsent) {
    return ComplaintsCompanion(
      id: Value(id),
      tenantId: tenantId == null && nullToAbsent ? const Value.absent() : Value(tenantId),
      roomId: roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      category: Value(category),
      description: Value(description),
      priority: Value(priority),
      status: Value(status),
      imagePaths: Value(imagePaths),
      resolutionNotes: resolutionNotes == null && nullToAbsent ? const Value.absent() : Value(resolutionNotes),
      expenseId: expenseId == null && nullToAbsent ? const Value.absent() : Value(expenseId),
      resolvedAt: resolvedAt == null && nullToAbsent ? const Value.absent() : Value(resolvedAt),
      closedAt: closedAt == null && nullToAbsent ? const Value.absent() : Value(closedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Complaint.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Complaint(
      id: serializer.fromJson<int>(json['id']),
      tenantId: serializer.fromJson<int?>(json['tenantId']),
      roomId: serializer.fromJson<int?>(json['roomId']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      priority: $ComplaintsTable.$converterpriority.fromJson(serializer.fromJson<String>(json['priority'])),
      status: $ComplaintsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      imagePaths: serializer.fromJson<String>(json['imagePaths']),
      resolutionNotes: serializer.fromJson<String?>(json['resolutionNotes']),
      expenseId: serializer.fromJson<int?>(json['expenseId']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenantId': serializer.toJson<int?>(tenantId),
      'roomId': serializer.toJson<int?>(roomId),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'priority': serializer.toJson<String>($ComplaintsTable.$converterpriority.toJson(priority)),
      'status': serializer.toJson<String>($ComplaintsTable.$converterstatus.toJson(status)),
      'imagePaths': serializer.toJson<String>(imagePaths),
      'resolutionNotes': serializer.toJson<String?>(resolutionNotes),
      'expenseId': serializer.toJson<int?>(expenseId),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Complaint copyWith({
    int? id,
    Value<int?> tenantId = const Value.absent(),
    Value<int?> roomId = const Value.absent(),
    String? category,
    String? description,
    ComplaintPriority? priority,
    ComplaintStatus? status,
    String? imagePaths,
    Value<String?> resolutionNotes = const Value.absent(),
    Value<int?> expenseId = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<DateTime?> closedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Complaint(
    id: id ?? this.id,
    tenantId: tenantId.present ? tenantId.value : this.tenantId,
    roomId: roomId.present ? roomId.value : this.roomId,
    category: category ?? this.category,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    imagePaths: imagePaths ?? this.imagePaths,
    resolutionNotes: resolutionNotes.present ? resolutionNotes.value : this.resolutionNotes,
    expenseId: expenseId.present ? expenseId.value : this.expenseId,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Complaint copyWithCompanion(ComplaintsCompanion data) {
    return Complaint(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present ? data.description.value : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      imagePaths: data.imagePaths.present ? data.imagePaths.value : this.imagePaths,
      resolutionNotes: data.resolutionNotes.present ? data.resolutionNotes.value : this.resolutionNotes,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      resolvedAt: data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Complaint(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('roomId: $roomId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('expenseId: $expenseId, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    roomId,
    category,
    description,
    priority,
    status,
    imagePaths,
    resolutionNotes,
    expenseId,
    resolvedAt,
    closedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Complaint &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.roomId == this.roomId &&
          other.category == this.category &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.imagePaths == this.imagePaths &&
          other.resolutionNotes == this.resolutionNotes &&
          other.expenseId == this.expenseId &&
          other.resolvedAt == this.resolvedAt &&
          other.closedAt == this.closedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ComplaintsCompanion extends UpdateCompanion<Complaint> {
  final Value<int> id;
  final Value<int?> tenantId;
  final Value<int?> roomId;
  final Value<String> category;
  final Value<String> description;
  final Value<ComplaintPriority> priority;
  final Value<ComplaintStatus> status;
  final Value<String> imagePaths;
  final Value<String?> resolutionNotes;
  final Value<int?> expenseId;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> closedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ComplaintsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ComplaintsCompanion.insert({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.roomId = const Value.absent(),
    required String category,
    required String description,
    required ComplaintPriority priority,
    this.status = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : category = Value(category),
       description = Value(description),
       priority = Value(priority);
  static Insertable<Complaint> custom({
    Expression<int>? id,
    Expression<int>? tenantId,
    Expression<int>? roomId,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<String>? imagePaths,
    Expression<String>? resolutionNotes,
    Expression<int>? expenseId,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? closedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (roomId != null) 'room_id': roomId,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (imagePaths != null) 'image_paths': imagePaths,
      if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      if (expenseId != null) 'expense_id': expenseId,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ComplaintsCompanion copyWith({
    Value<int>? id,
    Value<int?>? tenantId,
    Value<int?>? roomId,
    Value<String>? category,
    Value<String>? description,
    Value<ComplaintPriority>? priority,
    Value<ComplaintStatus>? status,
    Value<String>? imagePaths,
    Value<String?>? resolutionNotes,
    Value<int?>? expenseId,
    Value<DateTime?>? resolvedAt,
    Value<DateTime?>? closedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ComplaintsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      roomId: roomId ?? this.roomId,
      category: category ?? this.category,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      imagePaths: imagePaths ?? this.imagePaths,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      expenseId: expenseId ?? this.expenseId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<int>(tenantId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>($ComplaintsTable.$converterpriority.toSql(priority.value));
    }
    if (status.present) {
      map['status'] = Variable<String>($ComplaintsTable.$converterstatus.toSql(status.value));
    }
    if (imagePaths.present) {
      map['image_paths'] = Variable<String>(imagePaths.value);
    }
    if (resolutionNotes.present) {
      map['resolution_notes'] = Variable<String>(resolutionNotes.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<int>(expenseId.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('roomId: $roomId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('expenseId: $expenseId, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NoticesTable extends Notices with TableInfo<$NoticesTable, Notice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 4000),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishDateMeta = const VerificationMeta('publishDate');
  @override
  late final GeneratedColumn<DateTime> publishDate = GeneratedColumn<DateTime>(
    'publish_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, body, category, publishDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notices';
  @override
  VerificationContext validateIntegrity(Insertable<Notice> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('publish_date')) {
      context.handle(_publishDateMeta, publishDate.isAcceptableOrUnknown(data['publish_date']!, _publishDateMeta));
    } else if (isInserting) {
      context.missing(_publishDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notice(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      publishDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}publish_date'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NoticesTable createAlias(String alias) {
    return $NoticesTable(attachedDatabase, alias);
  }
}

class Notice extends DataClass implements Insertable<Notice> {
  final int id;
  final String title;
  final String body;
  final String category;
  final DateTime publishDate;
  final DateTime createdAt;
  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.publishDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['category'] = Variable<String>(category);
    map['publish_date'] = Variable<DateTime>(publishDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NoticesCompanion toCompanion(bool nullToAbsent) {
    return NoticesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      category: Value(category),
      publishDate: Value(publishDate),
      createdAt: Value(createdAt),
    );
  }

  factory Notice.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notice(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      category: serializer.fromJson<String>(json['category']),
      publishDate: serializer.fromJson<DateTime>(json['publishDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'category': serializer.toJson<String>(category),
      'publishDate': serializer.toJson<DateTime>(publishDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notice copyWith({
    int? id,
    String? title,
    String? body,
    String? category,
    DateTime? publishDate,
    DateTime? createdAt,
  }) => Notice(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    category: category ?? this.category,
    publishDate: publishDate ?? this.publishDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Notice copyWithCompanion(NoticesCompanion data) {
    return Notice(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      category: data.category.present ? data.category.value : this.category,
      publishDate: data.publishDate.present ? data.publishDate.value : this.publishDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notice(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category, ')
          ..write('publishDate: $publishDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, body, category, publishDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notice &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.category == this.category &&
          other.publishDate == this.publishDate &&
          other.createdAt == this.createdAt);
}

class NoticesCompanion extends UpdateCompanion<Notice> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<String> category;
  final Value<DateTime> publishDate;
  final Value<DateTime> createdAt;
  const NoticesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.category = const Value.absent(),
    this.publishDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NoticesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String body,
    required String category,
    required DateTime publishDate,
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       body = Value(body),
       category = Value(category),
       publishDate = Value(publishDate);
  static Insertable<Notice> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? category,
    Expression<DateTime>? publishDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (category != null) 'category': category,
      if (publishDate != null) 'publish_date': publishDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NoticesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<String>? category,
    Value<DateTime>? publishDate,
    Value<DateTime>? createdAt,
  }) {
    return NoticesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      publishDate: publishDate ?? this.publishDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (publishDate.present) {
      map['publish_date'] = Variable<DateTime>(publishDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoticesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category, ')
          ..write('publishDate: $publishDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MenusTable extends Menus with TableInfo<$MenusTable, Menu> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _menuDateMeta = const VerificationMeta('menuDate');
  @override
  late final GeneratedColumn<DateTime> menuDate = GeneratedColumn<DateTime>(
    'menu_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _breakfastMeta = const VerificationMeta('breakfast');
  @override
  late final GeneratedColumn<String> breakfast = GeneratedColumn<String>(
    'breakfast',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lunchMeta = const VerificationMeta('lunch');
  @override
  late final GeneratedColumn<String> lunch = GeneratedColumn<String>(
    'lunch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dinnerMeta = const VerificationMeta('dinner');
  @override
  late final GeneratedColumn<String> dinner = GeneratedColumn<String>(
    'dinner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, menuDate, breakfast, lunch, dinner, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menus';
  @override
  VerificationContext validateIntegrity(Insertable<Menu> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('menu_date')) {
      context.handle(_menuDateMeta, menuDate.isAcceptableOrUnknown(data['menu_date']!, _menuDateMeta));
    } else if (isInserting) {
      context.missing(_menuDateMeta);
    }
    if (data.containsKey('breakfast')) {
      context.handle(_breakfastMeta, breakfast.isAcceptableOrUnknown(data['breakfast']!, _breakfastMeta));
    }
    if (data.containsKey('lunch')) {
      context.handle(_lunchMeta, lunch.isAcceptableOrUnknown(data['lunch']!, _lunchMeta));
    }
    if (data.containsKey('dinner')) {
      context.handle(_dinnerMeta, dinner.isAcceptableOrUnknown(data['dinner']!, _dinnerMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Menu map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Menu(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      menuDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}menu_date'])!,
      breakfast: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}breakfast'])!,
      lunch: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lunch'])!,
      dinner: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}dinner'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MenusTable createAlias(String alias) {
    return $MenusTable(attachedDatabase, alias);
  }
}

class Menu extends DataClass implements Insertable<Menu> {
  final int id;
  final DateTime menuDate;
  final String breakfast;
  final String lunch;
  final String dinner;
  final DateTime updatedAt;
  const Menu({
    required this.id,
    required this.menuDate,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['menu_date'] = Variable<DateTime>(menuDate);
    map['breakfast'] = Variable<String>(breakfast);
    map['lunch'] = Variable<String>(lunch);
    map['dinner'] = Variable<String>(dinner);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MenusCompanion toCompanion(bool nullToAbsent) {
    return MenusCompanion(
      id: Value(id),
      menuDate: Value(menuDate),
      breakfast: Value(breakfast),
      lunch: Value(lunch),
      dinner: Value(dinner),
      updatedAt: Value(updatedAt),
    );
  }

  factory Menu.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Menu(
      id: serializer.fromJson<int>(json['id']),
      menuDate: serializer.fromJson<DateTime>(json['menuDate']),
      breakfast: serializer.fromJson<String>(json['breakfast']),
      lunch: serializer.fromJson<String>(json['lunch']),
      dinner: serializer.fromJson<String>(json['dinner']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'menuDate': serializer.toJson<DateTime>(menuDate),
      'breakfast': serializer.toJson<String>(breakfast),
      'lunch': serializer.toJson<String>(lunch),
      'dinner': serializer.toJson<String>(dinner),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Menu copyWith({int? id, DateTime? menuDate, String? breakfast, String? lunch, String? dinner, DateTime? updatedAt}) =>
      Menu(
        id: id ?? this.id,
        menuDate: menuDate ?? this.menuDate,
        breakfast: breakfast ?? this.breakfast,
        lunch: lunch ?? this.lunch,
        dinner: dinner ?? this.dinner,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Menu copyWithCompanion(MenusCompanion data) {
    return Menu(
      id: data.id.present ? data.id.value : this.id,
      menuDate: data.menuDate.present ? data.menuDate.value : this.menuDate,
      breakfast: data.breakfast.present ? data.breakfast.value : this.breakfast,
      lunch: data.lunch.present ? data.lunch.value : this.lunch,
      dinner: data.dinner.present ? data.dinner.value : this.dinner,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Menu(')
          ..write('id: $id, ')
          ..write('menuDate: $menuDate, ')
          ..write('breakfast: $breakfast, ')
          ..write('lunch: $lunch, ')
          ..write('dinner: $dinner, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, menuDate, breakfast, lunch, dinner, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Menu &&
          other.id == this.id &&
          other.menuDate == this.menuDate &&
          other.breakfast == this.breakfast &&
          other.lunch == this.lunch &&
          other.dinner == this.dinner &&
          other.updatedAt == this.updatedAt);
}

class MenusCompanion extends UpdateCompanion<Menu> {
  final Value<int> id;
  final Value<DateTime> menuDate;
  final Value<String> breakfast;
  final Value<String> lunch;
  final Value<String> dinner;
  final Value<DateTime> updatedAt;
  const MenusCompanion({
    this.id = const Value.absent(),
    this.menuDate = const Value.absent(),
    this.breakfast = const Value.absent(),
    this.lunch = const Value.absent(),
    this.dinner = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MenusCompanion.insert({
    this.id = const Value.absent(),
    required DateTime menuDate,
    this.breakfast = const Value.absent(),
    this.lunch = const Value.absent(),
    this.dinner = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : menuDate = Value(menuDate);
  static Insertable<Menu> custom({
    Expression<int>? id,
    Expression<DateTime>? menuDate,
    Expression<String>? breakfast,
    Expression<String>? lunch,
    Expression<String>? dinner,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (menuDate != null) 'menu_date': menuDate,
      if (breakfast != null) 'breakfast': breakfast,
      if (lunch != null) 'lunch': lunch,
      if (dinner != null) 'dinner': dinner,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MenusCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? menuDate,
    Value<String>? breakfast,
    Value<String>? lunch,
    Value<String>? dinner,
    Value<DateTime>? updatedAt,
  }) {
    return MenusCompanion(
      id: id ?? this.id,
      menuDate: menuDate ?? this.menuDate,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (menuDate.present) {
      map['menu_date'] = Variable<DateTime>(menuDate.value);
    }
    if (breakfast.present) {
      map['breakfast'] = Variable<String>(breakfast.value);
    }
    if (lunch.present) {
      map['lunch'] = Variable<String>(lunch.value);
    }
    if (dinner.present) {
      map['dinner'] = Variable<String>(dinner.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenusCompanion(')
          ..write('id: $id, ')
          ..write('menuDate: $menuDate, ')
          ..write('breakfast: $breakfast, ')
          ..write('lunch: $lunch, ')
          ..write('dinner: $dinner, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entity, entityId, action, details, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta, entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta, entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta, action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta, details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      entityId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}entity_id']),
      action: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      details: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}details']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final int id;
  final String entity;
  final int? entityId;
  final String action;
  final String? details;
  final DateTime createdAt;
  const AuditLog({
    required this.id,
    required this.entity,
    this.entityId,
    required this.action,
    this.details,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: entityId == null && nullToAbsent ? const Value.absent() : Value(entityId),
      action: Value(action),
      details: details == null && nullToAbsent ? const Value.absent() : Value(details),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      details: serializer.fromJson<String?>(json['details']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<int?>(entityId),
      'action': serializer.toJson<String>(action),
      'details': serializer.toJson<String?>(details),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith({
    int? id,
    String? entity,
    Value<int?> entityId = const Value.absent(),
    String? action,
    Value<String?> details = const Value.absent(),
    DateTime? createdAt,
  }) => AuditLog(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityId: entityId.present ? entityId.value : this.entityId,
    action: action ?? this.action,
    details: details.present ? details.value : this.details,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      details: data.details.present ? data.details.value : this.details,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entity, entityId, action, details, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.details == this.details &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<int> id;
  final Value<String> entity;
  final Value<int?> entityId;
  final Value<String> action;
  final Value<String?> details;
  final Value<DateTime> createdAt;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    this.entityId = const Value.absent(),
    required String action,
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entity = Value(entity),
       action = Value(action);
  static Insertable<AuditLog> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<int>? entityId,
    Expression<String>? action,
    Expression<String>? details,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (details != null) 'details': details,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AuditLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? entity,
    Value<int?>? entityId,
    Value<String>? action,
    Value<String?>? details,
    Value<DateTime>? createdAt,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value), updatedAt: Value(updatedAt));
  }

  factory AppSetting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value, updatedAt: updatedAt ?? this.updatedAt);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting && other.key == this.key && other.value == this.value && other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PgProfilesTable pgProfiles = $PgProfilesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $BedsTable beds = $BedsTable(this);
  late final $TenantsTable tenants = $TenantsTable(this);
  late final $AllocationsTable allocations = $AllocationsTable(this);
  late final $RentInvoicesTable rentInvoices = $RentInvoicesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PaymentAllocationsTable paymentAllocations = $PaymentAllocationsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ComplaintsTable complaints = $ComplaintsTable(this);
  late final $NoticesTable notices = $NoticesTable(this);
  late final $MenusTable menus = $MenusTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index idxRoomsFloor = Index('idx_rooms_floor', 'CREATE INDEX idx_rooms_floor ON rooms (floor)');
  late final Index idxBedsRoom = Index('idx_beds_room', 'CREATE INDEX idx_beds_room ON beds (room_id)');
  late final Index idxTenantsPhone = Index('idx_tenants_phone', 'CREATE INDEX idx_tenants_phone ON tenants (phone)');
  late final Index idxTenantsName = Index('idx_tenants_name', 'CREATE INDEX idx_tenants_name ON tenants (full_name)');
  late final Index idxTenantsStatus = Index(
    'idx_tenants_status',
    'CREATE INDEX idx_tenants_status ON tenants (status)',
  );
  late final Index idxAllocationsTenant = Index(
    'idx_allocations_tenant',
    'CREATE INDEX idx_allocations_tenant ON allocations (tenant_id)',
  );
  late final Index idxAllocationsBed = Index(
    'idx_allocations_bed',
    'CREATE INDEX idx_allocations_bed ON allocations (bed_id)',
  );
  late final Index idxInvoicesTenant = Index(
    'idx_invoices_tenant',
    'CREATE INDEX idx_invoices_tenant ON rent_invoices (tenant_id)',
  );
  late final Index idxInvoicesPeriod = Index(
    'idx_invoices_period',
    'CREATE INDEX idx_invoices_period ON rent_invoices (period_start)',
  );
  late final Index idxInvoicesDue = Index(
    'idx_invoices_due',
    'CREATE INDEX idx_invoices_due ON rent_invoices (due_date)',
  );
  late final Index idxPaymentsTenant = Index(
    'idx_payments_tenant',
    'CREATE INDEX idx_payments_tenant ON payments (tenant_id)',
  );
  late final Index idxPaymentsDate = Index(
    'idx_payments_date',
    'CREATE INDEX idx_payments_date ON payments (payment_date)',
  );
  late final Index idxPayallocPayment = Index(
    'idx_payalloc_payment',
    'CREATE INDEX idx_payalloc_payment ON payment_allocations (payment_id)',
  );
  late final Index idxPayallocInvoice = Index(
    'idx_payalloc_invoice',
    'CREATE INDEX idx_payalloc_invoice ON payment_allocations (invoice_id)',
  );
  late final Index idxExpensesDate = Index(
    'idx_expenses_date',
    'CREATE INDEX idx_expenses_date ON expenses (expense_date)',
  );
  late final Index idxExpensesCategory = Index(
    'idx_expenses_category',
    'CREATE INDEX idx_expenses_category ON expenses (category)',
  );
  late final Index idxComplaintsStatus = Index(
    'idx_complaints_status',
    'CREATE INDEX idx_complaints_status ON complaints (status)',
  );
  late final Index idxNoticesPublish = Index(
    'idx_notices_publish',
    'CREATE INDEX idx_notices_publish ON notices (publish_date)',
  );
  late final Index idxAuditEntity = Index(
    'idx_audit_entity',
    'CREATE INDEX idx_audit_entity ON audit_logs (entity, entity_id)',
  );
  late final DashboardDao dashboardDao = DashboardDao(this as AppDatabase);
  late final RoomsDao roomsDao = RoomsDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final TenantsDao tenantsDao = TenantsDao(this as AppDatabase);
  late final BillingDao billingDao = BillingDao(this as AppDatabase);
  late final OpsDao opsDao = OpsDao(this as AppDatabase);
  late final ReportsDao reportsDao = ReportsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pgProfiles,
    rooms,
    beds,
    tenants,
    allocations,
    rentInvoices,
    payments,
    paymentAllocations,
    expenses,
    complaints,
    notices,
    menus,
    auditLogs,
    appSettings,
    idxRoomsFloor,
    idxBedsRoom,
    idxTenantsPhone,
    idxTenantsName,
    idxTenantsStatus,
    idxAllocationsTenant,
    idxAllocationsBed,
    idxInvoicesTenant,
    idxInvoicesPeriod,
    idxInvoicesDue,
    idxPaymentsTenant,
    idxPaymentsDate,
    idxPayallocPayment,
    idxPayallocInvoice,
    idxExpensesDate,
    idxExpensesCategory,
    idxComplaintsStatus,
    idxNoticesPublish,
    idxAuditEntity,
  ];
}

typedef $$PgProfilesTableCreateCompanionBuilder = PgProfilesCompanion Function({
  Value<int> id,
  required String name,
  required String address,
  required String ownerName,
  required String ownerPhone,
  Value<String?> upiId,
  Value<int> defaultRentDueDay,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PgProfilesTableUpdateCompanionBuilder = PgProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> address,
  Value<String> ownerName,
  Value<String> ownerPhone,
  Value<String?> upiId,
  Value<int> defaultRentDueDay,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$PgProfilesTableFilterComposer extends Composer<_$AppDatabase, $PgProfilesTable> {
  $$PgProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerPhone =>
      $composableBuilder(column: $table.ownerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultRentDueDay =>
      $composableBuilder(column: $table.defaultRentDueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PgProfilesTableOrderingComposer extends Composer<_$AppDatabase, $PgProfilesTable> {
  $$PgProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerPhone =>
      $composableBuilder(column: $table.ownerPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultRentDueDay =>
      $composableBuilder(column: $table.defaultRentDueDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PgProfilesTableAnnotationComposer extends Composer<_$AppDatabase, $PgProfilesTable> {
  $$PgProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address => $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get ownerName => $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get ownerPhone => $composableBuilder(column: $table.ownerPhone, builder: (column) => column);

  GeneratedColumn<String> get upiId => $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<int> get defaultRentDueDay =>
      $composableBuilder(column: $table.defaultRentDueDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PgProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PgProfilesTable,
          PgProfile,
          $$PgProfilesTableFilterComposer,
          $$PgProfilesTableOrderingComposer,
          $$PgProfilesTableAnnotationComposer,
          $$PgProfilesTableCreateCompanionBuilder,
          $$PgProfilesTableUpdateCompanionBuilder,
          (PgProfile, BaseReferences<_$AppDatabase, $PgProfilesTable, PgProfile>),
          PgProfile,
          PrefetchHooks Function()
        > {
  $$PgProfilesTableTableManager(_$AppDatabase db, $PgProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PgProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PgProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PgProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> ownerName = const Value.absent(),
                Value<String> ownerPhone = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<int> defaultRentDueDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PgProfilesCompanion(
                id: id,
                name: name,
                address: address,
                ownerName: ownerName,
                ownerPhone: ownerPhone,
                upiId: upiId,
                defaultRentDueDay: defaultRentDueDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String address,
                required String ownerName,
                required String ownerPhone,
                Value<String?> upiId = const Value.absent(),
                Value<int> defaultRentDueDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PgProfilesCompanion.insert(
                id: id,
                name: name,
                address: address,
                ownerName: ownerName,
                ownerPhone: ownerPhone,
                upiId: upiId,
                defaultRentDueDay: defaultRentDueDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PgProfilesTable, PgProfile>(table),
                  BaseReferences<_$AppDatabase, $PgProfilesTable, PgProfile>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PgProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PgProfilesTable,
      PgProfile,
      $$PgProfilesTableFilterComposer,
      $$PgProfilesTableOrderingComposer,
      $$PgProfilesTableAnnotationComposer,
      $$PgProfilesTableCreateCompanionBuilder,
      $$PgProfilesTableUpdateCompanionBuilder,
      (PgProfile, BaseReferences<_$AppDatabase, $PgProfilesTable, PgProfile>),
      PgProfile,
      PrefetchHooks Function()
    >;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  Value<int> id,
  required String roomNumber,
  required int floor,
  required int rentPaise,
  Value<String?> notes,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<int> id,
  Value<String> roomNumber,
  Value<int> floor,
  Value<int> rentPaise,
  Value<String?> notes,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$RoomsTableReferences extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BedsTable, List<Bed>> _bedsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.beds, aliasName: 'rooms__id__beds__room_id');

  $$BedsTableProcessedTableManager get bedsRefs {
    final manager = $$BedsTableTableManager(
      $_db,
      $_db.beds,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bedsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>> _complaintsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.complaints, aliasName: 'rooms__id__complaints__room_id');

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomNumber =>
      $composableBuilder(column: $table.roomNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get floor => $composableBuilder(column: $table.floor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rentPaise =>
      $composableBuilder(column: $table.rentPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> bedsRefs(Expression<bool> Function($$BedsTableFilterComposer f) f) {
    final $$BedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beds,
      getReferencedColumn: (t) => t.roomId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BedsTableFilterComposer(
            $db: $db,
            $table: $db.beds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintsRefs(Expression<bool> Function($$ComplaintsTableFilterComposer f) f) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.roomId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomNumber =>
      $composableBuilder(column: $table.roomNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get floor =>
      $composableBuilder(column: $table.floor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rentPaise =>
      $composableBuilder(column: $table.rentPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RoomsTableAnnotationComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomNumber => $composableBuilder(column: $table.roomNumber, builder: (column) => column);

  GeneratedColumn<int> get floor => $composableBuilder(column: $table.floor, builder: (column) => column);

  GeneratedColumn<int> get rentPaise => $composableBuilder(column: $table.rentPaise, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> bedsRefs<T extends Object>(Expression<T> Function($$BedsTableAnnotationComposer a) f) {
    final $$BedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beds,
      getReferencedColumn: (t) => t.roomId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BedsTableAnnotationComposer(
            $db: $db,
            $table: $db.beds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> complaintsRefs<T extends Object>(Expression<T> Function($$ComplaintsTableAnnotationComposer a) f) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.roomId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, $$RoomsTableReferences),
          Room,
          PrefetchHooks Function({bool bedsRefs, bool complaintsRefs})
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> roomNumber = const Value.absent(),
                Value<int> floor = const Value.absent(),
                Value<int> rentPaise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                roomNumber: roomNumber,
                floor: floor,
                rentPaise: rentPaise,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String roomNumber,
                required int floor,
                required int rentPaise,
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                roomNumber: roomNumber,
                floor: floor,
                rentPaise: rentPaise,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$RoomsTable, Room>(table), $$RoomsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({bedsRefs = false, complaintsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bedsRefs) db.beds, if (complaintsRefs) db.complaints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bedsRefs)
                    await $_getPrefetchedDataByColumns<Room, $RoomsTable, Bed, $BedsTable>(
                      currentTable: table,
                      referencedTable: $$RoomsTableReferences._bedsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoomsTableReferences(db, table, p0).bedsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'room_id',
                      typedResults: items,
                    ),
                  if (complaintsRefs)
                    await $_getPrefetchedDataByColumns<Room, $RoomsTable, Complaint, $ComplaintsTable>(
                      currentTable: table,
                      referencedTable: $$RoomsTableReferences._complaintsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoomsTableReferences(db, table, p0).complaintsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'room_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, $$RoomsTableReferences),
      Room,
      PrefetchHooks Function({bool bedsRefs, bool complaintsRefs})
    >;
typedef $$BedsTableCreateCompanionBuilder = BedsCompanion Function({
  Value<int> id,
  required int roomId,
  required String label,
  Value<BedStatus> status,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BedsTableUpdateCompanionBuilder = BedsCompanion Function({
  Value<int> id,
  Value<int> roomId,
  Value<String> label,
  Value<BedStatus> status,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BedsTableReferences extends BaseReferences<_$AppDatabase, $BedsTable, Bed> {
  $$BedsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias('beds__room_id__rooms__id');

  $$RoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<int>('room_id')!;

    final manager = $$RoomsTableTableManager($_db, $_db.rooms).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AllocationsTable, List<Allocation>> _allocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.allocations, aliasName: 'beds__id__allocations__bed_id');

  $$AllocationsTableProcessedTableManager get allocationsRefs {
    final manager = $$AllocationsTableTableManager(
      $_db,
      $_db.allocations,
    ).filter((f) => f.bedId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_allocationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BedsTableFilterComposer extends Composer<_$AppDatabase, $BedsTable> {
  $$BedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BedStatus, BedStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> allocationsRefs(Expression<bool> Function($$AllocationsTableFilterComposer f) f) {
    final $$AllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.bedId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableFilterComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BedsTableOrderingComposer extends Composer<_$AppDatabase, $BedsTable> {
  $$BedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BedsTableAnnotationComposer extends Composer<_$AppDatabase, $BedsTable> {
  $$BedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BedStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> allocationsRefs<T extends Object>(Expression<T> Function($$AllocationsTableAnnotationComposer a) f) {
    final $$AllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.bedId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BedsTable,
          Bed,
          $$BedsTableFilterComposer,
          $$BedsTableOrderingComposer,
          $$BedsTableAnnotationComposer,
          $$BedsTableCreateCompanionBuilder,
          $$BedsTableUpdateCompanionBuilder,
          (Bed, $$BedsTableReferences),
          Bed,
          PrefetchHooks Function({bool roomId, bool allocationsRefs})
        > {
  $$BedsTableTableManager(_$AppDatabase db, $BedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> roomId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<BedStatus> status = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BedsCompanion(
                id: id,
                roomId: roomId,
                label: label,
                status: status,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roomId,
                required String label,
                Value<BedStatus> status = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BedsCompanion.insert(
                id: id,
                roomId: roomId,
                label: label,
                status: status,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$BedsTable, Bed>(table), $$BedsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({roomId = false, allocationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (allocationsRefs) db.allocations],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roomId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.roomId,
                        referencedTable: $$BedsTableReferences._roomIdTable(db),
                        referencedColumn: $$BedsTableReferences._roomIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (allocationsRefs)
                    await $_getPrefetchedDataByColumns<Bed, $BedsTable, Allocation, $AllocationsTable>(
                      currentTable: table,
                      referencedTable: $$BedsTableReferences._allocationsRefsTable(db),
                      managerFromTypedResult: (p0) => $$BedsTableReferences(db, table, p0).allocationsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'bed_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BedsTable,
      Bed,
      $$BedsTableFilterComposer,
      $$BedsTableOrderingComposer,
      $$BedsTableAnnotationComposer,
      $$BedsTableCreateCompanionBuilder,
      $$BedsTableUpdateCompanionBuilder,
      (Bed, $$BedsTableReferences),
      Bed,
      PrefetchHooks Function({bool roomId, bool allocationsRefs})
    >;
typedef $$TenantsTableCreateCompanionBuilder = TenantsCompanion Function({
  Value<int> id,
  required String fullName,
  required String phone,
  Value<String?> email,
  required Gender gender,
  Value<String?> photoPath,
  Value<String?> idProofType,
  Value<String?> idProofNumber,
  Value<String?> idProofPath,
  Value<String?> emergencyContactName,
  Value<String?> emergencyContactPhone,
  Value<String?> occupation,
  required DateTime joiningDate,
  required int monthlyRentPaise,
  Value<int> securityDepositPaise,
  Value<int> advancePaise,
  required int rentDueDay,
  Value<TenantStatus> status,
  Value<DateTime?> noticeDate,
  Value<DateTime?> expectedCheckoutDate,
  Value<DateTime?> checkoutDate,
  Value<int> depositAdjustedPaise,
  Value<int> depositRefundedPaise,
  Value<String?> checkoutNotes,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$TenantsTableUpdateCompanionBuilder = TenantsCompanion Function({
  Value<int> id,
  Value<String> fullName,
  Value<String> phone,
  Value<String?> email,
  Value<Gender> gender,
  Value<String?> photoPath,
  Value<String?> idProofType,
  Value<String?> idProofNumber,
  Value<String?> idProofPath,
  Value<String?> emergencyContactName,
  Value<String?> emergencyContactPhone,
  Value<String?> occupation,
  Value<DateTime> joiningDate,
  Value<int> monthlyRentPaise,
  Value<int> securityDepositPaise,
  Value<int> advancePaise,
  Value<int> rentDueDay,
  Value<TenantStatus> status,
  Value<DateTime?> noticeDate,
  Value<DateTime?> expectedCheckoutDate,
  Value<DateTime?> checkoutDate,
  Value<int> depositAdjustedPaise,
  Value<int> depositRefundedPaise,
  Value<String?> checkoutNotes,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$TenantsTableReferences extends BaseReferences<_$AppDatabase, $TenantsTable, Tenant> {
  $$TenantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AllocationsTable, List<Allocation>> _allocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.allocations, aliasName: 'tenants__id__allocations__tenant_id');

  $$AllocationsTableProcessedTableManager get allocationsRefs {
    final manager = $$AllocationsTableTableManager(
      $_db,
      $_db.allocations,
    ).filter((f) => f.tenantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_allocationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RentInvoicesTable, List<RentInvoice>> _rentInvoicesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.rentInvoices, aliasName: 'tenants__id__rent_invoices__tenant_id');

  $$RentInvoicesTableProcessedTableManager get rentInvoicesRefs {
    final manager = $$RentInvoicesTableTableManager(
      $_db,
      $_db.rentInvoices,
    ).filter((f) => f.tenantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rentInvoicesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments, aliasName: 'tenants__id__payments__tenant_id');

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.tenantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>> _complaintsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.complaints, aliasName: 'tenants__id__complaints__tenant_id');

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.tenantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TenantsTableFilterComposer extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Gender, Gender, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idProofType =>
      $composableBuilder(column: $table.idProofType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idProofNumber =>
      $composableBuilder(column: $table.idProofNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idProofPath =>
      $composableBuilder(column: $table.idProofPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emergencyContactName =>
      $composableBuilder(column: $table.emergencyContactName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emergencyContactPhone =>
      $composableBuilder(column: $table.emergencyContactPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occupation =>
      $composableBuilder(column: $table.occupation, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joiningDate =>
      $composableBuilder(column: $table.joiningDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyRentPaise =>
      $composableBuilder(column: $table.monthlyRentPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get securityDepositPaise =>
      $composableBuilder(column: $table.securityDepositPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get advancePaise =>
      $composableBuilder(column: $table.advancePaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rentDueDay =>
      $composableBuilder(column: $table.rentDueDay, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TenantStatus, TenantStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get noticeDate =>
      $composableBuilder(column: $table.noticeDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedCheckoutDate =>
      $composableBuilder(column: $table.expectedCheckoutDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkoutDate =>
      $composableBuilder(column: $table.checkoutDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get depositAdjustedPaise =>
      $composableBuilder(column: $table.depositAdjustedPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get depositRefundedPaise =>
      $composableBuilder(column: $table.depositRefundedPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checkoutNotes =>
      $composableBuilder(column: $table.checkoutNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> allocationsRefs(Expression<bool> Function($$AllocationsTableFilterComposer f) f) {
    final $$AllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableFilterComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rentInvoicesRefs(Expression<bool> Function($$RentInvoicesTableFilterComposer f) f) {
    final $$RentInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> complaintsRefs(Expression<bool> Function($$ComplaintsTableFilterComposer f) f) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TenantsTableOrderingComposer extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idProofType =>
      $composableBuilder(column: $table.idProofType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idProofNumber =>
      $composableBuilder(column: $table.idProofNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idProofPath =>
      $composableBuilder(column: $table.idProofPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emergencyContactName =>
      $composableBuilder(column: $table.emergencyContactName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emergencyContactPhone =>
      $composableBuilder(column: $table.emergencyContactPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occupation =>
      $composableBuilder(column: $table.occupation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joiningDate =>
      $composableBuilder(column: $table.joiningDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyRentPaise =>
      $composableBuilder(column: $table.monthlyRentPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get securityDepositPaise =>
      $composableBuilder(column: $table.securityDepositPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get advancePaise =>
      $composableBuilder(column: $table.advancePaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rentDueDay =>
      $composableBuilder(column: $table.rentDueDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get noticeDate =>
      $composableBuilder(column: $table.noticeDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedCheckoutDate =>
      $composableBuilder(column: $table.expectedCheckoutDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkoutDate =>
      $composableBuilder(column: $table.checkoutDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get depositAdjustedPaise =>
      $composableBuilder(column: $table.depositAdjustedPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get depositRefundedPaise =>
      $composableBuilder(column: $table.depositRefundedPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checkoutNotes =>
      $composableBuilder(column: $table.checkoutNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TenantsTableAnnotationComposer extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName => $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone => $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email => $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Gender, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get photoPath => $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get idProofType =>
      $composableBuilder(column: $table.idProofType, builder: (column) => column);

  GeneratedColumn<String> get idProofNumber =>
      $composableBuilder(column: $table.idProofNumber, builder: (column) => column);

  GeneratedColumn<String> get idProofPath =>
      $composableBuilder(column: $table.idProofPath, builder: (column) => column);

  GeneratedColumn<String> get emergencyContactName =>
      $composableBuilder(column: $table.emergencyContactName, builder: (column) => column);

  GeneratedColumn<String> get emergencyContactPhone =>
      $composableBuilder(column: $table.emergencyContactPhone, builder: (column) => column);

  GeneratedColumn<String> get occupation => $composableBuilder(column: $table.occupation, builder: (column) => column);

  GeneratedColumn<DateTime> get joiningDate =>
      $composableBuilder(column: $table.joiningDate, builder: (column) => column);

  GeneratedColumn<int> get monthlyRentPaise =>
      $composableBuilder(column: $table.monthlyRentPaise, builder: (column) => column);

  GeneratedColumn<int> get securityDepositPaise =>
      $composableBuilder(column: $table.securityDepositPaise, builder: (column) => column);

  GeneratedColumn<int> get advancePaise => $composableBuilder(column: $table.advancePaise, builder: (column) => column);

  GeneratedColumn<int> get rentDueDay => $composableBuilder(column: $table.rentDueDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TenantStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get noticeDate =>
      $composableBuilder(column: $table.noticeDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedCheckoutDate =>
      $composableBuilder(column: $table.expectedCheckoutDate, builder: (column) => column);

  GeneratedColumn<DateTime> get checkoutDate =>
      $composableBuilder(column: $table.checkoutDate, builder: (column) => column);

  GeneratedColumn<int> get depositAdjustedPaise =>
      $composableBuilder(column: $table.depositAdjustedPaise, builder: (column) => column);

  GeneratedColumn<int> get depositRefundedPaise =>
      $composableBuilder(column: $table.depositRefundedPaise, builder: (column) => column);

  GeneratedColumn<String> get checkoutNotes =>
      $composableBuilder(column: $table.checkoutNotes, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> allocationsRefs<T extends Object>(Expression<T> Function($$AllocationsTableAnnotationComposer a) f) {
    final $$AllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rentInvoicesRefs<T extends Object>(Expression<T> Function($$RentInvoicesTableAnnotationComposer a) f) {
    final $$RentInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> complaintsRefs<T extends Object>(Expression<T> Function($$ComplaintsTableAnnotationComposer a) f) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.tenantId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TenantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TenantsTable,
          Tenant,
          $$TenantsTableFilterComposer,
          $$TenantsTableOrderingComposer,
          $$TenantsTableAnnotationComposer,
          $$TenantsTableCreateCompanionBuilder,
          $$TenantsTableUpdateCompanionBuilder,
          (Tenant, $$TenantsTableReferences),
          Tenant,
          PrefetchHooks Function({bool allocationsRefs, bool rentInvoicesRefs, bool paymentsRefs, bool complaintsRefs})
        > {
  $$TenantsTableTableManager(_$AppDatabase db, $TenantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TenantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TenantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TenantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<Gender> gender = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> idProofType = const Value.absent(),
                Value<String?> idProofNumber = const Value.absent(),
                Value<String?> idProofPath = const Value.absent(),
                Value<String?> emergencyContactName = const Value.absent(),
                Value<String?> emergencyContactPhone = const Value.absent(),
                Value<String?> occupation = const Value.absent(),
                Value<DateTime> joiningDate = const Value.absent(),
                Value<int> monthlyRentPaise = const Value.absent(),
                Value<int> securityDepositPaise = const Value.absent(),
                Value<int> advancePaise = const Value.absent(),
                Value<int> rentDueDay = const Value.absent(),
                Value<TenantStatus> status = const Value.absent(),
                Value<DateTime?> noticeDate = const Value.absent(),
                Value<DateTime?> expectedCheckoutDate = const Value.absent(),
                Value<DateTime?> checkoutDate = const Value.absent(),
                Value<int> depositAdjustedPaise = const Value.absent(),
                Value<int> depositRefundedPaise = const Value.absent(),
                Value<String?> checkoutNotes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TenantsCompanion(
                id: id,
                fullName: fullName,
                phone: phone,
                email: email,
                gender: gender,
                photoPath: photoPath,
                idProofType: idProofType,
                idProofNumber: idProofNumber,
                idProofPath: idProofPath,
                emergencyContactName: emergencyContactName,
                emergencyContactPhone: emergencyContactPhone,
                occupation: occupation,
                joiningDate: joiningDate,
                monthlyRentPaise: monthlyRentPaise,
                securityDepositPaise: securityDepositPaise,
                advancePaise: advancePaise,
                rentDueDay: rentDueDay,
                status: status,
                noticeDate: noticeDate,
                expectedCheckoutDate: expectedCheckoutDate,
                checkoutDate: checkoutDate,
                depositAdjustedPaise: depositAdjustedPaise,
                depositRefundedPaise: depositRefundedPaise,
                checkoutNotes: checkoutNotes,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fullName,
                required String phone,
                Value<String?> email = const Value.absent(),
                required Gender gender,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> idProofType = const Value.absent(),
                Value<String?> idProofNumber = const Value.absent(),
                Value<String?> idProofPath = const Value.absent(),
                Value<String?> emergencyContactName = const Value.absent(),
                Value<String?> emergencyContactPhone = const Value.absent(),
                Value<String?> occupation = const Value.absent(),
                required DateTime joiningDate,
                required int monthlyRentPaise,
                Value<int> securityDepositPaise = const Value.absent(),
                Value<int> advancePaise = const Value.absent(),
                required int rentDueDay,
                Value<TenantStatus> status = const Value.absent(),
                Value<DateTime?> noticeDate = const Value.absent(),
                Value<DateTime?> expectedCheckoutDate = const Value.absent(),
                Value<DateTime?> checkoutDate = const Value.absent(),
                Value<int> depositAdjustedPaise = const Value.absent(),
                Value<int> depositRefundedPaise = const Value.absent(),
                Value<String?> checkoutNotes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TenantsCompanion.insert(
                id: id,
                fullName: fullName,
                phone: phone,
                email: email,
                gender: gender,
                photoPath: photoPath,
                idProofType: idProofType,
                idProofNumber: idProofNumber,
                idProofPath: idProofPath,
                emergencyContactName: emergencyContactName,
                emergencyContactPhone: emergencyContactPhone,
                occupation: occupation,
                joiningDate: joiningDate,
                monthlyRentPaise: monthlyRentPaise,
                securityDepositPaise: securityDepositPaise,
                advancePaise: advancePaise,
                rentDueDay: rentDueDay,
                status: status,
                noticeDate: noticeDate,
                expectedCheckoutDate: expectedCheckoutDate,
                checkoutDate: checkoutDate,
                depositAdjustedPaise: depositAdjustedPaise,
                depositRefundedPaise: depositRefundedPaise,
                checkoutNotes: checkoutNotes,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$TenantsTable, Tenant>(table), $$TenantsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({allocationsRefs = false, rentInvoicesRefs = false, paymentsRefs = false, complaintsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (allocationsRefs) db.allocations,
                    if (rentInvoicesRefs) db.rentInvoices,
                    if (paymentsRefs) db.payments,
                    if (complaintsRefs) db.complaints,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (allocationsRefs)
                        await $_getPrefetchedDataByColumns<Tenant, $TenantsTable, Allocation, $AllocationsTable>(
                          currentTable: table,
                          referencedTable: $$TenantsTableReferences._allocationsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TenantsTableReferences(db, table, p0).allocationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tenant_id',
                          typedResults: items,
                        ),
                      if (rentInvoicesRefs)
                        await $_getPrefetchedDataByColumns<Tenant, $TenantsTable, RentInvoice, $RentInvoicesTable>(
                          currentTable: table,
                          referencedTable: $$TenantsTableReferences._rentInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) => $$TenantsTableReferences(db, table, p0).rentInvoicesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tenant_id',
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedDataByColumns<Tenant, $TenantsTable, Payment, $PaymentsTable>(
                          currentTable: table,
                          referencedTable: $$TenantsTableReferences._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TenantsTableReferences(db, table, p0).paymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tenant_id',
                          typedResults: items,
                        ),
                      if (complaintsRefs)
                        await $_getPrefetchedDataByColumns<Tenant, $TenantsTable, Complaint, $ComplaintsTable>(
                          currentTable: table,
                          referencedTable: $$TenantsTableReferences._complaintsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TenantsTableReferences(db, table, p0).complaintsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tenant_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TenantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TenantsTable,
      Tenant,
      $$TenantsTableFilterComposer,
      $$TenantsTableOrderingComposer,
      $$TenantsTableAnnotationComposer,
      $$TenantsTableCreateCompanionBuilder,
      $$TenantsTableUpdateCompanionBuilder,
      (Tenant, $$TenantsTableReferences),
      Tenant,
      PrefetchHooks Function({bool allocationsRefs, bool rentInvoicesRefs, bool paymentsRefs, bool complaintsRefs})
    >;
typedef $$AllocationsTableCreateCompanionBuilder = AllocationsCompanion Function({
  Value<int> id,
  required int tenantId,
  required int bedId,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<bool> isActive,
  required int rentPaise,
  Value<String?> endReason,
  Value<DateTime> createdAt,
});
typedef $$AllocationsTableUpdateCompanionBuilder = AllocationsCompanion Function({
  Value<int> id,
  Value<int> tenantId,
  Value<int> bedId,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<bool> isActive,
  Value<int> rentPaise,
  Value<String?> endReason,
  Value<DateTime> createdAt,
});

final class $$AllocationsTableReferences extends BaseReferences<_$AppDatabase, $AllocationsTable, Allocation> {
  $$AllocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantIdTable(_$AppDatabase db) =>
      db.tenants.createAlias('allocations__tenant_id__tenants__id');

  $$TenantsTableProcessedTableManager get tenantId {
    final $_column = $_itemColumn<int>('tenant_id')!;

    final manager = $$TenantsTableTableManager($_db, $_db.tenants).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BedsTable _bedIdTable(_$AppDatabase db) => db.beds.createAlias('allocations__bed_id__beds__id');

  $$BedsTableProcessedTableManager get bedId {
    final $_column = $_itemColumn<int>('bed_id')!;

    final manager = $$BedsTableTableManager($_db, $_db.beds).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bedIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RentInvoicesTable, List<RentInvoice>> _rentInvoicesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.rentInvoices, aliasName: 'allocations__id__rent_invoices__allocation_id');

  $$RentInvoicesTableProcessedTableManager get rentInvoicesRefs {
    final manager = $$RentInvoicesTableTableManager(
      $_db,
      $_db.rentInvoices,
    ).filter((f) => f.allocationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rentInvoicesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AllocationsTableFilterComposer extends Composer<_$AppDatabase, $AllocationsTable> {
  $$AllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rentPaise =>
      $composableBuilder(column: $table.rentPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TenantsTableFilterComposer get tenantId {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BedsTableFilterComposer get bedId {
    final $$BedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bedId,
      referencedTable: $db.beds,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BedsTableFilterComposer(
            $db: $db,
            $table: $db.beds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> rentInvoicesRefs(Expression<bool> Function($$RentInvoicesTableFilterComposer f) f) {
    final $$RentInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.allocationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AllocationsTableOrderingComposer extends Composer<_$AppDatabase, $AllocationsTable> {
  $$AllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rentPaise =>
      $composableBuilder(column: $table.rentPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TenantsTableOrderingComposer get tenantId {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BedsTableOrderingComposer get bedId {
    final $$BedsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bedId,
      referencedTable: $db.beds,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BedsTableOrderingComposer(
            $db: $db,
            $table: $db.beds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableAnnotationComposer extends Composer<_$AppDatabase, $AllocationsTable> {
  $$AllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate => $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get rentPaise => $composableBuilder(column: $table.rentPaise, builder: (column) => column);

  GeneratedColumn<String> get endReason => $composableBuilder(column: $table.endReason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantId {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BedsTableAnnotationComposer get bedId {
    final $$BedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bedId,
      referencedTable: $db.beds,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BedsTableAnnotationComposer(
            $db: $db,
            $table: $db.beds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> rentInvoicesRefs<T extends Object>(Expression<T> Function($$RentInvoicesTableAnnotationComposer a) f) {
    final $$RentInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.allocationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllocationsTable,
          Allocation,
          $$AllocationsTableFilterComposer,
          $$AllocationsTableOrderingComposer,
          $$AllocationsTableAnnotationComposer,
          $$AllocationsTableCreateCompanionBuilder,
          $$AllocationsTableUpdateCompanionBuilder,
          (Allocation, $$AllocationsTableReferences),
          Allocation,
          PrefetchHooks Function({bool tenantId, bool bedId, bool rentInvoicesRefs})
        > {
  $$AllocationsTableTableManager(_$AppDatabase db, $AllocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AllocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tenantId = const Value.absent(),
                Value<int> bedId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rentPaise = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AllocationsCompanion(
                id: id,
                tenantId: tenantId,
                bedId: bedId,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rentPaise: rentPaise,
                endReason: endReason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tenantId,
                required int bedId,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int rentPaise,
                Value<String?> endReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AllocationsCompanion.insert(
                id: id,
                tenantId: tenantId,
                bedId: bedId,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rentPaise: rentPaise,
                endReason: endReason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable<$AllocationsTable, Allocation>(table), $$AllocationsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tenantId = false, bedId = false, rentInvoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (rentInvoicesRefs) db.rentInvoices],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tenantId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tenantId,
                        referencedTable: $$AllocationsTableReferences._tenantIdTable(db),
                        referencedColumn: $$AllocationsTableReferences._tenantIdTable(db).id,
                      ) as T;
                    }
                    if (bedId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bedId,
                        referencedTable: $$AllocationsTableReferences._bedIdTable(db),
                        referencedColumn: $$AllocationsTableReferences._bedIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rentInvoicesRefs)
                    await $_getPrefetchedDataByColumns<Allocation, $AllocationsTable, RentInvoice, $RentInvoicesTable>(
                      currentTable: table,
                      referencedTable: $$AllocationsTableReferences._rentInvoicesRefsTable(db),
                      managerFromTypedResult: (p0) => $$AllocationsTableReferences(db, table, p0).rentInvoicesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'allocation_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllocationsTable,
      Allocation,
      $$AllocationsTableFilterComposer,
      $$AllocationsTableOrderingComposer,
      $$AllocationsTableAnnotationComposer,
      $$AllocationsTableCreateCompanionBuilder,
      $$AllocationsTableUpdateCompanionBuilder,
      (Allocation, $$AllocationsTableReferences),
      Allocation,
      PrefetchHooks Function({bool tenantId, bool bedId, bool rentInvoicesRefs})
    >;
typedef $$RentInvoicesTableCreateCompanionBuilder = RentInvoicesCompanion Function({
  Value<int> id,
  required String invoiceNumber,
  required int tenantId,
  Value<int?> allocationId,
  required int periodYear,
  required int periodMonth,
  required DateTime periodStart,
  required DateTime periodEnd,
  required int rentPaise,
  Value<int> additionalChargesPaise,
  Value<int> discountPaise,
  required int totalPaise,
  Value<int> paidPaise,
  Value<InvoiceStatus> status,
  required DateTime dueDate,
  Value<bool> isProrated,
  Value<String?> notes,
  Value<DateTime?> cancelledAt,
  Value<String?> cancelReason,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$RentInvoicesTableUpdateCompanionBuilder = RentInvoicesCompanion Function({
  Value<int> id,
  Value<String> invoiceNumber,
  Value<int> tenantId,
  Value<int?> allocationId,
  Value<int> periodYear,
  Value<int> periodMonth,
  Value<DateTime> periodStart,
  Value<DateTime> periodEnd,
  Value<int> rentPaise,
  Value<int> additionalChargesPaise,
  Value<int> discountPaise,
  Value<int> totalPaise,
  Value<int> paidPaise,
  Value<InvoiceStatus> status,
  Value<DateTime> dueDate,
  Value<bool> isProrated,
  Value<String?> notes,
  Value<DateTime?> cancelledAt,
  Value<String?> cancelReason,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$RentInvoicesTableReferences extends BaseReferences<_$AppDatabase, $RentInvoicesTable, RentInvoice> {
  $$RentInvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantIdTable(_$AppDatabase db) =>
      db.tenants.createAlias('rent_invoices__tenant_id__tenants__id');

  $$TenantsTableProcessedTableManager get tenantId {
    final $_column = $_itemColumn<int>('tenant_id')!;

    final manager = $$TenantsTableTableManager($_db, $_db.tenants).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AllocationsTable _allocationIdTable(_$AppDatabase db) =>
      db.allocations.createAlias('rent_invoices__allocation_id__allocations__id');

  $$AllocationsTableProcessedTableManager? get allocationId {
    final $_column = $_itemColumn<int>('allocation_id');
    if ($_column == null) return null;
    final manager = $$AllocationsTableTableManager($_db, $_db.allocations).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_allocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PaymentAllocationsTable, List<PaymentAllocation>> _paymentAllocationsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.paymentAllocations,
    aliasName: 'rent_invoices__id__payment_allocations__invoice_id',
  );

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentAllocationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RentInvoicesTableFilterComposer extends Composer<_$AppDatabase, $RentInvoicesTable> {
  $$RentInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber =>
      $composableBuilder(column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodYear =>
      $composableBuilder(column: $table.periodYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodMonth =>
      $composableBuilder(column: $table.periodMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rentPaise =>
      $composableBuilder(column: $table.rentPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get additionalChargesPaise =>
      $composableBuilder(column: $table.additionalChargesPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountPaise =>
      $composableBuilder(column: $table.discountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPaise =>
      $composableBuilder(column: $table.totalPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidPaise =>
      $composableBuilder(column: $table.paidPaise, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<InvoiceStatus, InvoiceStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProrated =>
      $composableBuilder(column: $table.isProrated, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cancelledAt =>
      $composableBuilder(column: $table.cancelledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cancelReason =>
      $composableBuilder(column: $table.cancelReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TenantsTableFilterComposer get tenantId {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AllocationsTableFilterComposer get allocationId {
    final $$AllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.allocationId,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableFilterComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.invoiceId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RentInvoicesTableOrderingComposer extends Composer<_$AppDatabase, $RentInvoicesTable> {
  $$RentInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber =>
      $composableBuilder(column: $table.invoiceNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodYear =>
      $composableBuilder(column: $table.periodYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodMonth =>
      $composableBuilder(column: $table.periodMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rentPaise =>
      $composableBuilder(column: $table.rentPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get additionalChargesPaise =>
      $composableBuilder(column: $table.additionalChargesPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discountPaise =>
      $composableBuilder(column: $table.discountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPaise =>
      $composableBuilder(column: $table.totalPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidPaise =>
      $composableBuilder(column: $table.paidPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProrated =>
      $composableBuilder(column: $table.isProrated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cancelledAt =>
      $composableBuilder(column: $table.cancelledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancelReason =>
      $composableBuilder(column: $table.cancelReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TenantsTableOrderingComposer get tenantId {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AllocationsTableOrderingComposer get allocationId {
    final $$AllocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.allocationId,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableOrderingComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RentInvoicesTableAnnotationComposer extends Composer<_$AppDatabase, $RentInvoicesTable> {
  $$RentInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber =>
      $composableBuilder(column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<int> get periodYear => $composableBuilder(column: $table.periodYear, builder: (column) => column);

  GeneratedColumn<int> get periodMonth => $composableBuilder(column: $table.periodMonth, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd => $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<int> get rentPaise => $composableBuilder(column: $table.rentPaise, builder: (column) => column);

  GeneratedColumn<int> get additionalChargesPaise =>
      $composableBuilder(column: $table.additionalChargesPaise, builder: (column) => column);

  GeneratedColumn<int> get discountPaise =>
      $composableBuilder(column: $table.discountPaise, builder: (column) => column);

  GeneratedColumn<int> get totalPaise => $composableBuilder(column: $table.totalPaise, builder: (column) => column);

  GeneratedColumn<int> get paidPaise => $composableBuilder(column: $table.paidPaise, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InvoiceStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate => $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isProrated => $composableBuilder(column: $table.isProrated, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get cancelledAt =>
      $composableBuilder(column: $table.cancelledAt, builder: (column) => column);

  GeneratedColumn<String> get cancelReason =>
      $composableBuilder(column: $table.cancelReason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantId {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AllocationsTableAnnotationComposer get allocationId {
    final $$AllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.allocationId,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$AllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaymentAllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.invoiceId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentAllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RentInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentInvoicesTable,
          RentInvoice,
          $$RentInvoicesTableFilterComposer,
          $$RentInvoicesTableOrderingComposer,
          $$RentInvoicesTableAnnotationComposer,
          $$RentInvoicesTableCreateCompanionBuilder,
          $$RentInvoicesTableUpdateCompanionBuilder,
          (RentInvoice, $$RentInvoicesTableReferences),
          RentInvoice,
          PrefetchHooks Function({bool tenantId, bool allocationId, bool paymentAllocationsRefs})
        > {
  $$RentInvoicesTableTableManager(_$AppDatabase db, $RentInvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RentInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RentInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RentInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<int> tenantId = const Value.absent(),
                Value<int?> allocationId = const Value.absent(),
                Value<int> periodYear = const Value.absent(),
                Value<int> periodMonth = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> periodEnd = const Value.absent(),
                Value<int> rentPaise = const Value.absent(),
                Value<int> additionalChargesPaise = const Value.absent(),
                Value<int> discountPaise = const Value.absent(),
                Value<int> totalPaise = const Value.absent(),
                Value<int> paidPaise = const Value.absent(),
                Value<InvoiceStatus> status = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<bool> isProrated = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RentInvoicesCompanion(
                id: id,
                invoiceNumber: invoiceNumber,
                tenantId: tenantId,
                allocationId: allocationId,
                periodYear: periodYear,
                periodMonth: periodMonth,
                periodStart: periodStart,
                periodEnd: periodEnd,
                rentPaise: rentPaise,
                additionalChargesPaise: additionalChargesPaise,
                discountPaise: discountPaise,
                totalPaise: totalPaise,
                paidPaise: paidPaise,
                status: status,
                dueDate: dueDate,
                isProrated: isProrated,
                notes: notes,
                cancelledAt: cancelledAt,
                cancelReason: cancelReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String invoiceNumber,
                required int tenantId,
                Value<int?> allocationId = const Value.absent(),
                required int periodYear,
                required int periodMonth,
                required DateTime periodStart,
                required DateTime periodEnd,
                required int rentPaise,
                Value<int> additionalChargesPaise = const Value.absent(),
                Value<int> discountPaise = const Value.absent(),
                required int totalPaise,
                Value<int> paidPaise = const Value.absent(),
                Value<InvoiceStatus> status = const Value.absent(),
                required DateTime dueDate,
                Value<bool> isProrated = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RentInvoicesCompanion.insert(
                id: id,
                invoiceNumber: invoiceNumber,
                tenantId: tenantId,
                allocationId: allocationId,
                periodYear: periodYear,
                periodMonth: periodMonth,
                periodStart: periodStart,
                periodEnd: periodEnd,
                rentPaise: rentPaise,
                additionalChargesPaise: additionalChargesPaise,
                discountPaise: discountPaise,
                totalPaise: totalPaise,
                paidPaise: paidPaise,
                status: status,
                dueDate: dueDate,
                isProrated: isProrated,
                notes: notes,
                cancelledAt: cancelledAt,
                cancelReason: cancelReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable<$RentInvoicesTable, RentInvoice>(table), $$RentInvoicesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tenantId = false, allocationId = false, paymentAllocationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentAllocationsRefs) db.paymentAllocations],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tenantId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tenantId,
                        referencedTable: $$RentInvoicesTableReferences._tenantIdTable(db),
                        referencedColumn: $$RentInvoicesTableReferences._tenantIdTable(db).id,
                      ) as T;
                    }
                    if (allocationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.allocationId,
                        referencedTable: $$RentInvoicesTableReferences._allocationIdTable(db),
                        referencedColumn: $$RentInvoicesTableReferences._allocationIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentAllocationsRefs)
                    await $_getPrefetchedDataByColumns<
                      RentInvoice,
                      $RentInvoicesTable,
                      PaymentAllocation,
                      $PaymentAllocationsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RentInvoicesTableReferences._paymentAllocationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RentInvoicesTableReferences(db, table, p0).paymentAllocationsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'invoice_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RentInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentInvoicesTable,
      RentInvoice,
      $$RentInvoicesTableFilterComposer,
      $$RentInvoicesTableOrderingComposer,
      $$RentInvoicesTableAnnotationComposer,
      $$RentInvoicesTableCreateCompanionBuilder,
      $$RentInvoicesTableUpdateCompanionBuilder,
      (RentInvoice, $$RentInvoicesTableReferences),
      RentInvoice,
      PrefetchHooks Function({bool tenantId, bool allocationId, bool paymentAllocationsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required String transactionId,
  required String receiptNumber,
  required int tenantId,
  required int amountPaise,
  required PaymentMethod method,
  Value<String?> upiReference,
  required DateTime paymentDate,
  required PaymentStatus status,
  Value<PaymentKind> kind,
  Value<int?> reversesPaymentId,
  Value<String?> notes,
  Value<DateTime?> verifiedAt,
  Value<DateTime> createdAt,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<String> transactionId,
  Value<String> receiptNumber,
  Value<int> tenantId,
  Value<int> amountPaise,
  Value<PaymentMethod> method,
  Value<String?> upiReference,
  Value<DateTime> paymentDate,
  Value<PaymentStatus> status,
  Value<PaymentKind> kind,
  Value<int?> reversesPaymentId,
  Value<String?> notes,
  Value<DateTime?> verifiedAt,
  Value<DateTime> createdAt,
});

final class $$PaymentsTableReferences extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantIdTable(_$AppDatabase db) => db.tenants.createAlias('payments__tenant_id__tenants__id');

  $$TenantsTableProcessedTableManager get tenantId {
    final $_column = $_itemColumn<int>('tenant_id')!;

    final manager = $$TenantsTableTableManager($_db, $_db.tenants).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PaymentsTable _reversesPaymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias('payments__reverses_payment_id__payments__id');

  $$PaymentsTableProcessedTableManager? get reversesPaymentId {
    final $_column = $_itemColumn<int>('reverses_payment_id');
    if ($_column == null) return null;
    final manager = $$PaymentsTableTableManager($_db, $_db.payments).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reversesPaymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PaymentAllocationsTable, List<PaymentAllocation>> _paymentAllocationsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.paymentAllocations, aliasName: 'payments__id__payment_allocations__payment_id');

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentAllocationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PaymentsTableFilterComposer extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId =>
      $composableBuilder(column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptNumber =>
      $composableBuilder(column: $table.receiptNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get upiReference =>
      $composableBuilder(column: $table.upiReference, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate =>
      $composableBuilder(column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PaymentKind, PaymentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get verifiedAt =>
      $composableBuilder(column: $table.verifiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TenantsTableFilterComposer get tenantId {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentsTableFilterComposer get reversesPaymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesPaymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.paymentId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId =>
      $composableBuilder(column: $table.transactionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptNumber =>
      $composableBuilder(column: $table.receiptNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiReference =>
      $composableBuilder(column: $table.upiReference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate =>
      $composableBuilder(column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get verifiedAt =>
      $composableBuilder(column: $table.verifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TenantsTableOrderingComposer get tenantId {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentsTableOrderingComposer get reversesPaymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesPaymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId =>
      $composableBuilder(column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<String> get receiptNumber =>
      $composableBuilder(column: $table.receiptNumber, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(column: $table.amountPaise, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get upiReference =>
      $composableBuilder(column: $table.upiReference, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate =>
      $composableBuilder(column: $table.paymentDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt =>
      $composableBuilder(column: $table.verifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantId {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentsTableAnnotationComposer get reversesPaymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesPaymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaymentAllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.paymentId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentAllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool tenantId, bool reversesPaymentId, bool paymentAllocationsRefs})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> receiptNumber = const Value.absent(),
                Value<int> tenantId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<PaymentMethod> method = const Value.absent(),
                Value<String?> upiReference = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<PaymentStatus> status = const Value.absent(),
                Value<PaymentKind> kind = const Value.absent(),
                Value<int?> reversesPaymentId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                transactionId: transactionId,
                receiptNumber: receiptNumber,
                tenantId: tenantId,
                amountPaise: amountPaise,
                method: method,
                upiReference: upiReference,
                paymentDate: paymentDate,
                status: status,
                kind: kind,
                reversesPaymentId: reversesPaymentId,
                notes: notes,
                verifiedAt: verifiedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String transactionId,
                required String receiptNumber,
                required int tenantId,
                required int amountPaise,
                required PaymentMethod method,
                Value<String?> upiReference = const Value.absent(),
                required DateTime paymentDate,
                required PaymentStatus status,
                Value<PaymentKind> kind = const Value.absent(),
                Value<int?> reversesPaymentId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                transactionId: transactionId,
                receiptNumber: receiptNumber,
                tenantId: tenantId,
                amountPaise: amountPaise,
                method: method,
                upiReference: upiReference,
                paymentDate: paymentDate,
                status: status,
                kind: kind,
                reversesPaymentId: reversesPaymentId,
                notes: notes,
                verifiedAt: verifiedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$PaymentsTable, Payment>(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tenantId = false, reversesPaymentId = false, paymentAllocationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentAllocationsRefs) db.paymentAllocations],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tenantId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tenantId,
                        referencedTable: $$PaymentsTableReferences._tenantIdTable(db),
                        referencedColumn: $$PaymentsTableReferences._tenantIdTable(db).id,
                      ) as T;
                    }
                    if (reversesPaymentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.reversesPaymentId,
                        referencedTable: $$PaymentsTableReferences._reversesPaymentIdTable(db),
                        referencedColumn: $$PaymentsTableReferences._reversesPaymentIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentAllocationsRefs)
                    await $_getPrefetchedDataByColumns<
                      Payment,
                      $PaymentsTable,
                      PaymentAllocation,
                      $PaymentAllocationsTable
                    >(
                      currentTable: table,
                      referencedTable: $$PaymentsTableReferences._paymentAllocationsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PaymentsTableReferences(db, table, p0).paymentAllocationsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'payment_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool tenantId, bool reversesPaymentId, bool paymentAllocationsRefs})
    >;
typedef $$PaymentAllocationsTableCreateCompanionBuilder = PaymentAllocationsCompanion Function({
  Value<int> id,
  required int paymentId,
  required int invoiceId,
  required int amountPaise,
  Value<DateTime> createdAt,
});
typedef $$PaymentAllocationsTableUpdateCompanionBuilder = PaymentAllocationsCompanion Function({
  Value<int> id,
  Value<int> paymentId,
  Value<int> invoiceId,
  Value<int> amountPaise,
  Value<DateTime> createdAt,
});

final class $$PaymentAllocationsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentAllocationsTable, PaymentAllocation> {
  $$PaymentAllocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias('payment_allocations__payment_id__payments__id');

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<int>('payment_id')!;

    final manager = $$PaymentsTableTableManager($_db, $_db.payments).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RentInvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.rentInvoices.createAlias('payment_allocations__invoice_id__rent_invoices__id');

  $$RentInvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<int>('invoice_id')!;

    final manager = $$RentInvoicesTableTableManager($_db, $_db.rentInvoices).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentAllocationsTableFilterComposer extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RentInvoicesTableFilterComposer get invoiceId {
    final $$RentInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableOrderingComposer extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RentInvoicesTableOrderingComposer get invoiceId {
    final $$RentInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableAnnotationComposer extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RentInvoicesTableAnnotationComposer get invoiceId {
    final $$RentInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.rentInvoices,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RentInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.rentInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentAllocationsTable,
          PaymentAllocation,
          $$PaymentAllocationsTableFilterComposer,
          $$PaymentAllocationsTableOrderingComposer,
          $$PaymentAllocationsTableAnnotationComposer,
          $$PaymentAllocationsTableCreateCompanionBuilder,
          $$PaymentAllocationsTableUpdateCompanionBuilder,
          (PaymentAllocation, $$PaymentAllocationsTableReferences),
          PaymentAllocation,
          PrefetchHooks Function({bool paymentId, bool invoiceId})
        > {
  $$PaymentAllocationsTableTableManager(_$AppDatabase db, $PaymentAllocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PaymentAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PaymentAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PaymentAllocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> paymentId = const Value.absent(),
                Value<int> invoiceId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentAllocationsCompanion(
                id: id,
                paymentId: paymentId,
                invoiceId: invoiceId,
                amountPaise: amountPaise,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int paymentId,
                required int invoiceId,
                required int amountPaise,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentAllocationsCompanion.insert(
                id: id,
                paymentId: paymentId,
                invoiceId: invoiceId,
                amountPaise: amountPaise,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentAllocationsTable, PaymentAllocation>(table),
                  $$PaymentAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentId = false, invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (paymentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.paymentId,
                        referencedTable: $$PaymentAllocationsTableReferences._paymentIdTable(db),
                        referencedColumn: $$PaymentAllocationsTableReferences._paymentIdTable(db).id,
                      ) as T;
                    }
                    if (invoiceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.invoiceId,
                        referencedTable: $$PaymentAllocationsTableReferences._invoiceIdTable(db),
                        referencedColumn: $$PaymentAllocationsTableReferences._invoiceIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentAllocationsTable,
      PaymentAllocation,
      $$PaymentAllocationsTableFilterComposer,
      $$PaymentAllocationsTableOrderingComposer,
      $$PaymentAllocationsTableAnnotationComposer,
      $$PaymentAllocationsTableCreateCompanionBuilder,
      $$PaymentAllocationsTableUpdateCompanionBuilder,
      (PaymentAllocation, $$PaymentAllocationsTableReferences),
      PaymentAllocation,
      PrefetchHooks Function({bool paymentId, bool invoiceId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required String title,
  required ExpenseCategory category,
  required int amountPaise,
  required DateTime expenseDate,
  required PaymentMethod paymentMethod,
  Value<String?> vendor,
  Value<String?> billPath,
  Value<String?> notes,
  Value<bool> isVoided,
  Value<String?> voidReason,
  Value<DateTime> createdAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<ExpenseCategory> category,
  Value<int> amountPaise,
  Value<DateTime> expenseDate,
  Value<PaymentMethod> paymentMethod,
  Value<String?> vendor,
  Value<String?> billPath,
  Value<String?> notes,
  Value<bool> isVoided,
  Value<String?> voidReason,
  Value<DateTime> createdAt,
});

final class $$ExpensesTableReferences extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComplaintsTable, List<Complaint>> _complaintsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.complaints, aliasName: 'expenses__id__complaints__expense_id');

  $$ComplaintsTableProcessedTableManager get complaintsRefs {
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_complaintsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExpensesTableFilterComposer extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ExpenseCategory, ExpenseCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate =>
      $composableBuilder(column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String> get paymentMethod =>
      $composableBuilder(column: $table.paymentMethod, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get vendor =>
      $composableBuilder(column: $table.vendor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billPath =>
      $composableBuilder(column: $table.billPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voidReason =>
      $composableBuilder(column: $table.voidReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> complaintsRefs(Expression<bool> Function($$ComplaintsTableFilterComposer f) f) {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.expenseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate =>
      $composableBuilder(column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod =>
      $composableBuilder(column: $table.paymentMethod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendor =>
      $composableBuilder(column: $table.vendor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billPath =>
      $composableBuilder(column: $table.billPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voidReason =>
      $composableBuilder(column: $table.voidReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate =>
      $composableBuilder(column: $table.expenseDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get vendor => $composableBuilder(column: $table.vendor, builder: (column) => column);

  GeneratedColumn<String> get billPath => $composableBuilder(column: $table.billPath, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isVoided => $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(column: $table.voidReason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> complaintsRefs<T extends Object>(Expression<T> Function($$ComplaintsTableAnnotationComposer a) f) {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.expenseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool complaintsRefs})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<ExpenseCategory> category = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> expenseDate = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> vendor = const Value.absent(),
                Value<String?> billPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                title: title,
                category: category,
                amountPaise: amountPaise,
                expenseDate: expenseDate,
                paymentMethod: paymentMethod,
                vendor: vendor,
                billPath: billPath,
                notes: notes,
                isVoided: isVoided,
                voidReason: voidReason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required ExpenseCategory category,
                required int amountPaise,
                required DateTime expenseDate,
                required PaymentMethod paymentMethod,
                Value<String?> vendor = const Value.absent(),
                Value<String?> billPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                title: title,
                category: category,
                amountPaise: amountPaise,
                expenseDate: expenseDate,
                paymentMethod: paymentMethod,
                vendor: vendor,
                billPath: billPath,
                notes: notes,
                isVoided: isVoided,
                voidReason: voidReason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$ExpensesTable, Expense>(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({complaintsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (complaintsRefs) db.complaints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (complaintsRefs)
                    await $_getPrefetchedDataByColumns<Expense, $ExpensesTable, Complaint, $ComplaintsTable>(
                      currentTable: table,
                      referencedTable: $$ExpensesTableReferences._complaintsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ExpensesTableReferences(db, table, p0).complaintsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'expense_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool complaintsRefs})
    >;
typedef $$ComplaintsTableCreateCompanionBuilder = ComplaintsCompanion Function({
  Value<int> id,
  Value<int?> tenantId,
  Value<int?> roomId,
  required String category,
  required String description,
  required ComplaintPriority priority,
  Value<ComplaintStatus> status,
  Value<String> imagePaths,
  Value<String?> resolutionNotes,
  Value<int?> expenseId,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> closedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ComplaintsTableUpdateCompanionBuilder = ComplaintsCompanion Function({
  Value<int> id,
  Value<int?> tenantId,
  Value<int?> roomId,
  Value<String> category,
  Value<String> description,
  Value<ComplaintPriority> priority,
  Value<ComplaintStatus> status,
  Value<String> imagePaths,
  Value<String?> resolutionNotes,
  Value<int?> expenseId,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> closedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$ComplaintsTableReferences extends BaseReferences<_$AppDatabase, $ComplaintsTable, Complaint> {
  $$ComplaintsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantIdTable(_$AppDatabase db) => db.tenants.createAlias('complaints__tenant_id__tenants__id');

  $$TenantsTableProcessedTableManager? get tenantId {
    final $_column = $_itemColumn<int>('tenant_id');
    if ($_column == null) return null;
    final manager = $$TenantsTableTableManager($_db, $_db.tenants).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias('complaints__room_id__rooms__id');

  $$RoomsTableProcessedTableManager? get roomId {
    final $_column = $_itemColumn<int>('room_id');
    if ($_column == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias('complaints__expense_id__expenses__id');

  $$ExpensesTableProcessedTableManager? get expenseId {
    final $_column = $_itemColumn<int>('expense_id');
    if ($_column == null) return null;
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ComplaintsTableFilterComposer extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ComplaintPriority, ComplaintPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ComplaintStatus, ComplaintStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get imagePaths =>
      $composableBuilder(column: $table.imagePaths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionNotes =>
      $composableBuilder(column: $table.resolutionNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt =>
      $composableBuilder(column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TenantsTableFilterComposer get tenantId {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintsTableOrderingComposer extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePaths =>
      $composableBuilder(column: $table.imagePaths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionNotes =>
      $composableBuilder(column: $table.resolutionNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt =>
      $composableBuilder(column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TenantsTableOrderingComposer get tenantId {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintsTableAnnotationComposer extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ComplaintPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ComplaintStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get imagePaths => $composableBuilder(column: $table.imagePaths, builder: (column) => column);

  GeneratedColumn<String> get resolutionNotes =>
      $composableBuilder(column: $table.resolutionNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt =>
      $composableBuilder(column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt => $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantId {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComplaintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplaintsTable,
          Complaint,
          $$ComplaintsTableFilterComposer,
          $$ComplaintsTableOrderingComposer,
          $$ComplaintsTableAnnotationComposer,
          $$ComplaintsTableCreateCompanionBuilder,
          $$ComplaintsTableUpdateCompanionBuilder,
          (Complaint, $$ComplaintsTableReferences),
          Complaint,
          PrefetchHooks Function({bool tenantId, bool roomId, bool expenseId})
        > {
  $$ComplaintsTableTableManager(_$AppDatabase db, $ComplaintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ComplaintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ComplaintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ComplaintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tenantId = const Value.absent(),
                Value<int?> roomId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<ComplaintPriority> priority = const Value.absent(),
                Value<ComplaintStatus> status = const Value.absent(),
                Value<String> imagePaths = const Value.absent(),
                Value<String?> resolutionNotes = const Value.absent(),
                Value<int?> expenseId = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ComplaintsCompanion(
                id: id,
                tenantId: tenantId,
                roomId: roomId,
                category: category,
                description: description,
                priority: priority,
                status: status,
                imagePaths: imagePaths,
                resolutionNotes: resolutionNotes,
                expenseId: expenseId,
                resolvedAt: resolvedAt,
                closedAt: closedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tenantId = const Value.absent(),
                Value<int?> roomId = const Value.absent(),
                required String category,
                required String description,
                required ComplaintPriority priority,
                Value<ComplaintStatus> status = const Value.absent(),
                Value<String> imagePaths = const Value.absent(),
                Value<String?> resolutionNotes = const Value.absent(),
                Value<int?> expenseId = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ComplaintsCompanion.insert(
                id: id,
                tenantId: tenantId,
                roomId: roomId,
                category: category,
                description: description,
                priority: priority,
                status: status,
                imagePaths: imagePaths,
                resolutionNotes: resolutionNotes,
                expenseId: expenseId,
                resolvedAt: resolvedAt,
                closedAt: closedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$ComplaintsTable, Complaint>(table), $$ComplaintsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tenantId = false, roomId = false, expenseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tenantId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tenantId,
                        referencedTable: $$ComplaintsTableReferences._tenantIdTable(db),
                        referencedColumn: $$ComplaintsTableReferences._tenantIdTable(db).id,
                      ) as T;
                    }
                    if (roomId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.roomId,
                        referencedTable: $$ComplaintsTableReferences._roomIdTable(db),
                        referencedColumn: $$ComplaintsTableReferences._roomIdTable(db).id,
                      ) as T;
                    }
                    if (expenseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.expenseId,
                        referencedTable: $$ComplaintsTableReferences._expenseIdTable(db),
                        referencedColumn: $$ComplaintsTableReferences._expenseIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComplaintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplaintsTable,
      Complaint,
      $$ComplaintsTableFilterComposer,
      $$ComplaintsTableOrderingComposer,
      $$ComplaintsTableAnnotationComposer,
      $$ComplaintsTableCreateCompanionBuilder,
      $$ComplaintsTableUpdateCompanionBuilder,
      (Complaint, $$ComplaintsTableReferences),
      Complaint,
      PrefetchHooks Function({bool tenantId, bool roomId, bool expenseId})
    >;
typedef $$NoticesTableCreateCompanionBuilder = NoticesCompanion Function({
  Value<int> id,
  required String title,
  required String body,
  required String category,
  required DateTime publishDate,
  Value<DateTime> createdAt,
});
typedef $$NoticesTableUpdateCompanionBuilder = NoticesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> body,
  Value<String> category,
  Value<DateTime> publishDate,
  Value<DateTime> createdAt,
});

class $$NoticesTableFilterComposer extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get publishDate =>
      $composableBuilder(column: $table.publishDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NoticesTableOrderingComposer extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get publishDate =>
      $composableBuilder(column: $table.publishDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NoticesTableAnnotationComposer extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get publishDate =>
      $composableBuilder(column: $table.publishDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NoticesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoticesTable,
          Notice,
          $$NoticesTableFilterComposer,
          $$NoticesTableOrderingComposer,
          $$NoticesTableAnnotationComposer,
          $$NoticesTableCreateCompanionBuilder,
          $$NoticesTableUpdateCompanionBuilder,
          (Notice, BaseReferences<_$AppDatabase, $NoticesTable, Notice>),
          Notice,
          PrefetchHooks Function()
        > {
  $$NoticesTableTableManager(_$AppDatabase db, $NoticesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$NoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$NoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$NoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> publishDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NoticesCompanion(
                id: id,
                title: title,
                body: body,
                category: category,
                publishDate: publishDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String body,
                required String category,
                required DateTime publishDate,
                Value<DateTime> createdAt = const Value.absent(),
              }) => NoticesCompanion.insert(
                id: id,
                title: title,
                body: body,
                category: category,
                publishDate: publishDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoticesTable, Notice>(table),
                  BaseReferences<_$AppDatabase, $NoticesTable, Notice>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoticesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoticesTable,
      Notice,
      $$NoticesTableFilterComposer,
      $$NoticesTableOrderingComposer,
      $$NoticesTableAnnotationComposer,
      $$NoticesTableCreateCompanionBuilder,
      $$NoticesTableUpdateCompanionBuilder,
      (Notice, BaseReferences<_$AppDatabase, $NoticesTable, Notice>),
      Notice,
      PrefetchHooks Function()
    >;
typedef $$MenusTableCreateCompanionBuilder = MenusCompanion Function({
  Value<int> id,
  required DateTime menuDate,
  Value<String> breakfast,
  Value<String> lunch,
  Value<String> dinner,
  Value<DateTime> updatedAt,
});
typedef $$MenusTableUpdateCompanionBuilder = MenusCompanion Function({
  Value<int> id,
  Value<DateTime> menuDate,
  Value<String> breakfast,
  Value<String> lunch,
  Value<String> dinner,
  Value<DateTime> updatedAt,
});

class $$MenusTableFilterComposer extends Composer<_$AppDatabase, $MenusTable> {
  $$MenusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get menuDate =>
      $composableBuilder(column: $table.menuDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breakfast =>
      $composableBuilder(column: $table.breakfast, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lunch =>
      $composableBuilder(column: $table.lunch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dinner =>
      $composableBuilder(column: $table.dinner, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MenusTableOrderingComposer extends Composer<_$AppDatabase, $MenusTable> {
  $$MenusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get menuDate =>
      $composableBuilder(column: $table.menuDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breakfast =>
      $composableBuilder(column: $table.breakfast, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunch =>
      $composableBuilder(column: $table.lunch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dinner =>
      $composableBuilder(column: $table.dinner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MenusTableAnnotationComposer extends Composer<_$AppDatabase, $MenusTable> {
  $$MenusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get menuDate => $composableBuilder(column: $table.menuDate, builder: (column) => column);

  GeneratedColumn<String> get breakfast => $composableBuilder(column: $table.breakfast, builder: (column) => column);

  GeneratedColumn<String> get lunch => $composableBuilder(column: $table.lunch, builder: (column) => column);

  GeneratedColumn<String> get dinner => $composableBuilder(column: $table.dinner, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MenusTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MenusTable,
          Menu,
          $$MenusTableFilterComposer,
          $$MenusTableOrderingComposer,
          $$MenusTableAnnotationComposer,
          $$MenusTableCreateCompanionBuilder,
          $$MenusTableUpdateCompanionBuilder,
          (Menu, BaseReferences<_$AppDatabase, $MenusTable, Menu>),
          Menu,
          PrefetchHooks Function()
        > {
  $$MenusTableTableManager(_$AppDatabase db, $MenusTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MenusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MenusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MenusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> menuDate = const Value.absent(),
                Value<String> breakfast = const Value.absent(),
                Value<String> lunch = const Value.absent(),
                Value<String> dinner = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MenusCompanion(
                id: id,
                menuDate: menuDate,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime menuDate,
                Value<String> breakfast = const Value.absent(),
                Value<String> lunch = const Value.absent(),
                Value<String> dinner = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MenusCompanion.insert(
                id: id,
                menuDate: menuDate,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MenusTable, Menu>(table),
                  BaseReferences<_$AppDatabase, $MenusTable, Menu>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MenusTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MenusTable,
      Menu,
      $$MenusTableFilterComposer,
      $$MenusTableOrderingComposer,
      $$MenusTableAnnotationComposer,
      $$MenusTableCreateCompanionBuilder,
      $$MenusTableUpdateCompanionBuilder,
      (Menu, BaseReferences<_$AppDatabase, $MenusTable, Menu>),
      Menu,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  Value<int> id,
  required String entity,
  Value<int?> entityId,
  required String action,
  Value<String?> details,
  Value<DateTime> createdAt,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<int> id,
  Value<String> entity,
  Value<int?> entityId,
  Value<String> action,
  Value<String?> details,
  Value<DateTime> createdAt,
});

class $$AuditLogsTableFilterComposer extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AuditLogsTableOrderingComposer extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogsTableAnnotationComposer extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity => $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get entityId => $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action => $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get details => $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                entity: entity,
                entityId: entityId,
                action: action,
                details: details,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity,
                Value<int?> entityId = const Value.absent(),
                required String action,
                Value<String?> details = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                entity: entity,
                entityId: entityId,
                action: action,
                details: details,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion Function({
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, updatedAt: updatedAt, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion.insert(key: key, value: value, updatedAt: updatedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PgProfilesTableTableManager get pgProfiles => $$PgProfilesTableTableManager(_db, _db.pgProfiles);
  $$RoomsTableTableManager get rooms => $$RoomsTableTableManager(_db, _db.rooms);
  $$BedsTableTableManager get beds => $$BedsTableTableManager(_db, _db.beds);
  $$TenantsTableTableManager get tenants => $$TenantsTableTableManager(_db, _db.tenants);
  $$AllocationsTableTableManager get allocations => $$AllocationsTableTableManager(_db, _db.allocations);
  $$RentInvoicesTableTableManager get rentInvoices => $$RentInvoicesTableTableManager(_db, _db.rentInvoices);
  $$PaymentsTableTableManager get payments => $$PaymentsTableTableManager(_db, _db.payments);
  $$PaymentAllocationsTableTableManager get paymentAllocations =>
      $$PaymentAllocationsTableTableManager(_db, _db.paymentAllocations);
  $$ExpensesTableTableManager get expenses => $$ExpensesTableTableManager(_db, _db.expenses);
  $$ComplaintsTableTableManager get complaints => $$ComplaintsTableTableManager(_db, _db.complaints);
  $$NoticesTableTableManager get notices => $$NoticesTableTableManager(_db, _db.notices);
  $$MenusTableTableManager get menus => $$MenusTableTableManager(_db, _db.menus);
  $$AuditLogsTableTableManager get auditLogs => $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$AppSettingsTableTableManager get appSettings => $$AppSettingsTableTableManager(_db, _db.appSettings);
}
