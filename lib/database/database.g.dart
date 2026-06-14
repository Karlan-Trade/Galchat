// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, Character> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _systemPromptMeta =
      const VerificationMeta('systemPrompt');
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
      'system_prompt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _greetingMeta =
      const VerificationMeta('greeting');
  @override
  late final GeneratedColumn<String> greeting = GeneratedColumn<String>(
      'greeting', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _worldSettingMeta =
      const VerificationMeta('worldSetting');
  @override
  late final GeneratedColumn<String> worldSetting = GeneratedColumn<String>(
      'world_setting', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _replyStyleMeta =
      const VerificationMeta('replyStyle');
  @override
  late final GeneratedColumn<String> replyStyle = GeneratedColumn<String>(
      'reply_style', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        displayName,
        systemPrompt,
        greeting,
        worldSetting,
        replyStyle,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(Insertable<Character> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
          _systemPromptMeta,
          systemPrompt.isAcceptableOrUnknown(
              data['system_prompt']!, _systemPromptMeta));
    } else if (isInserting) {
      context.missing(_systemPromptMeta);
    }
    if (data.containsKey('greeting')) {
      context.handle(_greetingMeta,
          greeting.isAcceptableOrUnknown(data['greeting']!, _greetingMeta));
    } else if (isInserting) {
      context.missing(_greetingMeta);
    }
    if (data.containsKey('world_setting')) {
      context.handle(
          _worldSettingMeta,
          worldSetting.isAcceptableOrUnknown(
              data['world_setting']!, _worldSettingMeta));
    } else if (isInserting) {
      context.missing(_worldSettingMeta);
    }
    if (data.containsKey('reply_style')) {
      context.handle(
          _replyStyleMeta,
          replyStyle.isAcceptableOrUnknown(
              data['reply_style']!, _replyStyleMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Character map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Character(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      systemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_prompt'])!,
      greeting: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}greeting'])!,
      worldSetting: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}world_setting'])!,
      replyStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_style']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class Character extends DataClass implements Insertable<Character> {
  final int id;
  final String name;
  final String displayName;
  final String systemPrompt;
  final String greeting;
  final String worldSetting;
  final String? replyStyle;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Character(
      {required this.id,
      required this.name,
      required this.displayName,
      required this.systemPrompt,
      required this.greeting,
      required this.worldSetting,
      this.replyStyle,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['system_prompt'] = Variable<String>(systemPrompt);
    map['greeting'] = Variable<String>(greeting);
    map['world_setting'] = Variable<String>(worldSetting);
    if (!nullToAbsent || replyStyle != null) {
      map['reply_style'] = Variable<String>(replyStyle);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      systemPrompt: Value(systemPrompt),
      greeting: Value(greeting),
      worldSetting: Value(worldSetting),
      replyStyle: replyStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(replyStyle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Character.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Character(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      systemPrompt: serializer.fromJson<String>(json['systemPrompt']),
      greeting: serializer.fromJson<String>(json['greeting']),
      worldSetting: serializer.fromJson<String>(json['worldSetting']),
      replyStyle: serializer.fromJson<String?>(json['replyStyle']),
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
      'displayName': serializer.toJson<String>(displayName),
      'systemPrompt': serializer.toJson<String>(systemPrompt),
      'greeting': serializer.toJson<String>(greeting),
      'worldSetting': serializer.toJson<String>(worldSetting),
      'replyStyle': serializer.toJson<String?>(replyStyle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Character copyWith(
          {int? id,
          String? name,
          String? displayName,
          String? systemPrompt,
          String? greeting,
          String? worldSetting,
          Value<String?> replyStyle = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Character(
        id: id ?? this.id,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        greeting: greeting ?? this.greeting,
        worldSetting: worldSetting ?? this.worldSetting,
        replyStyle: replyStyle.present ? replyStyle.value : this.replyStyle,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      greeting: data.greeting.present ? data.greeting.value : this.greeting,
      worldSetting: data.worldSetting.present
          ? data.worldSetting.value
          : this.worldSetting,
      replyStyle:
          data.replyStyle.present ? data.replyStyle.value : this.replyStyle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Character(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('greeting: $greeting, ')
          ..write('worldSetting: $worldSetting, ')
          ..write('replyStyle: $replyStyle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, displayName, systemPrompt, greeting,
      worldSetting, replyStyle, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Character &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.systemPrompt == this.systemPrompt &&
          other.greeting == this.greeting &&
          other.worldSetting == this.worldSetting &&
          other.replyStyle == this.replyStyle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String> systemPrompt;
  final Value<String> greeting;
  final Value<String> worldSetting;
  final Value<String?> replyStyle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.greeting = const Value.absent(),
    this.worldSetting = const Value.absent(),
    this.replyStyle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CharactersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String displayName,
    required String systemPrompt,
    required String greeting,
    required String worldSetting,
    this.replyStyle = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        displayName = Value(displayName),
        systemPrompt = Value(systemPrompt),
        greeting = Value(greeting),
        worldSetting = Value(worldSetting),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Character> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? systemPrompt,
    Expression<String>? greeting,
    Expression<String>? worldSetting,
    Expression<String>? replyStyle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (greeting != null) 'greeting': greeting,
      if (worldSetting != null) 'world_setting': worldSetting,
      if (replyStyle != null) 'reply_style': replyStyle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CharactersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? displayName,
      Value<String>? systemPrompt,
      Value<String>? greeting,
      Value<String>? worldSetting,
      Value<String?>? replyStyle,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      greeting: greeting ?? this.greeting,
      worldSetting: worldSetting ?? this.worldSetting,
      replyStyle: replyStyle ?? this.replyStyle,
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
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (greeting.present) {
      map['greeting'] = Variable<String>(greeting.value);
    }
    if (worldSetting.present) {
      map['world_setting'] = Variable<String>(worldSetting.value);
    }
    if (replyStyle.present) {
      map['reply_style'] = Variable<String>(replyStyle.value);
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
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('greeting: $greeting, ')
          ..write('worldSetting: $worldSetting, ')
          ..write('replyStyle: $replyStyle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
      'character_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, characterId, title, createdAt, updatedAt, archivedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}character_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final int characterId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const Conversation(
      {required this.id,
      required this.characterId,
      required this.title,
      required this.createdAt,
      required this.updatedAt,
      this.archivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Conversation copyWith(
          {int? id,
          int? characterId,
          String? title,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> archivedAt = const Value.absent()}) =>
      Conversation(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, characterId, title, createdAt, updatedAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
  })  : characterId = Value(characterId),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  ConversationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? characterId,
      Value<String>? title,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? archivedAt}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speakerMeta =
      const VerificationMeta('speaker');
  @override
  late final GeneratedColumn<String> speaker = GeneratedColumn<String>(
      'speaker', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawPayloadMeta =
      const VerificationMeta('rawPayload');
  @override
  late final GeneratedColumn<String> rawPayload = GeneratedColumn<String>(
      'raw_payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reasoningContentMeta =
      const VerificationMeta('reasoningContent');
  @override
  late final GeneratedColumn<String> reasoningContent = GeneratedColumn<String>(
      'reasoning_content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        speaker,
        content,
        rawPayload,
        reasoningContent,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('speaker')) {
      context.handle(_speakerMeta,
          speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('raw_payload')) {
      context.handle(
          _rawPayloadMeta,
          rawPayload.isAcceptableOrUnknown(
              data['raw_payload']!, _rawPayloadMeta));
    }
    if (data.containsKey('reasoning_content')) {
      context.handle(
          _reasoningContentMeta,
          reasoningContent.isAcceptableOrUnknown(
              data['reasoning_content']!, _reasoningContentMeta));
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      speaker: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}speaker']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      rawPayload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_payload']),
      reasoningContent: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reasoning_content']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final int conversationId;
  final String role;
  final String? speaker;
  final String content;
  final String? rawPayload;
  final String? reasoningContent;
  final DateTime createdAt;
  const Message(
      {required this.id,
      required this.conversationId,
      required this.role,
      this.speaker,
      required this.content,
      this.rawPayload,
      this.reasoningContent,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || speaker != null) {
      map['speaker'] = Variable<String>(speaker);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || rawPayload != null) {
      map['raw_payload'] = Variable<String>(rawPayload);
    }
    if (!nullToAbsent || reasoningContent != null) {
      map['reasoning_content'] = Variable<String>(reasoningContent);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      speaker: speaker == null && nullToAbsent
          ? const Value.absent()
          : Value(speaker),
      content: Value(content),
      rawPayload: rawPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(rawPayload),
      reasoningContent: reasoningContent == null && nullToAbsent
          ? const Value.absent()
          : Value(reasoningContent),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      speaker: serializer.fromJson<String?>(json['speaker']),
      content: serializer.fromJson<String>(json['content']),
      rawPayload: serializer.fromJson<String?>(json['rawPayload']),
      reasoningContent: serializer.fromJson<String?>(json['reasoningContent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'role': serializer.toJson<String>(role),
      'speaker': serializer.toJson<String?>(speaker),
      'content': serializer.toJson<String>(content),
      'rawPayload': serializer.toJson<String?>(rawPayload),
      'reasoningContent': serializer.toJson<String?>(reasoningContent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith(
          {int? id,
          int? conversationId,
          String? role,
          Value<String?> speaker = const Value.absent(),
          String? content,
          Value<String?> rawPayload = const Value.absent(),
          Value<String?> reasoningContent = const Value.absent(),
          DateTime? createdAt}) =>
      Message(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        speaker: speaker.present ? speaker.value : this.speaker,
        content: content ?? this.content,
        rawPayload: rawPayload.present ? rawPayload.value : this.rawPayload,
        reasoningContent: reasoningContent.present
            ? reasoningContent.value
            : this.reasoningContent,
        createdAt: createdAt ?? this.createdAt,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      content: data.content.present ? data.content.value : this.content,
      rawPayload:
          data.rawPayload.present ? data.rawPayload.value : this.rawPayload,
      reasoningContent: data.reasoningContent.present
          ? data.reasoningContent.value
          : this.reasoningContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('speaker: $speaker, ')
          ..write('content: $content, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('reasoningContent: $reasoningContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, role, speaker, content,
      rawPayload, reasoningContent, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.speaker == this.speaker &&
          other.content == this.content &&
          other.rawPayload == this.rawPayload &&
          other.reasoningContent == this.reasoningContent &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> role;
  final Value<String?> speaker;
  final Value<String> content;
  final Value<String?> rawPayload;
  final Value<String?> reasoningContent;
  final Value<DateTime> createdAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.speaker = const Value.absent(),
    this.content = const Value.absent(),
    this.rawPayload = const Value.absent(),
    this.reasoningContent = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String role,
    this.speaker = const Value.absent(),
    required String content,
    this.rawPayload = const Value.absent(),
    this.reasoningContent = const Value.absent(),
    required DateTime createdAt,
  })  : conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? role,
    Expression<String>? speaker,
    Expression<String>? content,
    Expression<String>? rawPayload,
    Expression<String>? reasoningContent,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (speaker != null) 'speaker': speaker,
      if (content != null) 'content': content,
      if (rawPayload != null) 'raw_payload': rawPayload,
      if (reasoningContent != null) 'reasoning_content': reasoningContent,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<String>? role,
      Value<String?>? speaker,
      Value<String>? content,
      Value<String?>? rawPayload,
      Value<String?>? reasoningContent,
      Value<DateTime>? createdAt}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      speaker: speaker ?? this.speaker,
      content: content ?? this.content,
      rawPayload: rawPayload ?? this.rawPayload,
      reasoningContent: reasoningContent ?? this.reasoningContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(speaker.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rawPayload.present) {
      map['raw_payload'] = Variable<String>(rawPayload.value);
    }
    if (reasoningContent.present) {
      map['reasoning_content'] = Variable<String>(reasoningContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('speaker: $speaker, ')
          ..write('content: $content, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('reasoningContent: $reasoningContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChoicesTable extends Choices with TableInfo<$ChoicesTable, Choice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
      'message_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _choiceKeyMeta =
      const VerificationMeta('choiceKey');
  @override
  late final GeneratedColumn<String> choiceKey = GeneratedColumn<String>(
      'choice_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _choiceTextMeta =
      const VerificationMeta('choiceText');
  @override
  late final GeneratedColumn<String> choiceText = GeneratedColumn<String>(
      'choice_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selectedAtMeta =
      const VerificationMeta('selectedAt');
  @override
  late final GeneratedColumn<DateTime> selectedAt = GeneratedColumn<DateTime>(
      'selected_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, messageId, choiceKey, choiceText, selectedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'choices';
  @override
  VerificationContext validateIntegrity(Insertable<Choice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('choice_key')) {
      context.handle(_choiceKeyMeta,
          choiceKey.isAcceptableOrUnknown(data['choice_key']!, _choiceKeyMeta));
    } else if (isInserting) {
      context.missing(_choiceKeyMeta);
    }
    if (data.containsKey('choice_text')) {
      context.handle(
          _choiceTextMeta,
          choiceText.isAcceptableOrUnknown(
              data['choice_text']!, _choiceTextMeta));
    } else if (isInserting) {
      context.missing(_choiceTextMeta);
    }
    if (data.containsKey('selected_at')) {
      context.handle(
          _selectedAtMeta,
          selectedAt.isAcceptableOrUnknown(
              data['selected_at']!, _selectedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Choice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Choice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_id'])!,
      choiceKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}choice_key'])!,
      choiceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}choice_text'])!,
      selectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}selected_at']),
    );
  }

  @override
  $ChoicesTable createAlias(String alias) {
    return $ChoicesTable(attachedDatabase, alias);
  }
}

class Choice extends DataClass implements Insertable<Choice> {
  final int id;
  final int conversationId;
  final int messageId;
  final String choiceKey;
  final String choiceText;
  final DateTime? selectedAt;
  const Choice(
      {required this.id,
      required this.conversationId,
      required this.messageId,
      required this.choiceKey,
      required this.choiceText,
      this.selectedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['message_id'] = Variable<int>(messageId);
    map['choice_key'] = Variable<String>(choiceKey);
    map['choice_text'] = Variable<String>(choiceText);
    if (!nullToAbsent || selectedAt != null) {
      map['selected_at'] = Variable<DateTime>(selectedAt);
    }
    return map;
  }

  ChoicesCompanion toCompanion(bool nullToAbsent) {
    return ChoicesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      messageId: Value(messageId),
      choiceKey: Value(choiceKey),
      choiceText: Value(choiceText),
      selectedAt: selectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedAt),
    );
  }

  factory Choice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Choice(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      messageId: serializer.fromJson<int>(json['messageId']),
      choiceKey: serializer.fromJson<String>(json['choiceKey']),
      choiceText: serializer.fromJson<String>(json['choiceText']),
      selectedAt: serializer.fromJson<DateTime?>(json['selectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'messageId': serializer.toJson<int>(messageId),
      'choiceKey': serializer.toJson<String>(choiceKey),
      'choiceText': serializer.toJson<String>(choiceText),
      'selectedAt': serializer.toJson<DateTime?>(selectedAt),
    };
  }

  Choice copyWith(
          {int? id,
          int? conversationId,
          int? messageId,
          String? choiceKey,
          String? choiceText,
          Value<DateTime?> selectedAt = const Value.absent()}) =>
      Choice(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        messageId: messageId ?? this.messageId,
        choiceKey: choiceKey ?? this.choiceKey,
        choiceText: choiceText ?? this.choiceText,
        selectedAt: selectedAt.present ? selectedAt.value : this.selectedAt,
      );
  Choice copyWithCompanion(ChoicesCompanion data) {
    return Choice(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      choiceKey: data.choiceKey.present ? data.choiceKey.value : this.choiceKey,
      choiceText:
          data.choiceText.present ? data.choiceText.value : this.choiceText,
      selectedAt:
          data.selectedAt.present ? data.selectedAt.value : this.selectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Choice(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('messageId: $messageId, ')
          ..write('choiceKey: $choiceKey, ')
          ..write('choiceText: $choiceText, ')
          ..write('selectedAt: $selectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, conversationId, messageId, choiceKey, choiceText, selectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Choice &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.messageId == this.messageId &&
          other.choiceKey == this.choiceKey &&
          other.choiceText == this.choiceText &&
          other.selectedAt == this.selectedAt);
}

class ChoicesCompanion extends UpdateCompanion<Choice> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<int> messageId;
  final Value<String> choiceKey;
  final Value<String> choiceText;
  final Value<DateTime?> selectedAt;
  const ChoicesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.choiceKey = const Value.absent(),
    this.choiceText = const Value.absent(),
    this.selectedAt = const Value.absent(),
  });
  ChoicesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required int messageId,
    required String choiceKey,
    required String choiceText,
    this.selectedAt = const Value.absent(),
  })  : conversationId = Value(conversationId),
        messageId = Value(messageId),
        choiceKey = Value(choiceKey),
        choiceText = Value(choiceText);
  static Insertable<Choice> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<int>? messageId,
    Expression<String>? choiceKey,
    Expression<String>? choiceText,
    Expression<DateTime>? selectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (messageId != null) 'message_id': messageId,
      if (choiceKey != null) 'choice_key': choiceKey,
      if (choiceText != null) 'choice_text': choiceText,
      if (selectedAt != null) 'selected_at': selectedAt,
    });
  }

  ChoicesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<int>? messageId,
      Value<String>? choiceKey,
      Value<String>? choiceText,
      Value<DateTime?>? selectedAt}) {
    return ChoicesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      choiceKey: choiceKey ?? this.choiceKey,
      choiceText: choiceText ?? this.choiceText,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (choiceKey.present) {
      map['choice_key'] = Variable<String>(choiceKey.value);
    }
    if (choiceText.present) {
      map['choice_text'] = Variable<String>(choiceText.value);
    }
    if (selectedAt.present) {
      map['selected_at'] = Variable<DateTime>(selectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoicesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('messageId: $messageId, ')
          ..write('choiceKey: $choiceKey, ')
          ..write('choiceText: $choiceText, ')
          ..write('selectedAt: $selectedAt')
          ..write(')'))
        .toString();
  }
}

class $GameStatesTable extends GameStates
    with TableInfo<$GameStatesTable, GameState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _affectionMeta =
      const VerificationMeta('affection');
  @override
  late final GeneratedColumn<int> affection = GeneratedColumn<int>(
      'affection', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('平静'));
  static const VerificationMeta _sceneMeta = const VerificationMeta('scene');
  @override
  late final GeneratedColumn<String> scene = GeneratedColumn<String>(
      'scene', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('教室'));
  static const VerificationMeta _timeSlotMeta =
      const VerificationMeta('timeSlot');
  @override
  late final GeneratedColumn<String> timeSlot = GeneratedColumn<String>(
      'time_slot', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('放学后'));
  static const VerificationMeta _flagsJsonMeta =
      const VerificationMeta('flagsJson');
  @override
  late final GeneratedColumn<String> flagsJson = GeneratedColumn<String>(
      'flags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        affection,
        mood,
        scene,
        timeSlot,
        flagsJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_states';
  @override
  VerificationContext validateIntegrity(Insertable<GameState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('affection')) {
      context.handle(_affectionMeta,
          affection.isAcceptableOrUnknown(data['affection']!, _affectionMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('scene')) {
      context.handle(
          _sceneMeta, scene.isAcceptableOrUnknown(data['scene']!, _sceneMeta));
    }
    if (data.containsKey('time_slot')) {
      context.handle(_timeSlotMeta,
          timeSlot.isAcceptableOrUnknown(data['time_slot']!, _timeSlotMeta));
    }
    if (data.containsKey('flags_json')) {
      context.handle(_flagsJsonMeta,
          flagsJson.isAcceptableOrUnknown(data['flags_json']!, _flagsJsonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameState(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      affection: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}affection'])!,
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood'])!,
      scene: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene'])!,
      timeSlot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_slot'])!,
      flagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flags_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GameStatesTable createAlias(String alias) {
    return $GameStatesTable(attachedDatabase, alias);
  }
}

class GameState extends DataClass implements Insertable<GameState> {
  final int id;
  final int conversationId;
  final int affection;
  final String mood;
  final String scene;
  final String timeSlot;
  final String flagsJson;
  final DateTime updatedAt;
  const GameState(
      {required this.id,
      required this.conversationId,
      required this.affection,
      required this.mood,
      required this.scene,
      required this.timeSlot,
      required this.flagsJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['affection'] = Variable<int>(affection);
    map['mood'] = Variable<String>(mood);
    map['scene'] = Variable<String>(scene);
    map['time_slot'] = Variable<String>(timeSlot);
    map['flags_json'] = Variable<String>(flagsJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GameStatesCompanion toCompanion(bool nullToAbsent) {
    return GameStatesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      affection: Value(affection),
      mood: Value(mood),
      scene: Value(scene),
      timeSlot: Value(timeSlot),
      flagsJson: Value(flagsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameState(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      affection: serializer.fromJson<int>(json['affection']),
      mood: serializer.fromJson<String>(json['mood']),
      scene: serializer.fromJson<String>(json['scene']),
      timeSlot: serializer.fromJson<String>(json['timeSlot']),
      flagsJson: serializer.fromJson<String>(json['flagsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'affection': serializer.toJson<int>(affection),
      'mood': serializer.toJson<String>(mood),
      'scene': serializer.toJson<String>(scene),
      'timeSlot': serializer.toJson<String>(timeSlot),
      'flagsJson': serializer.toJson<String>(flagsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GameState copyWith(
          {int? id,
          int? conversationId,
          int? affection,
          String? mood,
          String? scene,
          String? timeSlot,
          String? flagsJson,
          DateTime? updatedAt}) =>
      GameState(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        affection: affection ?? this.affection,
        mood: mood ?? this.mood,
        scene: scene ?? this.scene,
        timeSlot: timeSlot ?? this.timeSlot,
        flagsJson: flagsJson ?? this.flagsJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GameState copyWithCompanion(GameStatesCompanion data) {
    return GameState(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      affection: data.affection.present ? data.affection.value : this.affection,
      mood: data.mood.present ? data.mood.value : this.mood,
      scene: data.scene.present ? data.scene.value : this.scene,
      timeSlot: data.timeSlot.present ? data.timeSlot.value : this.timeSlot,
      flagsJson: data.flagsJson.present ? data.flagsJson.value : this.flagsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameState(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('affection: $affection, ')
          ..write('mood: $mood, ')
          ..write('scene: $scene, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('flagsJson: $flagsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, affection, mood, scene,
      timeSlot, flagsJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameState &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.affection == this.affection &&
          other.mood == this.mood &&
          other.scene == this.scene &&
          other.timeSlot == this.timeSlot &&
          other.flagsJson == this.flagsJson &&
          other.updatedAt == this.updatedAt);
}

class GameStatesCompanion extends UpdateCompanion<GameState> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<int> affection;
  final Value<String> mood;
  final Value<String> scene;
  final Value<String> timeSlot;
  final Value<String> flagsJson;
  final Value<DateTime> updatedAt;
  const GameStatesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.affection = const Value.absent(),
    this.mood = const Value.absent(),
    this.scene = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.flagsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GameStatesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    this.affection = const Value.absent(),
    this.mood = const Value.absent(),
    this.scene = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.flagsJson = const Value.absent(),
    required DateTime updatedAt,
  })  : conversationId = Value(conversationId),
        updatedAt = Value(updatedAt);
  static Insertable<GameState> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<int>? affection,
    Expression<String>? mood,
    Expression<String>? scene,
    Expression<String>? timeSlot,
    Expression<String>? flagsJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (affection != null) 'affection': affection,
      if (mood != null) 'mood': mood,
      if (scene != null) 'scene': scene,
      if (timeSlot != null) 'time_slot': timeSlot,
      if (flagsJson != null) 'flags_json': flagsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GameStatesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<int>? affection,
      Value<String>? mood,
      Value<String>? scene,
      Value<String>? timeSlot,
      Value<String>? flagsJson,
      Value<DateTime>? updatedAt}) {
    return GameStatesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      affection: affection ?? this.affection,
      mood: mood ?? this.mood,
      scene: scene ?? this.scene,
      timeSlot: timeSlot ?? this.timeSlot,
      flagsJson: flagsJson ?? this.flagsJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (affection.present) {
      map['affection'] = Variable<int>(affection.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (scene.present) {
      map['scene'] = Variable<String>(scene.value);
    }
    if (timeSlot.present) {
      map['time_slot'] = Variable<String>(timeSlot.value);
    }
    if (flagsJson.present) {
      map['flags_json'] = Variable<String>(flagsJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameStatesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('affection: $affection, ')
          ..write('mood: $mood, ')
          ..write('scene: $scene, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('flagsJson: $flagsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AiSettingsTable extends AiSettings
    with TableInfo<$AiSettingsTable, AiSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _baseUrlMeta =
      const VerificationMeta('baseUrl');
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.7));
  static const VerificationMeta _maxTokensMeta =
      const VerificationMeta('maxTokens');
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
      'max_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4096));
  static const VerificationMeta _contextWindowMeta =
      const VerificationMeta('contextWindow');
  @override
  late final GeneratedColumn<int> contextWindow = GeneratedColumn<int>(
      'context_window', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(128000));
  static const VerificationMeta _truncateStrategyMeta =
      const VerificationMeta('truncateStrategy');
  @override
  late final GeneratedColumn<String> truncateStrategy = GeneratedColumn<String>(
      'truncate_strategy', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('compress'));
  static const VerificationMeta _truncateLimitMeta =
      const VerificationMeta('truncateLimit');
  @override
  late final GeneratedColumn<int> truncateLimit = GeneratedColumn<int>(
      'truncate_limit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _markdownRenderMeta =
      const VerificationMeta('markdownRender');
  @override
  late final GeneratedColumn<bool> markdownRender = GeneratedColumn<bool>(
      'markdown_render', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("markdown_render" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        baseUrl,
        model,
        temperature,
        maxTokens,
        contextWindow,
        truncateStrategy,
        truncateLimit,
        markdownRender,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AiSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('base_url')) {
      context.handle(_baseUrlMeta,
          baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta));
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('max_tokens')) {
      context.handle(_maxTokensMeta,
          maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta));
    }
    if (data.containsKey('context_window')) {
      context.handle(
          _contextWindowMeta,
          contextWindow.isAcceptableOrUnknown(
              data['context_window']!, _contextWindowMeta));
    }
    if (data.containsKey('truncate_strategy')) {
      context.handle(
          _truncateStrategyMeta,
          truncateStrategy.isAcceptableOrUnknown(
              data['truncate_strategy']!, _truncateStrategyMeta));
    }
    if (data.containsKey('truncate_limit')) {
      context.handle(
          _truncateLimitMeta,
          truncateLimit.isAcceptableOrUnknown(
              data['truncate_limit']!, _truncateLimitMeta));
    }
    if (data.containsKey('markdown_render')) {
      context.handle(
          _markdownRenderMeta,
          markdownRender.isAcceptableOrUnknown(
              data['markdown_render']!, _markdownRenderMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature'])!,
      maxTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_tokens'])!,
      contextWindow: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}context_window'])!,
      truncateStrategy: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}truncate_strategy'])!,
      truncateLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}truncate_limit'])!,
      markdownRender: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}markdown_render'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AiSettingsTable createAlias(String alias) {
    return $AiSettingsTable(attachedDatabase, alias);
  }
}

class AiSetting extends DataClass implements Insertable<AiSetting> {
  final int id;
  final String baseUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final int contextWindow;
  final String truncateStrategy;
  final int truncateLimit;
  final bool markdownRender;
  final DateTime updatedAt;
  const AiSetting(
      {required this.id,
      required this.baseUrl,
      required this.model,
      required this.temperature,
      required this.maxTokens,
      required this.contextWindow,
      required this.truncateStrategy,
      required this.truncateLimit,
      required this.markdownRender,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_url'] = Variable<String>(baseUrl);
    map['model'] = Variable<String>(model);
    map['temperature'] = Variable<double>(temperature);
    map['max_tokens'] = Variable<int>(maxTokens);
    map['context_window'] = Variable<int>(contextWindow);
    map['truncate_strategy'] = Variable<String>(truncateStrategy);
    map['truncate_limit'] = Variable<int>(truncateLimit);
    map['markdown_render'] = Variable<bool>(markdownRender);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiSettingsCompanion toCompanion(bool nullToAbsent) {
    return AiSettingsCompanion(
      id: Value(id),
      baseUrl: Value(baseUrl),
      model: Value(model),
      temperature: Value(temperature),
      maxTokens: Value(maxTokens),
      contextWindow: Value(contextWindow),
      truncateStrategy: Value(truncateStrategy),
      truncateLimit: Value(truncateLimit),
      markdownRender: Value(markdownRender),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiSetting(
      id: serializer.fromJson<int>(json['id']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      model: serializer.fromJson<String>(json['model']),
      temperature: serializer.fromJson<double>(json['temperature']),
      maxTokens: serializer.fromJson<int>(json['maxTokens']),
      contextWindow: serializer.fromJson<int>(json['contextWindow']),
      truncateStrategy: serializer.fromJson<String>(json['truncateStrategy']),
      truncateLimit: serializer.fromJson<int>(json['truncateLimit']),
      markdownRender: serializer.fromJson<bool>(json['markdownRender']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'model': serializer.toJson<String>(model),
      'temperature': serializer.toJson<double>(temperature),
      'maxTokens': serializer.toJson<int>(maxTokens),
      'contextWindow': serializer.toJson<int>(contextWindow),
      'truncateStrategy': serializer.toJson<String>(truncateStrategy),
      'truncateLimit': serializer.toJson<int>(truncateLimit),
      'markdownRender': serializer.toJson<bool>(markdownRender),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiSetting copyWith(
          {int? id,
          String? baseUrl,
          String? model,
          double? temperature,
          int? maxTokens,
          int? contextWindow,
          String? truncateStrategy,
          int? truncateLimit,
          bool? markdownRender,
          DateTime? updatedAt}) =>
      AiSetting(
        id: id ?? this.id,
        baseUrl: baseUrl ?? this.baseUrl,
        model: model ?? this.model,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
        contextWindow: contextWindow ?? this.contextWindow,
        truncateStrategy: truncateStrategy ?? this.truncateStrategy,
        truncateLimit: truncateLimit ?? this.truncateLimit,
        markdownRender: markdownRender ?? this.markdownRender,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AiSetting copyWithCompanion(AiSettingsCompanion data) {
    return AiSetting(
      id: data.id.present ? data.id.value : this.id,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      model: data.model.present ? data.model.value : this.model,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      maxTokens: data.maxTokens.present ? data.maxTokens.value : this.maxTokens,
      contextWindow: data.contextWindow.present
          ? data.contextWindow.value
          : this.contextWindow,
      truncateStrategy: data.truncateStrategy.present
          ? data.truncateStrategy.value
          : this.truncateStrategy,
      truncateLimit: data.truncateLimit.present
          ? data.truncateLimit.value
          : this.truncateLimit,
      markdownRender: data.markdownRender.present
          ? data.markdownRender.value
          : this.markdownRender,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiSetting(')
          ..write('id: $id, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('model: $model, ')
          ..write('temperature: $temperature, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('contextWindow: $contextWindow, ')
          ..write('truncateStrategy: $truncateStrategy, ')
          ..write('truncateLimit: $truncateLimit, ')
          ..write('markdownRender: $markdownRender, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      baseUrl,
      model,
      temperature,
      maxTokens,
      contextWindow,
      truncateStrategy,
      truncateLimit,
      markdownRender,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiSetting &&
          other.id == this.id &&
          other.baseUrl == this.baseUrl &&
          other.model == this.model &&
          other.temperature == this.temperature &&
          other.maxTokens == this.maxTokens &&
          other.contextWindow == this.contextWindow &&
          other.truncateStrategy == this.truncateStrategy &&
          other.truncateLimit == this.truncateLimit &&
          other.markdownRender == this.markdownRender &&
          other.updatedAt == this.updatedAt);
}

class AiSettingsCompanion extends UpdateCompanion<AiSetting> {
  final Value<int> id;
  final Value<String> baseUrl;
  final Value<String> model;
  final Value<double> temperature;
  final Value<int> maxTokens;
  final Value<int> contextWindow;
  final Value<String> truncateStrategy;
  final Value<int> truncateLimit;
  final Value<bool> markdownRender;
  final Value<DateTime> updatedAt;
  const AiSettingsCompanion({
    this.id = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.model = const Value.absent(),
    this.temperature = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.contextWindow = const Value.absent(),
    this.truncateStrategy = const Value.absent(),
    this.truncateLimit = const Value.absent(),
    this.markdownRender = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AiSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String baseUrl,
    required String model,
    this.temperature = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.contextWindow = const Value.absent(),
    this.truncateStrategy = const Value.absent(),
    this.truncateLimit = const Value.absent(),
    this.markdownRender = const Value.absent(),
    required DateTime updatedAt,
  })  : baseUrl = Value(baseUrl),
        model = Value(model),
        updatedAt = Value(updatedAt);
  static Insertable<AiSetting> custom({
    Expression<int>? id,
    Expression<String>? baseUrl,
    Expression<String>? model,
    Expression<double>? temperature,
    Expression<int>? maxTokens,
    Expression<int>? contextWindow,
    Expression<String>? truncateStrategy,
    Expression<int>? truncateLimit,
    Expression<bool>? markdownRender,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseUrl != null) 'base_url': baseUrl,
      if (model != null) 'model': model,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (contextWindow != null) 'context_window': contextWindow,
      if (truncateStrategy != null) 'truncate_strategy': truncateStrategy,
      if (truncateLimit != null) 'truncate_limit': truncateLimit,
      if (markdownRender != null) 'markdown_render': markdownRender,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AiSettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? baseUrl,
      Value<String>? model,
      Value<double>? temperature,
      Value<int>? maxTokens,
      Value<int>? contextWindow,
      Value<String>? truncateStrategy,
      Value<int>? truncateLimit,
      Value<bool>? markdownRender,
      Value<DateTime>? updatedAt}) {
    return AiSettingsCompanion(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      contextWindow: contextWindow ?? this.contextWindow,
      truncateStrategy: truncateStrategy ?? this.truncateStrategy,
      truncateLimit: truncateLimit ?? this.truncateLimit,
      markdownRender: markdownRender ?? this.markdownRender,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (maxTokens.present) {
      map['max_tokens'] = Variable<int>(maxTokens.value);
    }
    if (contextWindow.present) {
      map['context_window'] = Variable<int>(contextWindow.value);
    }
    if (truncateStrategy.present) {
      map['truncate_strategy'] = Variable<String>(truncateStrategy.value);
    }
    if (truncateLimit.present) {
      map['truncate_limit'] = Variable<int>(truncateLimit.value);
    }
    if (markdownRender.present) {
      map['markdown_render'] = Variable<bool>(markdownRender.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiSettingsCompanion(')
          ..write('id: $id, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('model: $model, ')
          ..write('temperature: $temperature, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('contextWindow: $contextWindow, ')
          ..write('truncateStrategy: $truncateStrategy, ')
          ..write('truncateLimit: $truncateLimit, ')
          ..write('markdownRender: $markdownRender, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ChoicesTable choices = $ChoicesTable(this);
  late final $GameStatesTable gameStates = $GameStatesTable(this);
  late final $AiSettingsTable aiSettings = $AiSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [characters, conversations, messages, choices, gameStates, aiSettings];
}

typedef $$CharactersTableCreateCompanionBuilder = CharactersCompanion Function({
  Value<int> id,
  required String name,
  required String displayName,
  required String systemPrompt,
  required String greeting,
  required String worldSetting,
  Value<String?> replyStyle,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$CharactersTableUpdateCompanionBuilder = CharactersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> displayName,
  Value<String> systemPrompt,
  Value<String> greeting,
  Value<String> worldSetting,
  Value<String?> replyStyle,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get greeting => $composableBuilder(
      column: $table.greeting, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get worldSetting => $composableBuilder(
      column: $table.worldSetting, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyStyle => $composableBuilder(
      column: $table.replyStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get greeting => $composableBuilder(
      column: $table.greeting, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get worldSetting => $composableBuilder(
      column: $table.worldSetting,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyStyle => $composableBuilder(
      column: $table.replyStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => column);

  GeneratedColumn<String> get greeting =>
      $composableBuilder(column: $table.greeting, builder: (column) => column);

  GeneratedColumn<String> get worldSetting => $composableBuilder(
      column: $table.worldSetting, builder: (column) => column);

  GeneratedColumn<String> get replyStyle => $composableBuilder(
      column: $table.replyStyle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CharactersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CharactersTable,
    Character,
    $$CharactersTableFilterComposer,
    $$CharactersTableOrderingComposer,
    $$CharactersTableAnnotationComposer,
    $$CharactersTableCreateCompanionBuilder,
    $$CharactersTableUpdateCompanionBuilder,
    (Character, BaseReferences<_$AppDatabase, $CharactersTable, Character>),
    Character,
    PrefetchHooks Function()> {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> systemPrompt = const Value.absent(),
            Value<String> greeting = const Value.absent(),
            Value<String> worldSetting = const Value.absent(),
            Value<String?> replyStyle = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CharactersCompanion(
            id: id,
            name: name,
            displayName: displayName,
            systemPrompt: systemPrompt,
            greeting: greeting,
            worldSetting: worldSetting,
            replyStyle: replyStyle,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String displayName,
            required String systemPrompt,
            required String greeting,
            required String worldSetting,
            Value<String?> replyStyle = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              CharactersCompanion.insert(
            id: id,
            name: name,
            displayName: displayName,
            systemPrompt: systemPrompt,
            greeting: greeting,
            worldSetting: worldSetting,
            replyStyle: replyStyle,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CharactersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CharactersTable,
    Character,
    $$CharactersTableFilterComposer,
    $$CharactersTableOrderingComposer,
    $$CharactersTableAnnotationComposer,
    $$CharactersTableCreateCompanionBuilder,
    $$CharactersTableUpdateCompanionBuilder,
    (Character, BaseReferences<_$AppDatabase, $CharactersTable, Character>),
    Character,
    PrefetchHooks Function()>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  required int characterId,
  required String title,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  Value<int> characterId,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
});

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> characterId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            characterId: characterId,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int characterId,
            required String title,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> archivedAt = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            characterId: characterId,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required int conversationId,
  required String role,
  Value<String?> speaker,
  required String content,
  Value<String?> rawPayload,
  Value<String?> reasoningContent,
  required DateTime createdAt,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<String> role,
  Value<String?> speaker,
  Value<String> content,
  Value<String?> rawPayload,
  Value<String?> reasoningContent,
  Value<DateTime> createdAt,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speaker => $composableBuilder(
      column: $table.speaker, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawPayload => $composableBuilder(
      column: $table.rawPayload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasoningContent => $composableBuilder(
      column: $table.reasoningContent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speaker => $composableBuilder(
      column: $table.speaker, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawPayload => $composableBuilder(
      column: $table.rawPayload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasoningContent => $composableBuilder(
      column: $table.reasoningContent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get rawPayload => $composableBuilder(
      column: $table.rawPayload, builder: (column) => column);

  GeneratedColumn<String> get reasoningContent => $composableBuilder(
      column: $table.reasoningContent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> speaker = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> rawPayload = const Value.absent(),
            Value<String?> reasoningContent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            speaker: speaker,
            content: content,
            rawPayload: rawPayload,
            reasoningContent: reasoningContent,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required String role,
            Value<String?> speaker = const Value.absent(),
            required String content,
            Value<String?> rawPayload = const Value.absent(),
            Value<String?> reasoningContent = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            speaker: speaker,
            content: content,
            rawPayload: rawPayload,
            reasoningContent: reasoningContent,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$ChoicesTableCreateCompanionBuilder = ChoicesCompanion Function({
  Value<int> id,
  required int conversationId,
  required int messageId,
  required String choiceKey,
  required String choiceText,
  Value<DateTime?> selectedAt,
});
typedef $$ChoicesTableUpdateCompanionBuilder = ChoicesCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<int> messageId,
  Value<String> choiceKey,
  Value<String> choiceText,
  Value<DateTime?> selectedAt,
});

class $$ChoicesTableFilterComposer
    extends Composer<_$AppDatabase, $ChoicesTable> {
  $$ChoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get choiceKey => $composableBuilder(
      column: $table.choiceKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get choiceText => $composableBuilder(
      column: $table.choiceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get selectedAt => $composableBuilder(
      column: $table.selectedAt, builder: (column) => ColumnFilters(column));
}

class $$ChoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChoicesTable> {
  $$ChoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get choiceKey => $composableBuilder(
      column: $table.choiceKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get choiceText => $composableBuilder(
      column: $table.choiceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get selectedAt => $composableBuilder(
      column: $table.selectedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChoicesTable> {
  $$ChoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get choiceKey =>
      $composableBuilder(column: $table.choiceKey, builder: (column) => column);

  GeneratedColumn<String> get choiceText => $composableBuilder(
      column: $table.choiceText, builder: (column) => column);

  GeneratedColumn<DateTime> get selectedAt => $composableBuilder(
      column: $table.selectedAt, builder: (column) => column);
}

class $$ChoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChoicesTable,
    Choice,
    $$ChoicesTableFilterComposer,
    $$ChoicesTableOrderingComposer,
    $$ChoicesTableAnnotationComposer,
    $$ChoicesTableCreateCompanionBuilder,
    $$ChoicesTableUpdateCompanionBuilder,
    (Choice, BaseReferences<_$AppDatabase, $ChoicesTable, Choice>),
    Choice,
    PrefetchHooks Function()> {
  $$ChoicesTableTableManager(_$AppDatabase db, $ChoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<int> messageId = const Value.absent(),
            Value<String> choiceKey = const Value.absent(),
            Value<String> choiceText = const Value.absent(),
            Value<DateTime?> selectedAt = const Value.absent(),
          }) =>
              ChoicesCompanion(
            id: id,
            conversationId: conversationId,
            messageId: messageId,
            choiceKey: choiceKey,
            choiceText: choiceText,
            selectedAt: selectedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required int messageId,
            required String choiceKey,
            required String choiceText,
            Value<DateTime?> selectedAt = const Value.absent(),
          }) =>
              ChoicesCompanion.insert(
            id: id,
            conversationId: conversationId,
            messageId: messageId,
            choiceKey: choiceKey,
            choiceText: choiceText,
            selectedAt: selectedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChoicesTable,
    Choice,
    $$ChoicesTableFilterComposer,
    $$ChoicesTableOrderingComposer,
    $$ChoicesTableAnnotationComposer,
    $$ChoicesTableCreateCompanionBuilder,
    $$ChoicesTableUpdateCompanionBuilder,
    (Choice, BaseReferences<_$AppDatabase, $ChoicesTable, Choice>),
    Choice,
    PrefetchHooks Function()>;
typedef $$GameStatesTableCreateCompanionBuilder = GameStatesCompanion Function({
  Value<int> id,
  required int conversationId,
  Value<int> affection,
  Value<String> mood,
  Value<String> scene,
  Value<String> timeSlot,
  Value<String> flagsJson,
  required DateTime updatedAt,
});
typedef $$GameStatesTableUpdateCompanionBuilder = GameStatesCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<int> affection,
  Value<String> mood,
  Value<String> scene,
  Value<String> timeSlot,
  Value<String> flagsJson,
  Value<DateTime> updatedAt,
});

class $$GameStatesTableFilterComposer
    extends Composer<_$AppDatabase, $GameStatesTable> {
  $$GameStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get affection => $composableBuilder(
      column: $table.affection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scene => $composableBuilder(
      column: $table.scene, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeSlot => $composableBuilder(
      column: $table.timeSlot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flagsJson => $composableBuilder(
      column: $table.flagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GameStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameStatesTable> {
  $$GameStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get affection => $composableBuilder(
      column: $table.affection, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scene => $composableBuilder(
      column: $table.scene, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeSlot => $composableBuilder(
      column: $table.timeSlot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flagsJson => $composableBuilder(
      column: $table.flagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GameStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameStatesTable> {
  $$GameStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<int> get affection =>
      $composableBuilder(column: $table.affection, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get scene =>
      $composableBuilder(column: $table.scene, builder: (column) => column);

  GeneratedColumn<String> get timeSlot =>
      $composableBuilder(column: $table.timeSlot, builder: (column) => column);

  GeneratedColumn<String> get flagsJson =>
      $composableBuilder(column: $table.flagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GameStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GameStatesTable,
    GameState,
    $$GameStatesTableFilterComposer,
    $$GameStatesTableOrderingComposer,
    $$GameStatesTableAnnotationComposer,
    $$GameStatesTableCreateCompanionBuilder,
    $$GameStatesTableUpdateCompanionBuilder,
    (GameState, BaseReferences<_$AppDatabase, $GameStatesTable, GameState>),
    GameState,
    PrefetchHooks Function()> {
  $$GameStatesTableTableManager(_$AppDatabase db, $GameStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<int> affection = const Value.absent(),
            Value<String> mood = const Value.absent(),
            Value<String> scene = const Value.absent(),
            Value<String> timeSlot = const Value.absent(),
            Value<String> flagsJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GameStatesCompanion(
            id: id,
            conversationId: conversationId,
            affection: affection,
            mood: mood,
            scene: scene,
            timeSlot: timeSlot,
            flagsJson: flagsJson,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            Value<int> affection = const Value.absent(),
            Value<String> mood = const Value.absent(),
            Value<String> scene = const Value.absent(),
            Value<String> timeSlot = const Value.absent(),
            Value<String> flagsJson = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              GameStatesCompanion.insert(
            id: id,
            conversationId: conversationId,
            affection: affection,
            mood: mood,
            scene: scene,
            timeSlot: timeSlot,
            flagsJson: flagsJson,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GameStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GameStatesTable,
    GameState,
    $$GameStatesTableFilterComposer,
    $$GameStatesTableOrderingComposer,
    $$GameStatesTableAnnotationComposer,
    $$GameStatesTableCreateCompanionBuilder,
    $$GameStatesTableUpdateCompanionBuilder,
    (GameState, BaseReferences<_$AppDatabase, $GameStatesTable, GameState>),
    GameState,
    PrefetchHooks Function()>;
typedef $$AiSettingsTableCreateCompanionBuilder = AiSettingsCompanion Function({
  Value<int> id,
  required String baseUrl,
  required String model,
  Value<double> temperature,
  Value<int> maxTokens,
  Value<int> contextWindow,
  Value<String> truncateStrategy,
  Value<int> truncateLimit,
  Value<bool> markdownRender,
  required DateTime updatedAt,
});
typedef $$AiSettingsTableUpdateCompanionBuilder = AiSettingsCompanion Function({
  Value<int> id,
  Value<String> baseUrl,
  Value<String> model,
  Value<double> temperature,
  Value<int> maxTokens,
  Value<int> contextWindow,
  Value<String> truncateStrategy,
  Value<int> truncateLimit,
  Value<bool> markdownRender,
  Value<DateTime> updatedAt,
});

class $$AiSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AiSettingsTable> {
  $$AiSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxTokens => $composableBuilder(
      column: $table.maxTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get contextWindow => $composableBuilder(
      column: $table.contextWindow, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truncateStrategy => $composableBuilder(
      column: $table.truncateStrategy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get truncateLimit => $composableBuilder(
      column: $table.truncateLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get markdownRender => $composableBuilder(
      column: $table.markdownRender,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AiSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiSettingsTable> {
  $$AiSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxTokens => $composableBuilder(
      column: $table.maxTokens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get contextWindow => $composableBuilder(
      column: $table.contextWindow,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truncateStrategy => $composableBuilder(
      column: $table.truncateStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get truncateLimit => $composableBuilder(
      column: $table.truncateLimit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get markdownRender => $composableBuilder(
      column: $table.markdownRender,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AiSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiSettingsTable> {
  $$AiSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<int> get contextWindow => $composableBuilder(
      column: $table.contextWindow, builder: (column) => column);

  GeneratedColumn<String> get truncateStrategy => $composableBuilder(
      column: $table.truncateStrategy, builder: (column) => column);

  GeneratedColumn<int> get truncateLimit => $composableBuilder(
      column: $table.truncateLimit, builder: (column) => column);

  GeneratedColumn<bool> get markdownRender => $composableBuilder(
      column: $table.markdownRender, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiSettingsTable,
    AiSetting,
    $$AiSettingsTableFilterComposer,
    $$AiSettingsTableOrderingComposer,
    $$AiSettingsTableAnnotationComposer,
    $$AiSettingsTableCreateCompanionBuilder,
    $$AiSettingsTableUpdateCompanionBuilder,
    (AiSetting, BaseReferences<_$AppDatabase, $AiSettingsTable, AiSetting>),
    AiSetting,
    PrefetchHooks Function()> {
  $$AiSettingsTableTableManager(_$AppDatabase db, $AiSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> baseUrl = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<double> temperature = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> contextWindow = const Value.absent(),
            Value<String> truncateStrategy = const Value.absent(),
            Value<int> truncateLimit = const Value.absent(),
            Value<bool> markdownRender = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AiSettingsCompanion(
            id: id,
            baseUrl: baseUrl,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            contextWindow: contextWindow,
            truncateStrategy: truncateStrategy,
            truncateLimit: truncateLimit,
            markdownRender: markdownRender,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String baseUrl,
            required String model,
            Value<double> temperature = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> contextWindow = const Value.absent(),
            Value<String> truncateStrategy = const Value.absent(),
            Value<int> truncateLimit = const Value.absent(),
            Value<bool> markdownRender = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              AiSettingsCompanion.insert(
            id: id,
            baseUrl: baseUrl,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            contextWindow: contextWindow,
            truncateStrategy: truncateStrategy,
            truncateLimit: truncateLimit,
            markdownRender: markdownRender,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiSettingsTable,
    AiSetting,
    $$AiSettingsTableFilterComposer,
    $$AiSettingsTableOrderingComposer,
    $$AiSettingsTableAnnotationComposer,
    $$AiSettingsTableCreateCompanionBuilder,
    $$AiSettingsTableUpdateCompanionBuilder,
    (AiSetting, BaseReferences<_$AppDatabase, $AiSettingsTable, AiSetting>),
    AiSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ChoicesTableTableManager get choices =>
      $$ChoicesTableTableManager(_db, _db.choices);
  $$GameStatesTableTableManager get gameStates =>
      $$GameStatesTableTableManager(_db, _db.gameStates);
  $$AiSettingsTableTableManager get aiSettings =>
      $$AiSettingsTableTableManager(_db, _db.aiSettings);
}
