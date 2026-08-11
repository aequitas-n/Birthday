// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kin_database.dart';

// ignore_for_file: type=lint
class $PeopleTable extends People with TableInfo<$PeopleTable, PeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthMonthMeta =
      const VerificationMeta('birthMonth');
  @override
  late final GeneratedColumn<int> birthMonth = GeneratedColumn<int>(
      'birth_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _birthDayMeta =
      const VerificationMeta('birthDay');
  @override
  late final GeneratedColumn<int> birthDay = GeneratedColumn<int>(
      'birth_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _birthYearMeta =
      const VerificationMeta('birthYear');
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
      'birth_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _placeLabelMeta =
      const VerificationMeta('placeLabel');
  @override
  late final GeneratedColumn<String> placeLabel = GeneratedColumn<String>(
      'place_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ianaTimezoneMeta =
      const VerificationMeta('ianaTimezone');
  @override
  late final GeneratedColumn<String> ianaTimezone = GeneratedColumn<String>(
      'iana_timezone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortKeyMeta =
      const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
      'sort_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncRevMeta =
      const VerificationMeta('syncRev');
  @override
  late final GeneratedColumn<int> syncRev = GeneratedColumn<int>(
      'sync_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        birthMonth,
        birthDay,
        birthYear,
        placeLabel,
        ianaTimezone,
        sortKey,
        createdAt,
        updatedAt,
        deletedAt,
        syncRev
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(Insertable<PeopleData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('birth_month')) {
      context.handle(
          _birthMonthMeta,
          birthMonth.isAcceptableOrUnknown(
              data['birth_month']!, _birthMonthMeta));
    } else if (isInserting) {
      context.missing(_birthMonthMeta);
    }
    if (data.containsKey('birth_day')) {
      context.handle(_birthDayMeta,
          birthDay.isAcceptableOrUnknown(data['birth_day']!, _birthDayMeta));
    } else if (isInserting) {
      context.missing(_birthDayMeta);
    }
    if (data.containsKey('birth_year')) {
      context.handle(_birthYearMeta,
          birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta));
    }
    if (data.containsKey('place_label')) {
      context.handle(
          _placeLabelMeta,
          placeLabel.isAcceptableOrUnknown(
              data['place_label']!, _placeLabelMeta));
    }
    if (data.containsKey('iana_timezone')) {
      context.handle(
          _ianaTimezoneMeta,
          ianaTimezone.isAcceptableOrUnknown(
              data['iana_timezone']!, _ianaTimezoneMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta,
          sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_rev')) {
      context.handle(_syncRevMeta,
          syncRev.isAcceptableOrUnknown(data['sync_rev']!, _syncRevMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeopleData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      birthMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}birth_month'])!,
      birthDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}birth_day'])!,
      birthYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}birth_year']),
      placeLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_label']),
      ianaTimezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iana_timezone']),
      sortKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      syncRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_rev'])!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PeopleData extends DataClass implements Insertable<PeopleData> {
  final String id;
  final String displayName;
  final int birthMonth;
  final int birthDay;
  final int? birthYear;
  final String? placeLabel;
  final String? ianaTimezone;
  final String sortKey;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int syncRev;
  const PeopleData(
      {required this.id,
      required this.displayName,
      required this.birthMonth,
      required this.birthDay,
      this.birthYear,
      this.placeLabel,
      this.ianaTimezone,
      required this.sortKey,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncRev});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['birth_month'] = Variable<int>(birthMonth);
    map['birth_day'] = Variable<int>(birthDay);
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || placeLabel != null) {
      map['place_label'] = Variable<String>(placeLabel);
    }
    if (!nullToAbsent || ianaTimezone != null) {
      map['iana_timezone'] = Variable<String>(ianaTimezone);
    }
    map['sort_key'] = Variable<String>(sortKey);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_rev'] = Variable<int>(syncRev);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      displayName: Value(displayName),
      birthMonth: Value(birthMonth),
      birthDay: Value(birthDay),
      birthYear: birthYear == null && nullToAbsent
          ? const Value.absent()
          : Value(birthYear),
      placeLabel: placeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(placeLabel),
      ianaTimezone: ianaTimezone == null && nullToAbsent
          ? const Value.absent()
          : Value(ianaTimezone),
      sortKey: Value(sortKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncRev: Value(syncRev),
    );
  }

  factory PeopleData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeopleData(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      birthMonth: serializer.fromJson<int>(json['birthMonth']),
      birthDay: serializer.fromJson<int>(json['birthDay']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      placeLabel: serializer.fromJson<String?>(json['placeLabel']),
      ianaTimezone: serializer.fromJson<String?>(json['ianaTimezone']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncRev: serializer.fromJson<int>(json['syncRev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'birthMonth': serializer.toJson<int>(birthMonth),
      'birthDay': serializer.toJson<int>(birthDay),
      'birthYear': serializer.toJson<int?>(birthYear),
      'placeLabel': serializer.toJson<String?>(placeLabel),
      'ianaTimezone': serializer.toJson<String?>(ianaTimezone),
      'sortKey': serializer.toJson<String>(sortKey),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncRev': serializer.toJson<int>(syncRev),
    };
  }

  PeopleData copyWith(
          {String? id,
          String? displayName,
          int? birthMonth,
          int? birthDay,
          Value<int?> birthYear = const Value.absent(),
          Value<String?> placeLabel = const Value.absent(),
          Value<String?> ianaTimezone = const Value.absent(),
          String? sortKey,
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          int? syncRev}) =>
      PeopleData(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        birthMonth: birthMonth ?? this.birthMonth,
        birthDay: birthDay ?? this.birthDay,
        birthYear: birthYear.present ? birthYear.value : this.birthYear,
        placeLabel: placeLabel.present ? placeLabel.value : this.placeLabel,
        ianaTimezone:
            ianaTimezone.present ? ianaTimezone.value : this.ianaTimezone,
        sortKey: sortKey ?? this.sortKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncRev: syncRev ?? this.syncRev,
      );
  PeopleData copyWithCompanion(PeopleCompanion data) {
    return PeopleData(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      birthMonth:
          data.birthMonth.present ? data.birthMonth.value : this.birthMonth,
      birthDay: data.birthDay.present ? data.birthDay.value : this.birthDay,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      placeLabel:
          data.placeLabel.present ? data.placeLabel.value : this.placeLabel,
      ianaTimezone: data.ianaTimezone.present
          ? data.ianaTimezone.value
          : this.ianaTimezone,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncRev: data.syncRev.present ? data.syncRev.value : this.syncRev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeopleData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthMonth: $birthMonth, ')
          ..write('birthDay: $birthDay, ')
          ..write('birthYear: $birthYear, ')
          ..write('placeLabel: $placeLabel, ')
          ..write('ianaTimezone: $ianaTimezone, ')
          ..write('sortKey: $sortKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      displayName,
      birthMonth,
      birthDay,
      birthYear,
      placeLabel,
      ianaTimezone,
      sortKey,
      createdAt,
      updatedAt,
      deletedAt,
      syncRev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeopleData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.birthMonth == this.birthMonth &&
          other.birthDay == this.birthDay &&
          other.birthYear == this.birthYear &&
          other.placeLabel == this.placeLabel &&
          other.ianaTimezone == this.ianaTimezone &&
          other.sortKey == this.sortKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncRev == this.syncRev);
}

class PeopleCompanion extends UpdateCompanion<PeopleData> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<int> birthMonth;
  final Value<int> birthDay;
  final Value<int?> birthYear;
  final Value<String?> placeLabel;
  final Value<String?> ianaTimezone;
  final Value<String> sortKey;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> syncRev;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthMonth = const Value.absent(),
    this.birthDay = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.placeLabel = const Value.absent(),
    this.ianaTimezone = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String displayName,
    required int birthMonth,
    required int birthDay,
    this.birthYear = const Value.absent(),
    this.placeLabel = const Value.absent(),
    this.ianaTimezone = const Value.absent(),
    required String sortKey,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName),
        birthMonth = Value(birthMonth),
        birthDay = Value(birthDay),
        sortKey = Value(sortKey),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PeopleData> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<int>? birthMonth,
    Expression<int>? birthDay,
    Expression<int>? birthYear,
    Expression<String>? placeLabel,
    Expression<String>? ianaTimezone,
    Expression<String>? sortKey,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (birthMonth != null) 'birth_month': birthMonth,
      if (birthDay != null) 'birth_day': birthDay,
      if (birthYear != null) 'birth_year': birthYear,
      if (placeLabel != null) 'place_label': placeLabel,
      if (ianaTimezone != null) 'iana_timezone': ianaTimezone,
      if (sortKey != null) 'sort_key': sortKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncRev != null) 'sync_rev': syncRev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith(
      {Value<String>? id,
      Value<String>? displayName,
      Value<int>? birthMonth,
      Value<int>? birthDay,
      Value<int?>? birthYear,
      Value<String?>? placeLabel,
      Value<String?>? ianaTimezone,
      Value<String>? sortKey,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? syncRev,
      Value<int>? rowid}) {
    return PeopleCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      birthYear: birthYear ?? this.birthYear,
      placeLabel: placeLabel ?? this.placeLabel,
      ianaTimezone: ianaTimezone ?? this.ianaTimezone,
      sortKey: sortKey ?? this.sortKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncRev: syncRev ?? this.syncRev,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthMonth.present) {
      map['birth_month'] = Variable<int>(birthMonth.value);
    }
    if (birthDay.present) {
      map['birth_day'] = Variable<int>(birthDay.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (placeLabel.present) {
      map['place_label'] = Variable<String>(placeLabel.value);
    }
    if (ianaTimezone.present) {
      map['iana_timezone'] = Variable<String>(ianaTimezone.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncRev.present) {
      map['sync_rev'] = Variable<int>(syncRev.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthMonth: $birthMonth, ')
          ..write('birthDay: $birthDay, ')
          ..write('birthYear: $birthYear, ')
          ..write('placeLabel: $placeLabel, ')
          ..write('ianaTimezone: $ianaTimezone, ')
          ..write('sortKey: $sortKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('UNIQUE REFERENCES people (id)'));
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relationshipMeta =
      const VerificationMeta('relationship');
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
      'relationship', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relationshipLabelMeta =
      const VerificationMeta('relationshipLabel');
  @override
  late final GeneratedColumn<String> relationshipLabel =
      GeneratedColumn<String>('relationship_label', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoIdMeta =
      const VerificationMeta('photoId');
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
      'photo_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncRevMeta =
      const VerificationMeta('syncRev');
  @override
  late final GeneratedColumn<int> syncRev = GeneratedColumn<int>(
      'sync_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        personId,
        nickname,
        relationship,
        relationshipLabel,
        photoId,
        isPinned,
        createdAt,
        updatedAt,
        deletedAt,
        syncRev
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('relationship')) {
      context.handle(
          _relationshipMeta,
          relationship.isAcceptableOrUnknown(
              data['relationship']!, _relationshipMeta));
    }
    if (data.containsKey('relationship_label')) {
      context.handle(
          _relationshipLabelMeta,
          relationshipLabel.isAcceptableOrUnknown(
              data['relationship_label']!, _relationshipLabelMeta));
    }
    if (data.containsKey('photo_id')) {
      context.handle(_photoIdMeta,
          photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_rev')) {
      context.handle(_syncRevMeta,
          syncRev.isAcceptableOrUnknown(data['sync_rev']!, _syncRevMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
      relationship: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relationship']),
      relationshipLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}relationship_label']),
      photoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_id']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      syncRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_rev'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String personId;
  final String? nickname;
  final String? relationship;
  final String? relationshipLabel;
  final String? photoId;
  final bool isPinned;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int syncRev;
  const Profile(
      {required this.id,
      required this.personId,
      this.nickname,
      this.relationship,
      this.relationshipLabel,
      this.photoId,
      required this.isPinned,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncRev});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || relationship != null) {
      map['relationship'] = Variable<String>(relationship);
    }
    if (!nullToAbsent || relationshipLabel != null) {
      map['relationship_label'] = Variable<String>(relationshipLabel);
    }
    if (!nullToAbsent || photoId != null) {
      map['photo_id'] = Variable<String>(photoId);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_rev'] = Variable<int>(syncRev);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      personId: Value(personId),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      relationship: relationship == null && nullToAbsent
          ? const Value.absent()
          : Value(relationship),
      relationshipLabel: relationshipLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(relationshipLabel),
      photoId: photoId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoId),
      isPinned: Value(isPinned),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncRev: Value(syncRev),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      relationship: serializer.fromJson<String?>(json['relationship']),
      relationshipLabel:
          serializer.fromJson<String?>(json['relationshipLabel']),
      photoId: serializer.fromJson<String?>(json['photoId']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncRev: serializer.fromJson<int>(json['syncRev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'nickname': serializer.toJson<String?>(nickname),
      'relationship': serializer.toJson<String?>(relationship),
      'relationshipLabel': serializer.toJson<String?>(relationshipLabel),
      'photoId': serializer.toJson<String?>(photoId),
      'isPinned': serializer.toJson<bool>(isPinned),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncRev': serializer.toJson<int>(syncRev),
    };
  }

  Profile copyWith(
          {String? id,
          String? personId,
          Value<String?> nickname = const Value.absent(),
          Value<String?> relationship = const Value.absent(),
          Value<String?> relationshipLabel = const Value.absent(),
          Value<String?> photoId = const Value.absent(),
          bool? isPinned,
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          int? syncRev}) =>
      Profile(
        id: id ?? this.id,
        personId: personId ?? this.personId,
        nickname: nickname.present ? nickname.value : this.nickname,
        relationship:
            relationship.present ? relationship.value : this.relationship,
        relationshipLabel: relationshipLabel.present
            ? relationshipLabel.value
            : this.relationshipLabel,
        photoId: photoId.present ? photoId.value : this.photoId,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncRev: syncRev ?? this.syncRev,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      relationshipLabel: data.relationshipLabel.present
          ? data.relationshipLabel.value
          : this.relationshipLabel,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncRev: data.syncRev.present ? data.syncRev.value : this.syncRev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('nickname: $nickname, ')
          ..write('relationship: $relationship, ')
          ..write('relationshipLabel: $relationshipLabel, ')
          ..write('photoId: $photoId, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      personId,
      nickname,
      relationship,
      relationshipLabel,
      photoId,
      isPinned,
      createdAt,
      updatedAt,
      deletedAt,
      syncRev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.nickname == this.nickname &&
          other.relationship == this.relationship &&
          other.relationshipLabel == this.relationshipLabel &&
          other.photoId == this.photoId &&
          other.isPinned == this.isPinned &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncRev == this.syncRev);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String?> nickname;
  final Value<String?> relationship;
  final Value<String?> relationshipLabel;
  final Value<String?> photoId;
  final Value<bool> isPinned;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> syncRev;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.relationship = const Value.absent(),
    this.relationshipLabel = const Value.absent(),
    this.photoId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String personId,
    this.nickname = const Value.absent(),
    this.relationship = const Value.absent(),
    this.relationshipLabel = const Value.absent(),
    this.photoId = const Value.absent(),
    this.isPinned = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        personId = Value(personId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? nickname,
    Expression<String>? relationship,
    Expression<String>? relationshipLabel,
    Expression<String>? photoId,
    Expression<bool>? isPinned,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (nickname != null) 'nickname': nickname,
      if (relationship != null) 'relationship': relationship,
      if (relationshipLabel != null) 'relationship_label': relationshipLabel,
      if (photoId != null) 'photo_id': photoId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncRev != null) 'sync_rev': syncRev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? personId,
      Value<String?>? nickname,
      Value<String?>? relationship,
      Value<String?>? relationshipLabel,
      Value<String?>? photoId,
      Value<bool>? isPinned,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? syncRev,
      Value<int>? rowid}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      nickname: nickname ?? this.nickname,
      relationship: relationship ?? this.relationship,
      relationshipLabel: relationshipLabel ?? this.relationshipLabel,
      photoId: photoId ?? this.photoId,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncRev: syncRev ?? this.syncRev,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (relationshipLabel.present) {
      map['relationship_label'] = Variable<String>(relationshipLabel.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncRev.present) {
      map['sync_rev'] = Variable<int>(syncRev.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('nickname: $nickname, ')
          ..write('relationship: $relationship, ')
          ..write('relationshipLabel: $relationshipLabel, ')
          ..write('photoId: $photoId, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindLabelMeta =
      const VerificationMeta('kindLabel');
  @override
  late final GeneratedColumn<String> kindLabel = GeneratedColumn<String>(
      'kind_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 280),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isRetiredMeta =
      const VerificationMeta('isRetired');
  @override
  late final GeneratedColumn<bool> isRetired = GeneratedColumn<bool>(
      'is_retired', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_retired" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncRevMeta =
      const VerificationMeta('syncRev');
  @override
  late final GeneratedColumn<int> syncRev = GeneratedColumn<int>(
      'sync_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        kind,
        kindLabel,
        value,
        isRetired,
        position,
        createdAt,
        updatedAt,
        deletedAt,
        syncRev
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('kind_label')) {
      context.handle(_kindLabelMeta,
          kindLabel.isAcceptableOrUnknown(data['kind_label']!, _kindLabelMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('is_retired')) {
      context.handle(_isRetiredMeta,
          isRetired.isAcceptableOrUnknown(data['is_retired']!, _isRetiredMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_rev')) {
      context.handle(_syncRevMeta,
          syncRev.isAcceptableOrUnknown(data['sync_rev']!, _syncRevMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      kindLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind_label']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      isRetired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_retired'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      syncRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_rev'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String profileId;
  final String kind;
  final String? kindLabel;
  final String value;
  final bool isRetired;
  final int position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int syncRev;
  const Note(
      {required this.id,
      required this.profileId,
      required this.kind,
      this.kindLabel,
      required this.value,
      required this.isRetired,
      required this.position,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncRev});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || kindLabel != null) {
      map['kind_label'] = Variable<String>(kindLabel);
    }
    map['value'] = Variable<String>(value);
    map['is_retired'] = Variable<bool>(isRetired);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_rev'] = Variable<int>(syncRev);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      kind: Value(kind),
      kindLabel: kindLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(kindLabel),
      value: Value(value),
      isRetired: Value(isRetired),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncRev: Value(syncRev),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      kind: serializer.fromJson<String>(json['kind']),
      kindLabel: serializer.fromJson<String?>(json['kindLabel']),
      value: serializer.fromJson<String>(json['value']),
      isRetired: serializer.fromJson<bool>(json['isRetired']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncRev: serializer.fromJson<int>(json['syncRev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'kind': serializer.toJson<String>(kind),
      'kindLabel': serializer.toJson<String?>(kindLabel),
      'value': serializer.toJson<String>(value),
      'isRetired': serializer.toJson<bool>(isRetired),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncRev': serializer.toJson<int>(syncRev),
    };
  }

  Note copyWith(
          {String? id,
          String? profileId,
          String? kind,
          Value<String?> kindLabel = const Value.absent(),
          String? value,
          bool? isRetired,
          int? position,
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          int? syncRev}) =>
      Note(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        kind: kind ?? this.kind,
        kindLabel: kindLabel.present ? kindLabel.value : this.kindLabel,
        value: value ?? this.value,
        isRetired: isRetired ?? this.isRetired,
        position: position ?? this.position,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncRev: syncRev ?? this.syncRev,
      );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      kind: data.kind.present ? data.kind.value : this.kind,
      kindLabel: data.kindLabel.present ? data.kindLabel.value : this.kindLabel,
      value: data.value.present ? data.value.value : this.value,
      isRetired: data.isRetired.present ? data.isRetired.value : this.isRetired,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncRev: data.syncRev.present ? data.syncRev.value : this.syncRev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('kindLabel: $kindLabel, ')
          ..write('value: $value, ')
          ..write('isRetired: $isRetired, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, kind, kindLabel, value,
      isRetired, position, createdAt, updatedAt, deletedAt, syncRev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.kind == this.kind &&
          other.kindLabel == this.kindLabel &&
          other.value == this.value &&
          other.isRetired == this.isRetired &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncRev == this.syncRev);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> kind;
  final Value<String?> kindLabel;
  final Value<String> value;
  final Value<bool> isRetired;
  final Value<int> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> syncRev;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.kind = const Value.absent(),
    this.kindLabel = const Value.absent(),
    this.value = const Value.absent(),
    this.isRetired = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String profileId,
    required String kind,
    this.kindLabel = const Value.absent(),
    required String value,
    this.isRetired = const Value.absent(),
    required int position,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        kind = Value(kind),
        value = Value(value),
        position = Value(position),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? kind,
    Expression<String>? kindLabel,
    Expression<String>? value,
    Expression<bool>? isRetired,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (kind != null) 'kind': kind,
      if (kindLabel != null) 'kind_label': kindLabel,
      if (value != null) 'value': value,
      if (isRetired != null) 'is_retired': isRetired,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncRev != null) 'sync_rev': syncRev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? kind,
      Value<String?>? kindLabel,
      Value<String>? value,
      Value<bool>? isRetired,
      Value<int>? position,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? syncRev,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      kind: kind ?? this.kind,
      kindLabel: kindLabel ?? this.kindLabel,
      value: value ?? this.value,
      isRetired: isRetired ?? this.isRetired,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncRev: syncRev ?? this.syncRev,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (kindLabel.present) {
      map['kind_label'] = Variable<String>(kindLabel.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (isRetired.present) {
      map['is_retired'] = Variable<bool>(isRetired.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncRev.present) {
      map['sync_rev'] = Variable<int>(syncRev.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('kindLabel: $kindLabel, ')
          ..write('value: $value, ')
          ..write('isRetired: $isRetired, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES people (id)'));
  static const VerificationMeta _relPathMeta =
      const VerificationMeta('relPath');
  @override
  late final GeneratedColumn<String> relPath = GeneratedColumn<String>(
      'rel_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
      'bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _remotePathMeta =
      const VerificationMeta('remotePath');
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
      'remote_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        personId,
        relPath,
        width,
        height,
        bytes,
        remotePath,
        createdAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(Insertable<Photo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    }
    if (data.containsKey('rel_path')) {
      context.handle(_relPathMeta,
          relPath.isAcceptableOrUnknown(data['rel_path']!, _relPathMeta));
    } else if (isInserting) {
      context.missing(_relPathMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
          _bytesMeta, bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta));
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('remote_path')) {
      context.handle(
          _remotePathMeta,
          remotePath.isAcceptableOrUnknown(
              data['remote_path']!, _remotePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id']),
      relPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rel_path'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      bytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes'])!,
      remotePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final String? personId;
  final String relPath;
  final int width;
  final int height;
  final int bytes;
  final String? remotePath;
  final int createdAt;
  final int? deletedAt;
  const Photo(
      {required this.id,
      this.personId,
      required this.relPath,
      required this.width,
      required this.height,
      required this.bytes,
      this.remotePath,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['rel_path'] = Variable<String>(relPath);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['bytes'] = Variable<int>(bytes);
    if (!nullToAbsent || remotePath != null) {
      map['remote_path'] = Variable<String>(remotePath);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      relPath: Value(relPath),
      width: Value(width),
      height: Value(height),
      bytes: Value(bytes),
      remotePath: remotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePath),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String?>(json['personId']),
      relPath: serializer.fromJson<String>(json['relPath']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      bytes: serializer.fromJson<int>(json['bytes']),
      remotePath: serializer.fromJson<String?>(json['remotePath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String?>(personId),
      'relPath': serializer.toJson<String>(relPath),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'bytes': serializer.toJson<int>(bytes),
      'remotePath': serializer.toJson<String?>(remotePath),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Photo copyWith(
          {String? id,
          Value<String?> personId = const Value.absent(),
          String? relPath,
          int? width,
          int? height,
          int? bytes,
          Value<String?> remotePath = const Value.absent(),
          int? createdAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      Photo(
        id: id ?? this.id,
        personId: personId.present ? personId.value : this.personId,
        relPath: relPath ?? this.relPath,
        width: width ?? this.width,
        height: height ?? this.height,
        bytes: bytes ?? this.bytes,
        remotePath: remotePath.present ? remotePath.value : this.remotePath,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      relPath: data.relPath.present ? data.relPath.value : this.relPath,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      remotePath:
          data.remotePath.present ? data.remotePath.value : this.remotePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('relPath: $relPath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('bytes: $bytes, ')
          ..write('remotePath: $remotePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personId, relPath, width, height, bytes,
      remotePath, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.relPath == this.relPath &&
          other.width == this.width &&
          other.height == this.height &&
          other.bytes == this.bytes &&
          other.remotePath == this.remotePath &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String?> personId;
  final Value<String> relPath;
  final Value<int> width;
  final Value<int> height;
  final Value<int> bytes;
  final Value<String?> remotePath;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.relPath = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.bytes = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    this.personId = const Value.absent(),
    required String relPath,
    required int width,
    required int height,
    required int bytes,
    this.remotePath = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        relPath = Value(relPath),
        width = Value(width),
        height = Value(height),
        bytes = Value(bytes),
        createdAt = Value(createdAt);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? relPath,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? bytes,
    Expression<String>? remotePath,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (relPath != null) 'rel_path': relPath,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (bytes != null) 'bytes': bytes,
      if (remotePath != null) 'remote_path': remotePath,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? personId,
      Value<String>? relPath,
      Value<int>? width,
      Value<int>? height,
      Value<int>? bytes,
      Value<String?>? remotePath,
      Value<int>? createdAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return PhotosCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      relPath: relPath ?? this.relPath,
      width: width ?? this.width,
      height: height ?? this.height,
      bytes: bytes ?? this.bytes,
      remotePath: remotePath ?? this.remotePath,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (relPath.present) {
      map['rel_path'] = Variable<String>(relPath.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('relPath: $relPath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('bytes: $bytes, ')
          ..write('remotePath: $remotePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTable extends ReminderRules
    with TableInfo<$ReminderRulesTable, ReminderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES people (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _offsetDaysMeta =
      const VerificationMeta('offsetDays');
  @override
  late final GeneratedColumn<int> offsetDays = GeneratedColumn<int>(
      'offset_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _localTimeMeta =
      const VerificationMeta('localTime');
  @override
  late final GeneratedColumn<String> localTime = GeneratedColumn<String>(
      'local_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncRevMeta =
      const VerificationMeta('syncRev');
  @override
  late final GeneratedColumn<int> syncRev = GeneratedColumn<int>(
      'sync_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        personId,
        kind,
        offsetDays,
        localTime,
        enabled,
        updatedAt,
        deletedAt,
        syncRev
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules';
  @override
  VerificationContext validateIntegrity(Insertable<ReminderRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('offset_days')) {
      context.handle(
          _offsetDaysMeta,
          offsetDays.isAcceptableOrUnknown(
              data['offset_days']!, _offsetDaysMeta));
    }
    if (data.containsKey('local_time')) {
      context.handle(_localTimeMeta,
          localTime.isAcceptableOrUnknown(data['local_time']!, _localTimeMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_rev')) {
      context.handle(_syncRevMeta,
          syncRev.isAcceptableOrUnknown(data['sync_rev']!, _syncRevMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      offsetDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}offset_days']),
      localTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_time']),
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      syncRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_rev'])!,
    );
  }

  @override
  $ReminderRulesTable createAlias(String alias) {
    return $ReminderRulesTable(attachedDatabase, alias);
  }
}

class ReminderRule extends DataClass implements Insertable<ReminderRule> {
  final String id;
  final String? personId;
  final String kind;
  final int? offsetDays;
  final String? localTime;
  final bool enabled;
  final int updatedAt;
  final int? deletedAt;
  final int syncRev;
  const ReminderRule(
      {required this.id,
      this.personId,
      required this.kind,
      this.offsetDays,
      this.localTime,
      required this.enabled,
      required this.updatedAt,
      this.deletedAt,
      required this.syncRev});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || offsetDays != null) {
      map['offset_days'] = Variable<int>(offsetDays);
    }
    if (!nullToAbsent || localTime != null) {
      map['local_time'] = Variable<String>(localTime);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_rev'] = Variable<int>(syncRev);
    return map;
  }

  ReminderRulesCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesCompanion(
      id: Value(id),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      kind: Value(kind),
      offsetDays: offsetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(offsetDays),
      localTime: localTime == null && nullToAbsent
          ? const Value.absent()
          : Value(localTime),
      enabled: Value(enabled),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncRev: Value(syncRev),
    );
  }

  factory ReminderRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRule(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String?>(json['personId']),
      kind: serializer.fromJson<String>(json['kind']),
      offsetDays: serializer.fromJson<int?>(json['offsetDays']),
      localTime: serializer.fromJson<String?>(json['localTime']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncRev: serializer.fromJson<int>(json['syncRev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String?>(personId),
      'kind': serializer.toJson<String>(kind),
      'offsetDays': serializer.toJson<int?>(offsetDays),
      'localTime': serializer.toJson<String?>(localTime),
      'enabled': serializer.toJson<bool>(enabled),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncRev': serializer.toJson<int>(syncRev),
    };
  }

  ReminderRule copyWith(
          {String? id,
          Value<String?> personId = const Value.absent(),
          String? kind,
          Value<int?> offsetDays = const Value.absent(),
          Value<String?> localTime = const Value.absent(),
          bool? enabled,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          int? syncRev}) =>
      ReminderRule(
        id: id ?? this.id,
        personId: personId.present ? personId.value : this.personId,
        kind: kind ?? this.kind,
        offsetDays: offsetDays.present ? offsetDays.value : this.offsetDays,
        localTime: localTime.present ? localTime.value : this.localTime,
        enabled: enabled ?? this.enabled,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncRev: syncRev ?? this.syncRev,
      );
  ReminderRule copyWithCompanion(ReminderRulesCompanion data) {
    return ReminderRule(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      kind: data.kind.present ? data.kind.value : this.kind,
      offsetDays:
          data.offsetDays.present ? data.offsetDays.value : this.offsetDays,
      localTime: data.localTime.present ? data.localTime.value : this.localTime,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncRev: data.syncRev.present ? data.syncRev.value : this.syncRev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRule(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('kind: $kind, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('localTime: $localTime, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personId, kind, offsetDays, localTime,
      enabled, updatedAt, deletedAt, syncRev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRule &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.kind == this.kind &&
          other.offsetDays == this.offsetDays &&
          other.localTime == this.localTime &&
          other.enabled == this.enabled &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncRev == this.syncRev);
}

class ReminderRulesCompanion extends UpdateCompanion<ReminderRule> {
  final Value<String> id;
  final Value<String?> personId;
  final Value<String> kind;
  final Value<int?> offsetDays;
  final Value<String?> localTime;
  final Value<bool> enabled;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> syncRev;
  final Value<int> rowid;
  const ReminderRulesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.kind = const Value.absent(),
    this.offsetDays = const Value.absent(),
    this.localTime = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRulesCompanion.insert({
    required String id,
    this.personId = const Value.absent(),
    required String kind,
    this.offsetDays = const Value.absent(),
    this.localTime = const Value.absent(),
    this.enabled = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        updatedAt = Value(updatedAt);
  static Insertable<ReminderRule> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? kind,
    Expression<int>? offsetDays,
    Expression<String>? localTime,
    Expression<bool>? enabled,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (kind != null) 'kind': kind,
      if (offsetDays != null) 'offset_days': offsetDays,
      if (localTime != null) 'local_time': localTime,
      if (enabled != null) 'enabled': enabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncRev != null) 'sync_rev': syncRev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRulesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? personId,
      Value<String>? kind,
      Value<int?>? offsetDays,
      Value<String?>? localTime,
      Value<bool>? enabled,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? syncRev,
      Value<int>? rowid}) {
    return ReminderRulesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      kind: kind ?? this.kind,
      offsetDays: offsetDays ?? this.offsetDays,
      localTime: localTime ?? this.localTime,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncRev: syncRev ?? this.syncRev,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (offsetDays.present) {
      map['offset_days'] = Variable<int>(offsetDays.value);
    }
    if (localTime.present) {
      map['local_time'] = Variable<String>(localTime.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncRev.present) {
      map['sync_rev'] = Variable<int>(syncRev.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('kind: $kind, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('localTime: $localTime, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRev: $syncRev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledNotificationsTable extends ScheduledNotifications
    with TableInfo<$ScheduledNotificationsTable, ScheduledNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _osIdMeta = const VerificationMeta('osId');
  @override
  late final GeneratedColumn<int> osId = GeneratedColumn<int>(
      'os_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES people (id)'));
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
      'rule_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES reminder_rules (id)'));
  static const VerificationMeta _occurrenceYearMeta =
      const VerificationMeta('occurrenceYear');
  @override
  late final GeneratedColumn<int> occurrenceYear = GeneratedColumn<int>(
      'occurrence_year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fireAtUtcMeta =
      const VerificationMeta('fireAtUtc');
  @override
  late final GeneratedColumn<int> fireAtUtc = GeneratedColumn<int>(
      'fire_at_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fireAtDeviceLocalMeta =
      const VerificationMeta('fireAtDeviceLocal');
  @override
  late final GeneratedColumn<int> fireAtDeviceLocal = GeneratedColumn<int>(
      'fire_at_device_local', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviceTzMeta =
      const VerificationMeta('deviceTz');
  @override
  late final GeneratedColumn<String> deviceTz = GeneratedColumn<String>(
      'device_tz', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteIdUsedMeta =
      const VerificationMeta('noteIdUsed');
  @override
  late final GeneratedColumn<String> noteIdUsed = GeneratedColumn<String>(
      'note_id_used', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES notes (id)'));
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _snapshotJsonMeta =
      const VerificationMeta('snapshotJson');
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
      'snapshot_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        osId,
        personId,
        ruleId,
        occurrenceYear,
        fireAtUtc,
        fireAtDeviceLocal,
        deviceTz,
        title,
        body,
        noteIdUsed,
        state,
        snapshotJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_notifications';
  @override
  VerificationContext validateIntegrity(
      Insertable<ScheduledNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('os_id')) {
      context.handle(
          _osIdMeta, osId.isAcceptableOrUnknown(data['os_id']!, _osIdMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta,
          ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('occurrence_year')) {
      context.handle(
          _occurrenceYearMeta,
          occurrenceYear.isAcceptableOrUnknown(
              data['occurrence_year']!, _occurrenceYearMeta));
    } else if (isInserting) {
      context.missing(_occurrenceYearMeta);
    }
    if (data.containsKey('fire_at_utc')) {
      context.handle(
          _fireAtUtcMeta,
          fireAtUtc.isAcceptableOrUnknown(
              data['fire_at_utc']!, _fireAtUtcMeta));
    } else if (isInserting) {
      context.missing(_fireAtUtcMeta);
    }
    if (data.containsKey('fire_at_device_local')) {
      context.handle(
          _fireAtDeviceLocalMeta,
          fireAtDeviceLocal.isAcceptableOrUnknown(
              data['fire_at_device_local']!, _fireAtDeviceLocalMeta));
    } else if (isInserting) {
      context.missing(_fireAtDeviceLocalMeta);
    }
    if (data.containsKey('device_tz')) {
      context.handle(_deviceTzMeta,
          deviceTz.isAcceptableOrUnknown(data['device_tz']!, _deviceTzMeta));
    } else if (isInserting) {
      context.missing(_deviceTzMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('note_id_used')) {
      context.handle(
          _noteIdUsedMeta,
          noteIdUsed.isAcceptableOrUnknown(
              data['note_id_used']!, _noteIdUsedMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
          _snapshotJsonMeta,
          snapshotJson.isAcceptableOrUnknown(
              data['snapshot_json']!, _snapshotJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {osId};
  @override
  ScheduledNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledNotification(
      osId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}os_id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      ruleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_id'])!,
      occurrenceYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}occurrence_year'])!,
      fireAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fire_at_utc'])!,
      fireAtDeviceLocal: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}fire_at_device_local'])!,
      deviceTz: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_tz'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      noteIdUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_id_used']),
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      snapshotJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScheduledNotificationsTable createAlias(String alias) {
    return $ScheduledNotificationsTable(attachedDatabase, alias);
  }
}

class ScheduledNotification extends DataClass
    implements Insertable<ScheduledNotification> {
  final int osId;
  final String personId;
  final String ruleId;
  final int occurrenceYear;
  final int fireAtUtc;
  final int fireAtDeviceLocal;
  final String deviceTz;
  final String title;
  final String body;
  final String? noteIdUsed;
  final String state;
  final String snapshotJson;
  final int createdAt;
  const ScheduledNotification(
      {required this.osId,
      required this.personId,
      required this.ruleId,
      required this.occurrenceYear,
      required this.fireAtUtc,
      required this.fireAtDeviceLocal,
      required this.deviceTz,
      required this.title,
      required this.body,
      this.noteIdUsed,
      required this.state,
      required this.snapshotJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['os_id'] = Variable<int>(osId);
    map['person_id'] = Variable<String>(personId);
    map['rule_id'] = Variable<String>(ruleId);
    map['occurrence_year'] = Variable<int>(occurrenceYear);
    map['fire_at_utc'] = Variable<int>(fireAtUtc);
    map['fire_at_device_local'] = Variable<int>(fireAtDeviceLocal);
    map['device_tz'] = Variable<String>(deviceTz);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || noteIdUsed != null) {
      map['note_id_used'] = Variable<String>(noteIdUsed);
    }
    map['state'] = Variable<String>(state);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ScheduledNotificationsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledNotificationsCompanion(
      osId: Value(osId),
      personId: Value(personId),
      ruleId: Value(ruleId),
      occurrenceYear: Value(occurrenceYear),
      fireAtUtc: Value(fireAtUtc),
      fireAtDeviceLocal: Value(fireAtDeviceLocal),
      deviceTz: Value(deviceTz),
      title: Value(title),
      body: Value(body),
      noteIdUsed: noteIdUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(noteIdUsed),
      state: Value(state),
      snapshotJson: Value(snapshotJson),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduledNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledNotification(
      osId: serializer.fromJson<int>(json['osId']),
      personId: serializer.fromJson<String>(json['personId']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      occurrenceYear: serializer.fromJson<int>(json['occurrenceYear']),
      fireAtUtc: serializer.fromJson<int>(json['fireAtUtc']),
      fireAtDeviceLocal: serializer.fromJson<int>(json['fireAtDeviceLocal']),
      deviceTz: serializer.fromJson<String>(json['deviceTz']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      noteIdUsed: serializer.fromJson<String?>(json['noteIdUsed']),
      state: serializer.fromJson<String>(json['state']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'osId': serializer.toJson<int>(osId),
      'personId': serializer.toJson<String>(personId),
      'ruleId': serializer.toJson<String>(ruleId),
      'occurrenceYear': serializer.toJson<int>(occurrenceYear),
      'fireAtUtc': serializer.toJson<int>(fireAtUtc),
      'fireAtDeviceLocal': serializer.toJson<int>(fireAtDeviceLocal),
      'deviceTz': serializer.toJson<String>(deviceTz),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'noteIdUsed': serializer.toJson<String?>(noteIdUsed),
      'state': serializer.toJson<String>(state),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ScheduledNotification copyWith(
          {int? osId,
          String? personId,
          String? ruleId,
          int? occurrenceYear,
          int? fireAtUtc,
          int? fireAtDeviceLocal,
          String? deviceTz,
          String? title,
          String? body,
          Value<String?> noteIdUsed = const Value.absent(),
          String? state,
          String? snapshotJson,
          int? createdAt}) =>
      ScheduledNotification(
        osId: osId ?? this.osId,
        personId: personId ?? this.personId,
        ruleId: ruleId ?? this.ruleId,
        occurrenceYear: occurrenceYear ?? this.occurrenceYear,
        fireAtUtc: fireAtUtc ?? this.fireAtUtc,
        fireAtDeviceLocal: fireAtDeviceLocal ?? this.fireAtDeviceLocal,
        deviceTz: deviceTz ?? this.deviceTz,
        title: title ?? this.title,
        body: body ?? this.body,
        noteIdUsed: noteIdUsed.present ? noteIdUsed.value : this.noteIdUsed,
        state: state ?? this.state,
        snapshotJson: snapshotJson ?? this.snapshotJson,
        createdAt: createdAt ?? this.createdAt,
      );
  ScheduledNotification copyWithCompanion(
      ScheduledNotificationsCompanion data) {
    return ScheduledNotification(
      osId: data.osId.present ? data.osId.value : this.osId,
      personId: data.personId.present ? data.personId.value : this.personId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      occurrenceYear: data.occurrenceYear.present
          ? data.occurrenceYear.value
          : this.occurrenceYear,
      fireAtUtc: data.fireAtUtc.present ? data.fireAtUtc.value : this.fireAtUtc,
      fireAtDeviceLocal: data.fireAtDeviceLocal.present
          ? data.fireAtDeviceLocal.value
          : this.fireAtDeviceLocal,
      deviceTz: data.deviceTz.present ? data.deviceTz.value : this.deviceTz,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      noteIdUsed:
          data.noteIdUsed.present ? data.noteIdUsed.value : this.noteIdUsed,
      state: data.state.present ? data.state.value : this.state,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotification(')
          ..write('osId: $osId, ')
          ..write('personId: $personId, ')
          ..write('ruleId: $ruleId, ')
          ..write('occurrenceYear: $occurrenceYear, ')
          ..write('fireAtUtc: $fireAtUtc, ')
          ..write('fireAtDeviceLocal: $fireAtDeviceLocal, ')
          ..write('deviceTz: $deviceTz, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('noteIdUsed: $noteIdUsed, ')
          ..write('state: $state, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      osId,
      personId,
      ruleId,
      occurrenceYear,
      fireAtUtc,
      fireAtDeviceLocal,
      deviceTz,
      title,
      body,
      noteIdUsed,
      state,
      snapshotJson,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledNotification &&
          other.osId == this.osId &&
          other.personId == this.personId &&
          other.ruleId == this.ruleId &&
          other.occurrenceYear == this.occurrenceYear &&
          other.fireAtUtc == this.fireAtUtc &&
          other.fireAtDeviceLocal == this.fireAtDeviceLocal &&
          other.deviceTz == this.deviceTz &&
          other.title == this.title &&
          other.body == this.body &&
          other.noteIdUsed == this.noteIdUsed &&
          other.state == this.state &&
          other.snapshotJson == this.snapshotJson &&
          other.createdAt == this.createdAt);
}

class ScheduledNotificationsCompanion
    extends UpdateCompanion<ScheduledNotification> {
  final Value<int> osId;
  final Value<String> personId;
  final Value<String> ruleId;
  final Value<int> occurrenceYear;
  final Value<int> fireAtUtc;
  final Value<int> fireAtDeviceLocal;
  final Value<String> deviceTz;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> noteIdUsed;
  final Value<String> state;
  final Value<String> snapshotJson;
  final Value<int> createdAt;
  const ScheduledNotificationsCompanion({
    this.osId = const Value.absent(),
    this.personId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.occurrenceYear = const Value.absent(),
    this.fireAtUtc = const Value.absent(),
    this.fireAtDeviceLocal = const Value.absent(),
    this.deviceTz = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.noteIdUsed = const Value.absent(),
    this.state = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScheduledNotificationsCompanion.insert({
    this.osId = const Value.absent(),
    required String personId,
    required String ruleId,
    required int occurrenceYear,
    required int fireAtUtc,
    required int fireAtDeviceLocal,
    required String deviceTz,
    required String title,
    required String body,
    this.noteIdUsed = const Value.absent(),
    required String state,
    this.snapshotJson = const Value.absent(),
    required int createdAt,
  })  : personId = Value(personId),
        ruleId = Value(ruleId),
        occurrenceYear = Value(occurrenceYear),
        fireAtUtc = Value(fireAtUtc),
        fireAtDeviceLocal = Value(fireAtDeviceLocal),
        deviceTz = Value(deviceTz),
        title = Value(title),
        body = Value(body),
        state = Value(state),
        createdAt = Value(createdAt);
  static Insertable<ScheduledNotification> custom({
    Expression<int>? osId,
    Expression<String>? personId,
    Expression<String>? ruleId,
    Expression<int>? occurrenceYear,
    Expression<int>? fireAtUtc,
    Expression<int>? fireAtDeviceLocal,
    Expression<String>? deviceTz,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? noteIdUsed,
    Expression<String>? state,
    Expression<String>? snapshotJson,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (osId != null) 'os_id': osId,
      if (personId != null) 'person_id': personId,
      if (ruleId != null) 'rule_id': ruleId,
      if (occurrenceYear != null) 'occurrence_year': occurrenceYear,
      if (fireAtUtc != null) 'fire_at_utc': fireAtUtc,
      if (fireAtDeviceLocal != null) 'fire_at_device_local': fireAtDeviceLocal,
      if (deviceTz != null) 'device_tz': deviceTz,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (noteIdUsed != null) 'note_id_used': noteIdUsed,
      if (state != null) 'state': state,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScheduledNotificationsCompanion copyWith(
      {Value<int>? osId,
      Value<String>? personId,
      Value<String>? ruleId,
      Value<int>? occurrenceYear,
      Value<int>? fireAtUtc,
      Value<int>? fireAtDeviceLocal,
      Value<String>? deviceTz,
      Value<String>? title,
      Value<String>? body,
      Value<String?>? noteIdUsed,
      Value<String>? state,
      Value<String>? snapshotJson,
      Value<int>? createdAt}) {
    return ScheduledNotificationsCompanion(
      osId: osId ?? this.osId,
      personId: personId ?? this.personId,
      ruleId: ruleId ?? this.ruleId,
      occurrenceYear: occurrenceYear ?? this.occurrenceYear,
      fireAtUtc: fireAtUtc ?? this.fireAtUtc,
      fireAtDeviceLocal: fireAtDeviceLocal ?? this.fireAtDeviceLocal,
      deviceTz: deviceTz ?? this.deviceTz,
      title: title ?? this.title,
      body: body ?? this.body,
      noteIdUsed: noteIdUsed ?? this.noteIdUsed,
      state: state ?? this.state,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (osId.present) {
      map['os_id'] = Variable<int>(osId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (occurrenceYear.present) {
      map['occurrence_year'] = Variable<int>(occurrenceYear.value);
    }
    if (fireAtUtc.present) {
      map['fire_at_utc'] = Variable<int>(fireAtUtc.value);
    }
    if (fireAtDeviceLocal.present) {
      map['fire_at_device_local'] = Variable<int>(fireAtDeviceLocal.value);
    }
    if (deviceTz.present) {
      map['device_tz'] = Variable<String>(deviceTz.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (noteIdUsed.present) {
      map['note_id_used'] = Variable<String>(noteIdUsed.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotificationsCompanion(')
          ..write('osId: $osId, ')
          ..write('personId: $personId, ')
          ..write('ruleId: $ruleId, ')
          ..write('occurrenceYear: $occurrenceYear, ')
          ..write('fireAtUtc: $fireAtUtc, ')
          ..write('fireAtDeviceLocal: $fireAtDeviceLocal, ')
          ..write('deviceTz: $deviceTz, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('noteIdUsed: $noteIdUsed, ')
          ..write('state: $state, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _amoledMeta = const VerificationMeta('amoled');
  @override
  late final GeneratedColumn<bool> amoled = GeneratedColumn<bool>(
      'amoled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("amoled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showDetailsOnLockScreenMeta =
      const VerificationMeta('showDetailsOnLockScreen');
  @override
  late final GeneratedColumn<bool> showDetailsOnLockScreen =
      GeneratedColumn<bool>('show_details_on_lock_screen', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("show_details_on_lock_screen" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<int> onboardingCompletedAt = GeneratedColumn<int>(
      'onboarding_completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deviceTimezoneCacheMeta =
      const VerificationMeta('deviceTimezoneCache');
  @override
  late final GeneratedColumn<String> deviceTimezoneCache =
      GeneratedColumn<String>('device_timezone_cache', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastReconciledAtMeta =
      const VerificationMeta('lastReconciledAt');
  @override
  late final GeneratedColumn<int> lastReconciledAt = GeneratedColumn<int>(
      'last_reconciled_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        themeMode,
        amoled,
        showDetailsOnLockScreen,
        notificationsEnabled,
        onboardingCompletedAt,
        deviceTimezoneCache,
        lastReconciledAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('amoled')) {
      context.handle(_amoledMeta,
          amoled.isAcceptableOrUnknown(data['amoled']!, _amoledMeta));
    }
    if (data.containsKey('show_details_on_lock_screen')) {
      context.handle(
          _showDetailsOnLockScreenMeta,
          showDetailsOnLockScreen.isAcceptableOrUnknown(
              data['show_details_on_lock_screen']!,
              _showDetailsOnLockScreenMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
          _onboardingCompletedAtMeta,
          onboardingCompletedAt.isAcceptableOrUnknown(
              data['onboarding_completed_at']!, _onboardingCompletedAtMeta));
    }
    if (data.containsKey('device_timezone_cache')) {
      context.handle(
          _deviceTimezoneCacheMeta,
          deviceTimezoneCache.isAcceptableOrUnknown(
              data['device_timezone_cache']!, _deviceTimezoneCacheMeta));
    }
    if (data.containsKey('last_reconciled_at')) {
      context.handle(
          _lastReconciledAtMeta,
          lastReconciledAt.isAcceptableOrUnknown(
              data['last_reconciled_at']!, _lastReconciledAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      amoled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}amoled'])!,
      showDetailsOnLockScreen: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}show_details_on_lock_screen'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}onboarding_completed_at']),
      deviceTimezoneCache: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_timezone_cache']),
      lastReconciledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_reconciled_at']),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String themeMode;
  final bool amoled;
  final bool showDetailsOnLockScreen;
  final bool notificationsEnabled;
  final int? onboardingCompletedAt;
  final String? deviceTimezoneCache;
  final int? lastReconciledAt;
  const Setting(
      {required this.id,
      required this.themeMode,
      required this.amoled,
      required this.showDetailsOnLockScreen,
      required this.notificationsEnabled,
      this.onboardingCompletedAt,
      this.deviceTimezoneCache,
      this.lastReconciledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['amoled'] = Variable<bool>(amoled);
    map['show_details_on_lock_screen'] =
        Variable<bool>(showDetailsOnLockScreen);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<int>(onboardingCompletedAt);
    }
    if (!nullToAbsent || deviceTimezoneCache != null) {
      map['device_timezone_cache'] = Variable<String>(deviceTimezoneCache);
    }
    if (!nullToAbsent || lastReconciledAt != null) {
      map['last_reconciled_at'] = Variable<int>(lastReconciledAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      amoled: Value(amoled),
      showDetailsOnLockScreen: Value(showDetailsOnLockScreen),
      notificationsEnabled: Value(notificationsEnabled),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      deviceTimezoneCache: deviceTimezoneCache == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceTimezoneCache),
      lastReconciledAt: lastReconciledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReconciledAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      amoled: serializer.fromJson<bool>(json['amoled']),
      showDetailsOnLockScreen:
          serializer.fromJson<bool>(json['showDetailsOnLockScreen']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      onboardingCompletedAt:
          serializer.fromJson<int?>(json['onboardingCompletedAt']),
      deviceTimezoneCache:
          serializer.fromJson<String?>(json['deviceTimezoneCache']),
      lastReconciledAt: serializer.fromJson<int?>(json['lastReconciledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'amoled': serializer.toJson<bool>(amoled),
      'showDetailsOnLockScreen':
          serializer.toJson<bool>(showDetailsOnLockScreen),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'onboardingCompletedAt': serializer.toJson<int?>(onboardingCompletedAt),
      'deviceTimezoneCache': serializer.toJson<String?>(deviceTimezoneCache),
      'lastReconciledAt': serializer.toJson<int?>(lastReconciledAt),
    };
  }

  Setting copyWith(
          {int? id,
          String? themeMode,
          bool? amoled,
          bool? showDetailsOnLockScreen,
          bool? notificationsEnabled,
          Value<int?> onboardingCompletedAt = const Value.absent(),
          Value<String?> deviceTimezoneCache = const Value.absent(),
          Value<int?> lastReconciledAt = const Value.absent()}) =>
      Setting(
        id: id ?? this.id,
        themeMode: themeMode ?? this.themeMode,
        amoled: amoled ?? this.amoled,
        showDetailsOnLockScreen:
            showDetailsOnLockScreen ?? this.showDetailsOnLockScreen,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        onboardingCompletedAt: onboardingCompletedAt.present
            ? onboardingCompletedAt.value
            : this.onboardingCompletedAt,
        deviceTimezoneCache: deviceTimezoneCache.present
            ? deviceTimezoneCache.value
            : this.deviceTimezoneCache,
        lastReconciledAt: lastReconciledAt.present
            ? lastReconciledAt.value
            : this.lastReconciledAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      amoled: data.amoled.present ? data.amoled.value : this.amoled,
      showDetailsOnLockScreen: data.showDetailsOnLockScreen.present
          ? data.showDetailsOnLockScreen.value
          : this.showDetailsOnLockScreen,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      deviceTimezoneCache: data.deviceTimezoneCache.present
          ? data.deviceTimezoneCache.value
          : this.deviceTimezoneCache,
      lastReconciledAt: data.lastReconciledAt.present
          ? data.lastReconciledAt.value
          : this.lastReconciledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('amoled: $amoled, ')
          ..write('showDetailsOnLockScreen: $showDetailsOnLockScreen, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('deviceTimezoneCache: $deviceTimezoneCache, ')
          ..write('lastReconciledAt: $lastReconciledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      themeMode,
      amoled,
      showDetailsOnLockScreen,
      notificationsEnabled,
      onboardingCompletedAt,
      deviceTimezoneCache,
      lastReconciledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.amoled == this.amoled &&
          other.showDetailsOnLockScreen == this.showDetailsOnLockScreen &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.deviceTimezoneCache == this.deviceTimezoneCache &&
          other.lastReconciledAt == this.lastReconciledAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> amoled;
  final Value<bool> showDetailsOnLockScreen;
  final Value<bool> notificationsEnabled;
  final Value<int?> onboardingCompletedAt;
  final Value<String?> deviceTimezoneCache;
  final Value<int?> lastReconciledAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.amoled = const Value.absent(),
    this.showDetailsOnLockScreen = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.deviceTimezoneCache = const Value.absent(),
    this.lastReconciledAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.amoled = const Value.absent(),
    this.showDetailsOnLockScreen = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.deviceTimezoneCache = const Value.absent(),
    this.lastReconciledAt = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? amoled,
    Expression<bool>? showDetailsOnLockScreen,
    Expression<bool>? notificationsEnabled,
    Expression<int>? onboardingCompletedAt,
    Expression<String>? deviceTimezoneCache,
    Expression<int>? lastReconciledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (amoled != null) 'amoled': amoled,
      if (showDetailsOnLockScreen != null)
        'show_details_on_lock_screen': showDetailsOnLockScreen,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (deviceTimezoneCache != null)
        'device_timezone_cache': deviceTimezoneCache,
      if (lastReconciledAt != null) 'last_reconciled_at': lastReconciledAt,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? themeMode,
      Value<bool>? amoled,
      Value<bool>? showDetailsOnLockScreen,
      Value<bool>? notificationsEnabled,
      Value<int?>? onboardingCompletedAt,
      Value<String?>? deviceTimezoneCache,
      Value<int?>? lastReconciledAt}) {
    return SettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      amoled: amoled ?? this.amoled,
      showDetailsOnLockScreen:
          showDetailsOnLockScreen ?? this.showDetailsOnLockScreen,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      deviceTimezoneCache: deviceTimezoneCache ?? this.deviceTimezoneCache,
      lastReconciledAt: lastReconciledAt ?? this.lastReconciledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (amoled.present) {
      map['amoled'] = Variable<bool>(amoled.value);
    }
    if (showDetailsOnLockScreen.present) {
      map['show_details_on_lock_screen'] =
          Variable<bool>(showDetailsOnLockScreen.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] =
          Variable<int>(onboardingCompletedAt.value);
    }
    if (deviceTimezoneCache.present) {
      map['device_timezone_cache'] =
          Variable<String>(deviceTimezoneCache.value);
    }
    if (lastReconciledAt.present) {
      map['last_reconciled_at'] = Variable<int>(lastReconciledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('amoled: $amoled, ')
          ..write('showDetailsOnLockScreen: $showDetailsOnLockScreen, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('deviceTimezoneCache: $deviceTimezoneCache, ')
          ..write('lastReconciledAt: $lastReconciledAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPulledAtMeta =
      const VerificationMeta('lastPulledAt');
  @override
  late final GeneratedColumn<int> lastPulledAt = GeneratedColumn<int>(
      'last_pulled_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPushedAtMeta =
      const VerificationMeta('lastPushedAt');
  @override
  late final GeneratedColumn<int> lastPushedAt = GeneratedColumn<int>(
      'last_pushed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceId, accountId, lastPulledAt, lastPushedAt, lastError];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
          _lastPulledAtMeta,
          lastPulledAt.isAcceptableOrUnknown(
              data['last_pulled_at']!, _lastPulledAtMeta));
    }
    if (data.containsKey('last_pushed_at')) {
      context.handle(
          _lastPushedAtMeta,
          lastPushedAt.isAcceptableOrUnknown(
              data['last_pushed_at']!, _lastPushedAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      lastPulledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_pulled_at']),
      lastPushedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_pushed_at']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int id;
  final String deviceId;
  final String? accountId;
  final int? lastPulledAt;
  final int? lastPushedAt;
  final String? lastError;
  const SyncStateData(
      {required this.id,
      required this.deviceId,
      this.accountId,
      this.lastPulledAt,
      this.lastPushedAt,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt);
    }
    if (!nullToAbsent || lastPushedAt != null) {
      map['last_pushed_at'] = Variable<int>(lastPushedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      lastPushedAt: lastPushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      lastPulledAt: serializer.fromJson<int?>(json['lastPulledAt']),
      lastPushedAt: serializer.fromJson<int?>(json['lastPushedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'accountId': serializer.toJson<String?>(accountId),
      'lastPulledAt': serializer.toJson<int?>(lastPulledAt),
      'lastPushedAt': serializer.toJson<int?>(lastPushedAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncStateData copyWith(
          {int? id,
          String? deviceId,
          Value<String?> accountId = const Value.absent(),
          Value<int?> lastPulledAt = const Value.absent(),
          Value<int?> lastPushedAt = const Value.absent(),
          Value<String?> lastError = const Value.absent()}) =>
      SyncStateData(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        accountId: accountId.present ? accountId.value : this.accountId,
        lastPulledAt:
            lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
        lastPushedAt:
            lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present
          ? data.lastPushedAt.value
          : this.lastPushedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deviceId, accountId, lastPulledAt, lastPushedAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.accountId == this.accountId &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt &&
          other.lastError == this.lastError);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String?> accountId;
  final Value<int?> lastPulledAt;
  final Value<int?> lastPushedAt;
  final Value<String?> lastError;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    this.accountId = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncStateData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? accountId,
    Expression<int>? lastPulledAt,
    Expression<int>? lastPushedAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (accountId != null) 'account_id': accountId,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncStateCompanion copyWith(
      {Value<int>? id,
      Value<String>? deviceId,
      Value<String?>? accountId,
      Value<int?>? lastPulledAt,
      Value<int?>? lastPushedAt,
      Value<String?>? lastError}) {
    return SyncStateCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      accountId: accountId ?? this.accountId,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt.value);
    }
    if (lastPushedAt.present) {
      map['last_pushed_at'] = Variable<int>(lastPushedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$KinDatabase extends GeneratedDatabase {
  _$KinDatabase(QueryExecutor e) : super(e);
  $KinDatabaseManager get managers => $KinDatabaseManager(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $ReminderRulesTable reminderRules = $ReminderRulesTable(this);
  late final $ScheduledNotificationsTable scheduledNotifications =
      $ScheduledNotificationsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        people,
        profiles,
        notes,
        photos,
        reminderRules,
        scheduledNotifications,
        settings,
        syncState
      ];
}

typedef $$PeopleTableCreateCompanionBuilder = PeopleCompanion Function({
  required String id,
  required String displayName,
  required int birthMonth,
  required int birthDay,
  Value<int?> birthYear,
  Value<String?> placeLabel,
  Value<String?> ianaTimezone,
  required String sortKey,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});
typedef $$PeopleTableUpdateCompanionBuilder = PeopleCompanion Function({
  Value<String> id,
  Value<String> displayName,
  Value<int> birthMonth,
  Value<int> birthDay,
  Value<int?> birthYear,
  Value<String?> placeLabel,
  Value<String?> ianaTimezone,
  Value<String> sortKey,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});

final class $$PeopleTableReferences
    extends BaseReferences<_$KinDatabase, $PeopleTable, PeopleData> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfilesTable, List<Profile>> _profilesRefsTable(
          _$KinDatabase db) =>
      MultiTypedResultKey.fromTable(db.profiles,
          aliasName: $_aliasNameGenerator(db.people.id, db.profiles.personId));

  $$ProfilesTableProcessedTableManager get profilesRefs {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.personId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_profilesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhotosTable, List<Photo>> _photosRefsTable(
          _$KinDatabase db) =>
      MultiTypedResultKey.fromTable(db.photos,
          aliasName: $_aliasNameGenerator(db.people.id, db.photos.personId));

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager($_db, $_db.photos)
        .filter((f) => f.personId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
      _reminderRulesRefsTable(_$KinDatabase db) =>
          MultiTypedResultKey.fromTable(db.reminderRules,
              aliasName: $_aliasNameGenerator(
                  db.people.id, db.reminderRules.personId));

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager($_db, $_db.reminderRules)
        .filter((f) => f.personId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScheduledNotificationsTable,
      List<ScheduledNotification>> _scheduledNotificationsRefsTable(
          _$KinDatabase db) =>
      MultiTypedResultKey.fromTable(db.scheduledNotifications,
          aliasName: $_aliasNameGenerator(
              db.people.id, db.scheduledNotifications.personId));

  $$ScheduledNotificationsTableProcessedTableManager
      get scheduledNotificationsRefs {
    final manager = $$ScheduledNotificationsTableTableManager(
            $_db, $_db.scheduledNotifications)
        .filter((f) => f.personId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_scheduledNotificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$KinDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get birthMonth => $composableBuilder(
      column: $table.birthMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get birthDay => $composableBuilder(
      column: $table.birthDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get birthYear => $composableBuilder(
      column: $table.birthYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeLabel => $composableBuilder(
      column: $table.placeLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ianaTimezone => $composableBuilder(
      column: $table.ianaTimezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey => $composableBuilder(
      column: $table.sortKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnFilters(column));

  Expression<bool> profilesRefs(
      Expression<bool> Function($$ProfilesTableFilterComposer f) f) {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> photosRefs(
      Expression<bool> Function($$PhotosTableFilterComposer f) f) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photos,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotosTableFilterComposer(
              $db: $db,
              $table: $db.photos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
      Expression<bool> Function($$ReminderRulesTableFilterComposer f) f) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminderRules,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReminderRulesTableFilterComposer(
              $db: $db,
              $table: $db.reminderRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scheduledNotificationsRefs(
      Expression<bool> Function($$ScheduledNotificationsTableFilterComposer f)
          f) {
    final $$ScheduledNotificationsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledNotifications,
            getReferencedColumn: (t) => t.personId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledNotificationsTableFilterComposer(
                  $db: $db,
                  $table: $db.scheduledNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$KinDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get birthMonth => $composableBuilder(
      column: $table.birthMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get birthDay => $composableBuilder(
      column: $table.birthDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get birthYear => $composableBuilder(
      column: $table.birthYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeLabel => $composableBuilder(
      column: $table.placeLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ianaTimezone => $composableBuilder(
      column: $table.ianaTimezone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey => $composableBuilder(
      column: $table.sortKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnOrderings(column));
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$KinDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<int> get birthMonth => $composableBuilder(
      column: $table.birthMonth, builder: (column) => column);

  GeneratedColumn<int> get birthDay =>
      $composableBuilder(column: $table.birthDay, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<String> get placeLabel => $composableBuilder(
      column: $table.placeLabel, builder: (column) => column);

  GeneratedColumn<String> get ianaTimezone => $composableBuilder(
      column: $table.ianaTimezone, builder: (column) => column);

  GeneratedColumn<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncRev =>
      $composableBuilder(column: $table.syncRev, builder: (column) => column);

  Expression<T> profilesRefs<T extends Object>(
      Expression<T> Function($$ProfilesTableAnnotationComposer a) f) {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
      Expression<T> Function($$PhotosTableAnnotationComposer a) f) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photos,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.photos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
      Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminderRules,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReminderRulesTableAnnotationComposer(
              $db: $db,
              $table: $db.reminderRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scheduledNotificationsRefs<T extends Object>(
      Expression<T> Function($$ScheduledNotificationsTableAnnotationComposer a)
          f) {
    final $$ScheduledNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledNotifications,
            getReferencedColumn: (t) => t.personId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduledNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PeopleTableTableManager extends RootTableManager<
    _$KinDatabase,
    $PeopleTable,
    PeopleData,
    $$PeopleTableFilterComposer,
    $$PeopleTableOrderingComposer,
    $$PeopleTableAnnotationComposer,
    $$PeopleTableCreateCompanionBuilder,
    $$PeopleTableUpdateCompanionBuilder,
    (PeopleData, $$PeopleTableReferences),
    PeopleData,
    PrefetchHooks Function(
        {bool profilesRefs,
        bool photosRefs,
        bool reminderRulesRefs,
        bool scheduledNotificationsRefs})> {
  $$PeopleTableTableManager(_$KinDatabase db, $PeopleTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<int> birthMonth = const Value.absent(),
            Value<int> birthDay = const Value.absent(),
            Value<int?> birthYear = const Value.absent(),
            Value<String?> placeLabel = const Value.absent(),
            Value<String?> ianaTimezone = const Value.absent(),
            Value<String> sortKey = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeopleCompanion(
            id: id,
            displayName: displayName,
            birthMonth: birthMonth,
            birthDay: birthDay,
            birthYear: birthYear,
            placeLabel: placeLabel,
            ianaTimezone: ianaTimezone,
            sortKey: sortKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String displayName,
            required int birthMonth,
            required int birthDay,
            Value<int?> birthYear = const Value.absent(),
            Value<String?> placeLabel = const Value.absent(),
            Value<String?> ianaTimezone = const Value.absent(),
            required String sortKey,
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeopleCompanion.insert(
            id: id,
            displayName: displayName,
            birthMonth: birthMonth,
            birthDay: birthDay,
            birthYear: birthYear,
            placeLabel: placeLabel,
            ianaTimezone: ianaTimezone,
            sortKey: sortKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PeopleTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profilesRefs = false,
              photosRefs = false,
              reminderRulesRefs = false,
              scheduledNotificationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profilesRefs) db.profiles,
                if (photosRefs) db.photos,
                if (reminderRulesRefs) db.reminderRules,
                if (scheduledNotificationsRefs) db.scheduledNotifications
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profilesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$PeopleTableReferences._profilesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PeopleTableReferences(db, table, p0).profilesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.personId == item.id),
                        typedResults: items),
                  if (photosRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$PeopleTableReferences._photosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PeopleTableReferences(db, table, p0).photosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.personId == item.id),
                        typedResults: items),
                  if (reminderRulesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$PeopleTableReferences._reminderRulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PeopleTableReferences(db, table, p0)
                                .reminderRulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.personId == item.id),
                        typedResults: items),
                  if (scheduledNotificationsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$PeopleTableReferences
                            ._scheduledNotificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PeopleTableReferences(db, table, p0)
                                .scheduledNotificationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.personId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PeopleTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $PeopleTable,
    PeopleData,
    $$PeopleTableFilterComposer,
    $$PeopleTableOrderingComposer,
    $$PeopleTableAnnotationComposer,
    $$PeopleTableCreateCompanionBuilder,
    $$PeopleTableUpdateCompanionBuilder,
    (PeopleData, $$PeopleTableReferences),
    PeopleData,
    PrefetchHooks Function(
        {bool profilesRefs,
        bool photosRefs,
        bool reminderRulesRefs,
        bool scheduledNotificationsRefs})>;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String id,
  required String personId,
  Value<String?> nickname,
  Value<String?> relationship,
  Value<String?> relationshipLabel,
  Value<String?> photoId,
  Value<bool> isPinned,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<String> personId,
  Value<String?> nickname,
  Value<String?> relationship,
  Value<String?> relationshipLabel,
  Value<String?> photoId,
  Value<bool> isPinned,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$KinDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$KinDatabase db) => db.people
      .createAlias($_aliasNameGenerator(db.profiles.personId, db.people.id));

  $$PeopleTableProcessedTableManager? get personId {
    if ($_item.personId == null) return null;
    final manager = $$PeopleTableTableManager($_db, $_db.people)
        .filter((f) => f.id($_item.personId!));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
          _$KinDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName: $_aliasNameGenerator(db.profiles.id, db.notes.profileId));

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$KinDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationshipLabel => $composableBuilder(
      column: $table.relationshipLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoId => $composableBuilder(
      column: $table.photoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnFilters(column));

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableFilterComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> notesRefs(
      Expression<bool> Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$KinDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationship => $composableBuilder(
      column: $table.relationship,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationshipLabel => $composableBuilder(
      column: $table.relationshipLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoId => $composableBuilder(
      column: $table.photoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnOrderings(column));

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableOrderingComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$KinDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => column);

  GeneratedColumn<String> get relationshipLabel => $composableBuilder(
      column: $table.relationshipLabel, builder: (column) => column);

  GeneratedColumn<String> get photoId =>
      $composableBuilder(column: $table.photoId, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncRev =>
      $composableBuilder(column: $table.syncRev, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableAnnotationComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> notesRefs<T extends Object>(
      Expression<T> Function($$NotesTableAnnotationComposer a) f) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$KinDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function({bool personId, bool notesRefs})> {
  $$ProfilesTableTableManager(_$KinDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> personId = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<String?> relationship = const Value.absent(),
            Value<String?> relationshipLabel = const Value.absent(),
            Value<String?> photoId = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            personId: personId,
            nickname: nickname,
            relationship: relationship,
            relationshipLabel: relationshipLabel,
            photoId: photoId,
            isPinned: isPinned,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String personId,
            Value<String?> nickname = const Value.absent(),
            Value<String?> relationship = const Value.absent(),
            Value<String?> relationshipLabel = const Value.absent(),
            Value<String?> photoId = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            personId: personId,
            nickname: nickname,
            relationship: relationship,
            relationshipLabel: relationshipLabel,
            photoId: photoId,
            isPinned: isPinned,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({personId = false, notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notesRefs) db.notes],
              addJoins: <
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
                      dynamic>>(state) {
                if (personId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.personId,
                    referencedTable:
                        $$ProfilesTableReferences._personIdTable(db),
                    referencedColumn:
                        $$ProfilesTableReferences._personIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0).notesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function({bool personId, bool notesRefs})>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String profileId,
  required String kind,
  Value<String?> kindLabel,
  required String value,
  Value<bool> isRetired,
  required int position,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> kind,
  Value<String?> kindLabel,
  Value<String> value,
  Value<bool> isRetired,
  Value<int> position,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$KinDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$KinDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.notes.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    if ($_item.profileId == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId!));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ScheduledNotificationsTable,
      List<ScheduledNotification>> _scheduledNotificationsRefsTable(
          _$KinDatabase db) =>
      MultiTypedResultKey.fromTable(db.scheduledNotifications,
          aliasName: $_aliasNameGenerator(
              db.notes.id, db.scheduledNotifications.noteIdUsed));

  $$ScheduledNotificationsTableProcessedTableManager
      get scheduledNotificationsRefs {
    final manager = $$ScheduledNotificationsTableTableManager(
            $_db, $_db.scheduledNotifications)
        .filter((f) => f.noteIdUsed.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_scheduledNotificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$NotesTableFilterComposer extends Composer<_$KinDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kindLabel => $composableBuilder(
      column: $table.kindLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRetired => $composableBuilder(
      column: $table.isRetired, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> scheduledNotificationsRefs(
      Expression<bool> Function($$ScheduledNotificationsTableFilterComposer f)
          f) {
    final $$ScheduledNotificationsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledNotifications,
            getReferencedColumn: (t) => t.noteIdUsed,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledNotificationsTableFilterComposer(
                  $db: $db,
                  $table: $db.scheduledNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$KinDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kindLabel => $composableBuilder(
      column: $table.kindLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRetired => $composableBuilder(
      column: $table.isRetired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$KinDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get kindLabel =>
      $composableBuilder(column: $table.kindLabel, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get isRetired =>
      $composableBuilder(column: $table.isRetired, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncRev =>
      $composableBuilder(column: $table.syncRev, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> scheduledNotificationsRefs<T extends Object>(
      Expression<T> Function($$ScheduledNotificationsTableAnnotationComposer a)
          f) {
    final $$ScheduledNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledNotifications,
            getReferencedColumn: (t) => t.noteIdUsed,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduledNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$NotesTableTableManager extends RootTableManager<
    _$KinDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, $$NotesTableReferences),
    Note,
    PrefetchHooks Function({bool profileId, bool scheduledNotificationsRefs})> {
  $$NotesTableTableManager(_$KinDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String?> kindLabel = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<bool> isRetired = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            profileId: profileId,
            kind: kind,
            kindLabel: kindLabel,
            value: value,
            isRetired: isRetired,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String kind,
            Value<String?> kindLabel = const Value.absent(),
            required String value,
            Value<bool> isRetired = const Value.absent(),
            required int position,
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            profileId: profileId,
            kind: kind,
            kindLabel: kindLabel,
            value: value,
            isRetired: isRetired,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$NotesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profileId = false, scheduledNotificationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (scheduledNotificationsRefs) db.scheduledNotifications
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable: $$NotesTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$NotesTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scheduledNotificationsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$NotesTableReferences
                            ._scheduledNotificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$NotesTableReferences(db, table, p0)
                                .scheduledNotificationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.noteIdUsed == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, $$NotesTableReferences),
    Note,
    PrefetchHooks Function({bool profileId, bool scheduledNotificationsRefs})>;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  Value<String?> personId,
  required String relPath,
  required int width,
  required int height,
  required int bytes,
  Value<String?> remotePath,
  required int createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<String?> personId,
  Value<String> relPath,
  Value<int> width,
  Value<int> height,
  Value<int> bytes,
  Value<String?> remotePath,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$PhotosTableReferences
    extends BaseReferences<_$KinDatabase, $PhotosTable, Photo> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$KinDatabase db) => db.people
      .createAlias($_aliasNameGenerator(db.photos.personId, db.people.id));

  $$PeopleTableProcessedTableManager? get personId {
    if ($_item.personId == null) return null;
    final manager = $$PeopleTableTableManager($_db, $_db.people)
        .filter((f) => f.id($_item.personId!));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$KinDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relPath => $composableBuilder(
      column: $table.relPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remotePath => $composableBuilder(
      column: $table.remotePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableFilterComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$KinDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relPath => $composableBuilder(
      column: $table.relPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remotePath => $composableBuilder(
      column: $table.remotePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableOrderingComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$KinDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relPath =>
      $composableBuilder(column: $table.relPath, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get remotePath => $composableBuilder(
      column: $table.remotePath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableAnnotationComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableTableManager extends RootTableManager<
    _$KinDatabase,
    $PhotosTable,
    Photo,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableAnnotationComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder,
    (Photo, $$PhotosTableReferences),
    Photo,
    PrefetchHooks Function({bool personId})> {
  $$PhotosTableTableManager(_$KinDatabase db, $PhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String> relPath = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<int> bytes = const Value.absent(),
            Value<String?> remotePath = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotosCompanion(
            id: id,
            personId: personId,
            relPath: relPath,
            width: width,
            height: height,
            bytes: bytes,
            remotePath: remotePath,
            createdAt: createdAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> personId = const Value.absent(),
            required String relPath,
            required int width,
            required int height,
            required int bytes,
            Value<String?> remotePath = const Value.absent(),
            required int createdAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotosCompanion.insert(
            id: id,
            personId: personId,
            relPath: relPath,
            width: width,
            height: height,
            bytes: bytes,
            remotePath: remotePath,
            createdAt: createdAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PhotosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (personId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.personId,
                    referencedTable: $$PhotosTableReferences._personIdTable(db),
                    referencedColumn:
                        $$PhotosTableReferences._personIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhotosTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $PhotosTable,
    Photo,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableAnnotationComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder,
    (Photo, $$PhotosTableReferences),
    Photo,
    PrefetchHooks Function({bool personId})>;
typedef $$ReminderRulesTableCreateCompanionBuilder = ReminderRulesCompanion
    Function({
  required String id,
  Value<String?> personId,
  required String kind,
  Value<int?> offsetDays,
  Value<String?> localTime,
  Value<bool> enabled,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});
typedef $$ReminderRulesTableUpdateCompanionBuilder = ReminderRulesCompanion
    Function({
  Value<String> id,
  Value<String?> personId,
  Value<String> kind,
  Value<int?> offsetDays,
  Value<String?> localTime,
  Value<bool> enabled,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> syncRev,
  Value<int> rowid,
});

final class $$ReminderRulesTableReferences
    extends BaseReferences<_$KinDatabase, $ReminderRulesTable, ReminderRule> {
  $$ReminderRulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$KinDatabase db) => db.people.createAlias(
      $_aliasNameGenerator(db.reminderRules.personId, db.people.id));

  $$PeopleTableProcessedTableManager? get personId {
    if ($_item.personId == null) return null;
    final manager = $$PeopleTableTableManager($_db, $_db.people)
        .filter((f) => f.id($_item.personId!));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ScheduledNotificationsTable,
      List<ScheduledNotification>> _scheduledNotificationsRefsTable(
          _$KinDatabase db) =>
      MultiTypedResultKey.fromTable(db.scheduledNotifications,
          aliasName: $_aliasNameGenerator(
              db.reminderRules.id, db.scheduledNotifications.ruleId));

  $$ScheduledNotificationsTableProcessedTableManager
      get scheduledNotificationsRefs {
    final manager = $$ScheduledNotificationsTableTableManager(
            $_db, $_db.scheduledNotifications)
        .filter((f) => f.ruleId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_scheduledNotificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ReminderRulesTableFilterComposer
    extends Composer<_$KinDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get offsetDays => $composableBuilder(
      column: $table.offsetDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localTime => $composableBuilder(
      column: $table.localTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnFilters(column));

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableFilterComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> scheduledNotificationsRefs(
      Expression<bool> Function($$ScheduledNotificationsTableFilterComposer f)
          f) {
    final $$ScheduledNotificationsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledNotifications,
            getReferencedColumn: (t) => t.ruleId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledNotificationsTableFilterComposer(
                  $db: $db,
                  $table: $db.scheduledNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ReminderRulesTableOrderingComposer
    extends Composer<_$KinDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get offsetDays => $composableBuilder(
      column: $table.offsetDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localTime => $composableBuilder(
      column: $table.localTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncRev => $composableBuilder(
      column: $table.syncRev, builder: (column) => ColumnOrderings(column));

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableOrderingComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReminderRulesTableAnnotationComposer
    extends Composer<_$KinDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get offsetDays => $composableBuilder(
      column: $table.offsetDays, builder: (column) => column);

  GeneratedColumn<String> get localTime =>
      $composableBuilder(column: $table.localTime, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncRev =>
      $composableBuilder(column: $table.syncRev, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableAnnotationComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> scheduledNotificationsRefs<T extends Object>(
      Expression<T> Function($$ScheduledNotificationsTableAnnotationComposer a)
          f) {
    final $$ScheduledNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledNotifications,
            getReferencedColumn: (t) => t.ruleId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduledNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ReminderRulesTableTableManager extends RootTableManager<
    _$KinDatabase,
    $ReminderRulesTable,
    ReminderRule,
    $$ReminderRulesTableFilterComposer,
    $$ReminderRulesTableOrderingComposer,
    $$ReminderRulesTableAnnotationComposer,
    $$ReminderRulesTableCreateCompanionBuilder,
    $$ReminderRulesTableUpdateCompanionBuilder,
    (ReminderRule, $$ReminderRulesTableReferences),
    ReminderRule,
    PrefetchHooks Function({bool personId, bool scheduledNotificationsRefs})> {
  $$ReminderRulesTableTableManager(_$KinDatabase db, $ReminderRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int?> offsetDays = const Value.absent(),
            Value<String?> localTime = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReminderRulesCompanion(
            id: id,
            personId: personId,
            kind: kind,
            offsetDays: offsetDays,
            localTime: localTime,
            enabled: enabled,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> personId = const Value.absent(),
            required String kind,
            Value<int?> offsetDays = const Value.absent(),
            Value<String?> localTime = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> syncRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReminderRulesCompanion.insert(
            id: id,
            personId: personId,
            kind: kind,
            offsetDays: offsetDays,
            localTime: localTime,
            enabled: enabled,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncRev: syncRev,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReminderRulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {personId = false, scheduledNotificationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (scheduledNotificationsRefs) db.scheduledNotifications
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (personId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.personId,
                    referencedTable:
                        $$ReminderRulesTableReferences._personIdTable(db),
                    referencedColumn:
                        $$ReminderRulesTableReferences._personIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scheduledNotificationsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ReminderRulesTableReferences
                            ._scheduledNotificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReminderRulesTableReferences(db, table, p0)
                                .scheduledNotificationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ruleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ReminderRulesTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $ReminderRulesTable,
    ReminderRule,
    $$ReminderRulesTableFilterComposer,
    $$ReminderRulesTableOrderingComposer,
    $$ReminderRulesTableAnnotationComposer,
    $$ReminderRulesTableCreateCompanionBuilder,
    $$ReminderRulesTableUpdateCompanionBuilder,
    (ReminderRule, $$ReminderRulesTableReferences),
    ReminderRule,
    PrefetchHooks Function({bool personId, bool scheduledNotificationsRefs})>;
typedef $$ScheduledNotificationsTableCreateCompanionBuilder
    = ScheduledNotificationsCompanion Function({
  Value<int> osId,
  required String personId,
  required String ruleId,
  required int occurrenceYear,
  required int fireAtUtc,
  required int fireAtDeviceLocal,
  required String deviceTz,
  required String title,
  required String body,
  Value<String?> noteIdUsed,
  required String state,
  Value<String> snapshotJson,
  required int createdAt,
});
typedef $$ScheduledNotificationsTableUpdateCompanionBuilder
    = ScheduledNotificationsCompanion Function({
  Value<int> osId,
  Value<String> personId,
  Value<String> ruleId,
  Value<int> occurrenceYear,
  Value<int> fireAtUtc,
  Value<int> fireAtDeviceLocal,
  Value<String> deviceTz,
  Value<String> title,
  Value<String> body,
  Value<String?> noteIdUsed,
  Value<String> state,
  Value<String> snapshotJson,
  Value<int> createdAt,
});

final class $$ScheduledNotificationsTableReferences extends BaseReferences<
    _$KinDatabase, $ScheduledNotificationsTable, ScheduledNotification> {
  $$ScheduledNotificationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$KinDatabase db) => db.people.createAlias(
      $_aliasNameGenerator(db.scheduledNotifications.personId, db.people.id));

  $$PeopleTableProcessedTableManager? get personId {
    if ($_item.personId == null) return null;
    final manager = $$PeopleTableTableManager($_db, $_db.people)
        .filter((f) => f.id($_item.personId!));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ReminderRulesTable _ruleIdTable(_$KinDatabase db) =>
      db.reminderRules.createAlias($_aliasNameGenerator(
          db.scheduledNotifications.ruleId, db.reminderRules.id));

  $$ReminderRulesTableProcessedTableManager? get ruleId {
    if ($_item.ruleId == null) return null;
    final manager = $$ReminderRulesTableTableManager($_db, $_db.reminderRules)
        .filter((f) => f.id($_item.ruleId!));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $NotesTable _noteIdUsedTable(_$KinDatabase db) => db.notes.createAlias(
      $_aliasNameGenerator(db.scheduledNotifications.noteIdUsed, db.notes.id));

  $$NotesTableProcessedTableManager? get noteIdUsed {
    if ($_item.noteIdUsed == null) return null;
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.id($_item.noteIdUsed!));
    final item = $_typedResult.readTableOrNull(_noteIdUsedTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScheduledNotificationsTableFilterComposer
    extends Composer<_$KinDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get osId => $composableBuilder(
      column: $table.osId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occurrenceYear => $composableBuilder(
      column: $table.occurrenceYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fireAtUtc => $composableBuilder(
      column: $table.fireAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fireAtDeviceLocal => $composableBuilder(
      column: $table.fireAtDeviceLocal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceTz => $composableBuilder(
      column: $table.deviceTz, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableFilterComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ReminderRulesTableFilterComposer get ruleId {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ruleId,
        referencedTable: $db.reminderRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReminderRulesTableFilterComposer(
              $db: $db,
              $table: $db.reminderRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$NotesTableFilterComposer get noteIdUsed {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.noteIdUsed,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduledNotificationsTableOrderingComposer
    extends Composer<_$KinDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get osId => $composableBuilder(
      column: $table.osId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occurrenceYear => $composableBuilder(
      column: $table.occurrenceYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fireAtUtc => $composableBuilder(
      column: $table.fireAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fireAtDeviceLocal => $composableBuilder(
      column: $table.fireAtDeviceLocal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceTz => $composableBuilder(
      column: $table.deviceTz, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableOrderingComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ReminderRulesTableOrderingComposer get ruleId {
    final $$ReminderRulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ruleId,
        referencedTable: $db.reminderRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReminderRulesTableOrderingComposer(
              $db: $db,
              $table: $db.reminderRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$NotesTableOrderingComposer get noteIdUsed {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.noteIdUsed,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableOrderingComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduledNotificationsTableAnnotationComposer
    extends Composer<_$KinDatabase, $ScheduledNotificationsTable> {
  $$ScheduledNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get osId =>
      $composableBuilder(column: $table.osId, builder: (column) => column);

  GeneratedColumn<int> get occurrenceYear => $composableBuilder(
      column: $table.occurrenceYear, builder: (column) => column);

  GeneratedColumn<int> get fireAtUtc =>
      $composableBuilder(column: $table.fireAtUtc, builder: (column) => column);

  GeneratedColumn<int> get fireAtDeviceLocal => $composableBuilder(
      column: $table.fireAtDeviceLocal, builder: (column) => column);

  GeneratedColumn<String> get deviceTz =>
      $composableBuilder(column: $table.deviceTz, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableAnnotationComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ReminderRulesTableAnnotationComposer get ruleId {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ruleId,
        referencedTable: $db.reminderRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReminderRulesTableAnnotationComposer(
              $db: $db,
              $table: $db.reminderRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$NotesTableAnnotationComposer get noteIdUsed {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.noteIdUsed,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduledNotificationsTableTableManager extends RootTableManager<
    _$KinDatabase,
    $ScheduledNotificationsTable,
    ScheduledNotification,
    $$ScheduledNotificationsTableFilterComposer,
    $$ScheduledNotificationsTableOrderingComposer,
    $$ScheduledNotificationsTableAnnotationComposer,
    $$ScheduledNotificationsTableCreateCompanionBuilder,
    $$ScheduledNotificationsTableUpdateCompanionBuilder,
    (ScheduledNotification, $$ScheduledNotificationsTableReferences),
    ScheduledNotification,
    PrefetchHooks Function({bool personId, bool ruleId, bool noteIdUsed})> {
  $$ScheduledNotificationsTableTableManager(
      _$KinDatabase db, $ScheduledNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledNotificationsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledNotificationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledNotificationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> osId = const Value.absent(),
            Value<String> personId = const Value.absent(),
            Value<String> ruleId = const Value.absent(),
            Value<int> occurrenceYear = const Value.absent(),
            Value<int> fireAtUtc = const Value.absent(),
            Value<int> fireAtDeviceLocal = const Value.absent(),
            Value<String> deviceTz = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String?> noteIdUsed = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String> snapshotJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ScheduledNotificationsCompanion(
            osId: osId,
            personId: personId,
            ruleId: ruleId,
            occurrenceYear: occurrenceYear,
            fireAtUtc: fireAtUtc,
            fireAtDeviceLocal: fireAtDeviceLocal,
            deviceTz: deviceTz,
            title: title,
            body: body,
            noteIdUsed: noteIdUsed,
            state: state,
            snapshotJson: snapshotJson,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> osId = const Value.absent(),
            required String personId,
            required String ruleId,
            required int occurrenceYear,
            required int fireAtUtc,
            required int fireAtDeviceLocal,
            required String deviceTz,
            required String title,
            required String body,
            Value<String?> noteIdUsed = const Value.absent(),
            required String state,
            Value<String> snapshotJson = const Value.absent(),
            required int createdAt,
          }) =>
              ScheduledNotificationsCompanion.insert(
            osId: osId,
            personId: personId,
            ruleId: ruleId,
            occurrenceYear: occurrenceYear,
            fireAtUtc: fireAtUtc,
            fireAtDeviceLocal: fireAtDeviceLocal,
            deviceTz: deviceTz,
            title: title,
            body: body,
            noteIdUsed: noteIdUsed,
            state: state,
            snapshotJson: snapshotJson,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScheduledNotificationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {personId = false, ruleId = false, noteIdUsed = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (personId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.personId,
                    referencedTable: $$ScheduledNotificationsTableReferences
                        ._personIdTable(db),
                    referencedColumn: $$ScheduledNotificationsTableReferences
                        ._personIdTable(db)
                        .id,
                  ) as T;
                }
                if (ruleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ruleId,
                    referencedTable: $$ScheduledNotificationsTableReferences
                        ._ruleIdTable(db),
                    referencedColumn: $$ScheduledNotificationsTableReferences
                        ._ruleIdTable(db)
                        .id,
                  ) as T;
                }
                if (noteIdUsed) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.noteIdUsed,
                    referencedTable: $$ScheduledNotificationsTableReferences
                        ._noteIdUsedTable(db),
                    referencedColumn: $$ScheduledNotificationsTableReferences
                        ._noteIdUsedTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScheduledNotificationsTableProcessedTableManager
    = ProcessedTableManager<
        _$KinDatabase,
        $ScheduledNotificationsTable,
        ScheduledNotification,
        $$ScheduledNotificationsTableFilterComposer,
        $$ScheduledNotificationsTableOrderingComposer,
        $$ScheduledNotificationsTableAnnotationComposer,
        $$ScheduledNotificationsTableCreateCompanionBuilder,
        $$ScheduledNotificationsTableUpdateCompanionBuilder,
        (ScheduledNotification, $$ScheduledNotificationsTableReferences),
        ScheduledNotification,
        PrefetchHooks Function({bool personId, bool ruleId, bool noteIdUsed})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> themeMode,
  Value<bool> amoled,
  Value<bool> showDetailsOnLockScreen,
  Value<bool> notificationsEnabled,
  Value<int?> onboardingCompletedAt,
  Value<String?> deviceTimezoneCache,
  Value<int?> lastReconciledAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> themeMode,
  Value<bool> amoled,
  Value<bool> showDetailsOnLockScreen,
  Value<bool> notificationsEnabled,
  Value<int?> onboardingCompletedAt,
  Value<String?> deviceTimezoneCache,
  Value<int?> lastReconciledAt,
});

class $$SettingsTableFilterComposer
    extends Composer<_$KinDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get amoled => $composableBuilder(
      column: $table.amoled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showDetailsOnLockScreen => $composableBuilder(
      column: $table.showDetailsOnLockScreen,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceTimezoneCache => $composableBuilder(
      column: $table.deviceTimezoneCache,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastReconciledAt => $composableBuilder(
      column: $table.lastReconciledAt,
      builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$KinDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get amoled => $composableBuilder(
      column: $table.amoled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showDetailsOnLockScreen => $composableBuilder(
      column: $table.showDetailsOnLockScreen,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceTimezoneCache => $composableBuilder(
      column: $table.deviceTimezoneCache,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastReconciledAt => $composableBuilder(
      column: $table.lastReconciledAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$KinDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get amoled =>
      $composableBuilder(column: $table.amoled, builder: (column) => column);

  GeneratedColumn<bool> get showDetailsOnLockScreen => $composableBuilder(
      column: $table.showDetailsOnLockScreen, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<int> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceTimezoneCache => $composableBuilder(
      column: $table.deviceTimezoneCache, builder: (column) => column);

  GeneratedColumn<int> get lastReconciledAt => $composableBuilder(
      column: $table.lastReconciledAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$KinDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$KinDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$KinDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> amoled = const Value.absent(),
            Value<bool> showDetailsOnLockScreen = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<int?> onboardingCompletedAt = const Value.absent(),
            Value<String?> deviceTimezoneCache = const Value.absent(),
            Value<int?> lastReconciledAt = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            themeMode: themeMode,
            amoled: amoled,
            showDetailsOnLockScreen: showDetailsOnLockScreen,
            notificationsEnabled: notificationsEnabled,
            onboardingCompletedAt: onboardingCompletedAt,
            deviceTimezoneCache: deviceTimezoneCache,
            lastReconciledAt: lastReconciledAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> amoled = const Value.absent(),
            Value<bool> showDetailsOnLockScreen = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<int?> onboardingCompletedAt = const Value.absent(),
            Value<String?> deviceTimezoneCache = const Value.absent(),
            Value<int?> lastReconciledAt = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            themeMode: themeMode,
            amoled: amoled,
            showDetailsOnLockScreen: showDetailsOnLockScreen,
            notificationsEnabled: notificationsEnabled,
            onboardingCompletedAt: onboardingCompletedAt,
            deviceTimezoneCache: deviceTimezoneCache,
            lastReconciledAt: lastReconciledAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$KinDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  Value<int> id,
  required String deviceId,
  Value<String?> accountId,
  Value<int?> lastPulledAt,
  Value<int?> lastPushedAt,
  Value<String?> lastError,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<int> id,
  Value<String> deviceId,
  Value<String?> accountId,
  Value<int?> lastPulledAt,
  Value<int?> lastPushedAt,
  Value<String?> lastError,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$KinDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPushedAt => $composableBuilder(
      column: $table.lastPushedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$KinDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPushedAt => $composableBuilder(
      column: $table.lastPushedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$KinDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt, builder: (column) => column);

  GeneratedColumn<int> get lastPushedAt => $composableBuilder(
      column: $table.lastPushedAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$KinDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$KinDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$KinDatabase db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<int?> lastPulledAt = const Value.absent(),
            Value<int?> lastPushedAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncStateCompanion(
            id: id,
            deviceId: deviceId,
            accountId: accountId,
            lastPulledAt: lastPulledAt,
            lastPushedAt: lastPushedAt,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String deviceId,
            Value<String?> accountId = const Value.absent(),
            Value<int?> lastPulledAt = const Value.absent(),
            Value<int?> lastPushedAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            id: id,
            deviceId: deviceId,
            accountId: accountId,
            lastPulledAt: lastPulledAt,
            lastPushedAt: lastPushedAt,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$KinDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$KinDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()>;

class $KinDatabaseManager {
  final _$KinDatabase _db;
  $KinDatabaseManager(this._db);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$ReminderRulesTableTableManager get reminderRules =>
      $$ReminderRulesTableTableManager(_db, _db.reminderRules);
  $$ScheduledNotificationsTableTableManager get scheduledNotifications =>
      $$ScheduledNotificationsTableTableManager(
          _db, _db.scheduledNotifications);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
