import 'dart:convert';

import 'database/sqlite_worker.dart';
import 'migrations.dart';
import 'models/models.dart';
import 'signing.dart';
import 'types/types.dart';

const jldbCompatibleSinceVersion = 3;

final class Jldb {
  static const _getAllEintraegeSql = '''
    select 
      e.id,
      e.start,
      e.end,
      e.kategorie_id,
      e.thema,
      e.ort,
      e.raum,
      e.dienstverlauf,
      e.besonderheiten,
      j.jugendliche,
      b.betreuer
    from eintrag as e
      left join (
        select 
          ej.eintrag_id as eid,
          group_concat(concat(ej.jugendlicher_id, ':', ej.status), ',') as jugendliche
        from eintrag_jugendlicher as ej
        group by ej.eintrag_id
      ) as j on e.id = j.eid
      left join (
        select 
          eb.eintrag_id as eid,
          group_concat(eb.betreuer_id, ',') as betreuer
        from eintrag_betreuer as eb
        group by eb.eintrag_id
      ) as b on e.id = b.eid
      %COND%
  ;
  ''';
  static const _eintraegeColumns = [
    'id',
    'start',
    'end',
    'kategorie_id',
    'thema',
    'ort',
    'raum',
    'dienstverlauf',
    'besonderheiten',
    'status_jugendlicher_ids',
    'betreuer_ids',
  ];

  final String filename;

  final SqliteWorker _database;
  int? _version;
  WorkerStatement? _createBetreuerStmnt;
  WorkerStatement? _createIdentityStmnt;
  WorkerStatement? _createKategorieStmnt;
  WorkerStatement? _getAllIdentitiesStmnt;
  WorkerStatement? _getAllJugendlicheStmnt;
  WorkerStatement? _getAllKategorienStmnt;
  WorkerStatement? _getBetreuerStmnt;
  WorkerStatement? _getConfigStmnt;
  WorkerStatement? _getIdentityStmnt;
  WorkerStatement? _getJugendlicherStmnt;
  WorkerStatement? _getKategorieStmnt;
  WorkerStatement? _setConfigStmnt;

  WorkerStatement? _getAllBetreuerStmnt;

  WorkerStatement? _insertNewJugendlicherStmnt;

  WorkerStatement? _createSignatureStmnt;

  WorkerStatement? _getAllEintraegeStmnt;

  WorkerStatement? _getEintragStmnt;

  WorkerStatement? _getSignaturesByEintragIdStmnt;
  Jldb._(this.filename, this._database);

  AsyncResult<BetreuerApiModel> createBetreuer(
    BetreuerApiModel betreuer,
  ) async {
    const sql = '''
      insert into betreuer (id, name, sex) 
      values (?, ?, ?)
      returning id, name, sex;
    ''';
    return Result.safeAsync(() async {
      _createBetreuerStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _createBetreuerStmnt!.select([
        betreuer.id.toString(),
        betreuer.name,
        betreuer.sex.toInt(),
      ]);
      final row = result.first;
      final bet = BetreuerApiModel(
        id: row[0].toString().toUUID(),
        name: row[1].toString(),
        sex: Sex.fromInt(row[2] as int),
      );
      return bet;
    });
  }

  AsyncResult<EintragApiModel> createEintrag(EintragApiModel eintrag) {
    const createEintragSql = '''
      insert into eintrag (
        id,
        start,
        end,
        kategorie_id,
        thema,
        ort,
        raum,
        dienstverlauf,
        besonderheiten
      ) values (?, ?, ?, ?, ?, ?, ?, ?, ?);
    ''';
    const createEintragBetreuerSql = '''
      insert into eintrag_betreuer (eintrag_id, betreuer_id) 
      values (?, ?);
    ''';
    const createEintragJugendlicherSql = '''
      insert into eintrag_jugendlicher (eintrag_id, jugendlicher_id, status) 
      values (?, ?, ?);
    ''';
    return Result.safeAsync(() async {
      return await _database.transaction((db) async {
        await db.execute(createEintragSql, [
          eintrag.id.toString(),
          eintrag.start.millisecondsSinceEpoch,
          eintrag.end.millisecondsSinceEpoch,
          eintrag.kategorieId.toString(),
          eintrag.thema,
          eintrag.ort,
          eintrag.raum,
          eintrag.dienstverlauf,
          eintrag.besonderheiten,
        ]);
        for (final betreuerId in eintrag.betreuerIds) {
          await db.execute(createEintragBetreuerSql, [
            eintrag.id.toString(),
            betreuerId.toString(),
          ]);
        }
        for (final jugendlicherId in eintrag.anwesendeJugendlicherIds) {
          await db.execute(createEintragJugendlicherSql, [
            eintrag.id.toString(),
            jugendlicherId.toString(),
            eintragStatusAnwesend, // status: anwesend
          ]);
        }
        for (final jugendlicherId in eintrag.entschuldigteJugendlicherIds) {
          await db.execute(createEintragJugendlicherSql, [
            eintrag.id.toString(),
            jugendlicherId.toString(),
            eintragStatusEntschuldigt, // status: entschuldigt
          ]);
        }
        final result = await db.select(
          _getAllEintraegeSql.replaceFirst('%COND%', 'where e.id = ?'),
          [eintrag.id.toString()],
        );
        final row = result.first;
        final newEintrag = eintragApiModelFromDbArray(row, _eintraegeColumns);
        if (newEintrag != eintrag) {
          throw Exception(
            'Erstellter Eintrag stimmt nicht mit Eingabe überein.',
          );
        }
        return newEintrag;
      });
    });
  }

  AsyncResult<IdentityApiModel> createIdentity(
    IdentityApiModel identity,
  ) async {
    const sql = '''
      insert into identity (id, public_key) 
      values (?, ?)
      returning id, public_key;
    ''';
    return Result.safeAsync(() async {
      _createIdentityStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _createIdentityStmnt!.select([
        identity.id.toString(),
        identity.publicKey,
      ]);
      final row = result.first;
      final iden = IdentityApiModel(
        id: row[0].toString().toUUID(),
        publicKey: row[1].toString(),
      );
      return iden;
    });
  }

  AsyncResult<KategorieApiModel> createKategorie(
    KategorieApiModel kategorie,
  ) async {
    const sql = '''
      insert into kategorien (id, name) 
      values (?, ?)
      returning id, name;
    ''';
    return Result.safeAsync(() async {
      _createKategorieStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _createKategorieStmnt!.select([
        kategorie.id.toString(),
        kategorie.name,
      ]);
      final row = result.first;
      final kat = KategorieApiModel(
        id: row[0].toString().toUUID(),
        name: row[1].toString(),
      );
      return kat;
    });
  }

  AsyncResult<SignatureApiModel> createSignature(SignatureApiModel signature) {
    const sql = '''
      insert into signature (
        eintrag_id,
        identity_id,
        signature,
        timestamp,
        version
      ) values (?, ?, ?, ?, ?)
      returning 
        eintrag_id,
        identity_id,
        signature,
        timestamp,
        version;
    ''';
    return Result.safeAsync(() async {
      _createSignatureStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _createSignatureStmnt!.select([
        signature.eintragId.toString(),
        signature.identityId.toString(),
        signature.signature,
        signature.timestamp.millisecondsSinceEpoch,
        signature.version,
      ]);
      final row = result.first;
      final sig = SignatureApiModel(
        eintragId: row[0].toString().toUUID(),
        identityId: row[1].toString().toUUID(),
        signature: row[2].toString(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row[3] as int),
        version: row[4] as int,
      );
      return sig;
    });
  }

  Future<void> close() async {
    await _database.close();
  }

  AsyncResult<List<BetreuerApiModel>> getAllBetreuer() {
    const sql = 'select id, name, sex from betreuer;';
    return Result.safeAsync(() async {
      _getAllBetreuerStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getAllBetreuerStmnt!.select([]);
      final betreuer = result.map((row) {
        return BetreuerApiModel(
          id: row[0].toString().toUUID(),
          name: row[1].toString(),
          sex: Sex.fromInt(row[2] as int),
        );
      }).toList();
      return betreuer;
    });
  }

  AsyncResult<List<EintragApiModel>> getAllEintraege() async {
    return Result.safeAsync(() async {
      _getAllEintraegeStmnt ??= await _database.prepare(
        _getAllEintraegeSql.replaceFirst('%COND%', ''),
        peristent: true,
      );
      final result = await _getAllEintraegeStmnt!.select([]);
      final eintraege = result.map((row) {
        return eintragApiModelFromDbArray(row, _eintraegeColumns);
      });
      return eintraege.toList();
    });
  }

  AsyncResult<List<IdentityApiModel>> getAllIdentities() async {
    const sql = 'select id, public_key from identity;';
    return Result.safeAsync(() async {
      _getAllIdentitiesStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getAllIdentitiesStmnt!.select([]);
      final identities = result.map((row) {
        return IdentityApiModel(
          id: row[0].toString().toUUID(),
          publicKey: row[1].toString(),
        );
      }).toList();
      return identities;
    });
  }

  AsyncResult<List<JugendlicherApiModel>> getAllJugendliche() async {
    const sql = '''
      select 
        id, 
        name, 
        sex, 
        pass, 
        birth_date, 
        member_since, 
        exit_date, 
        exit_reason, 
        replaced_by_id 
      from jugendlicher;
    ''';
    return Result.safeAsync(() async {
      _getAllJugendlicheStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getAllJugendlicheStmnt!.select([]);
      final jugendliche = result.map((row) {
        return JugendlicherApiModel(
          id: row[0].toString().toUUID(),
          name: row[1].toString(),
          sex: Sex.fromInt(row[2] as int),
          pass: row[3]?.toString(),
          birthDate: DateTime.fromMillisecondsSinceEpoch(row[4] as int),
          memberSince: DateTime.fromMillisecondsSinceEpoch(row[5] as int),
          exitDate: row[6] != null
              ? DateTime.fromMillisecondsSinceEpoch(row[6] as int)
              : null,
          exitReason: row[7] != null ? row[7] as int : null,
          replacedById: row[8]?.toString().toUUID(),
        );
      }).toList();
      return jugendliche;
    });
  }

  AsyncResult<List<KategorieApiModel>> getAllKategorien() async {
    const sql = 'select id, name from kategorien;';
    return Result.safeAsync(() async {
      _getAllKategorienStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getAllKategorienStmnt!.select([]);
      final kategorien = result.map((row) {
        return KategorieApiModel(
          id: row[0].toString().toUUID(),
          name: row[1].toString(),
        );
      }).toList();
      return kategorien;
    });
  }

  AsyncResultOptional<BetreuerApiModel> getBetreuer(UUID id) async {
    const sql = 'select id, name, sex from betreuer where id = ?;';
    return Result.safeNullableAsync(() async {
      _getBetreuerStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getBetreuerStmnt!.select([id.toString()]);
      if (result.isEmpty) {
        return null;
      }
      final row = result.first;
      final bet = BetreuerApiModel(
        id: row[0].toString().toUUID(),
        name: row[1].toString(),
        sex: Sex.fromInt(row[2] as int),
      );
      return bet;
    });
  }

  AsyncResultOptional<String> getConfigValue(String key) async {
    const sql = 'select val from config where field = ?;';
    return Result.safeNullableAsync(() async {
      _getConfigStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getConfigStmnt!.select([key]);
      final val = result[0][0];
      if (val == null) {
        return null;
      } else {
        return val.toString();
      }
    });
  }

  AsyncResultOptional<EintragApiModel> getEintrag(UUID id) async {
    return Result.safeNullableAsync(() async {
      _getEintragStmnt ??= await _database.prepare(
        _getAllEintraegeSql.replaceFirst('%COND%', 'where e.id = ?'),
        peristent: true,
      );
      final result = await _getEintragStmnt!.select([id.toString()]);
      if (result.isEmpty) {
        return null;
      }
      final row = result.first;
      final eintrag = eintragApiModelFromDbArray(row, _eintraegeColumns);
      return eintrag;
    });
  }

  AsyncResultOptional<String> getEintragForSigning(
    UUID id,
    int version,
    DateTime timestamp,
  ) async {
    final query = switch (version) {
      4 => signV4Query,
      _ => throw UnsupportedError('Unsupported signing version: $version'),
    };
    return Result.safeNullableAsync(() async {
      final result = await _database.select(query, [id.toString()]);
      if (result.isEmpty) {
        return null;
      }
      final row = result.first;
      final json = row[0].toString();
      final data = jsonDecode(json) as Map<String, dynamic>;
      data.addAll({'timestamp': timestamp.millisecondsSinceEpoch});
      return json;
    });
  }

  AsyncResultOptional<IdentityApiModel> getIdentity(UUID id) async {
    const sql = 'select id, public_key from identity where id = ?;';
    return Result.safeNullableAsync(() async {
      _getIdentityStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getIdentityStmnt!.select([id.toString()]);
      if (result.isEmpty) {
        return null;
      }
      final row = result.first;
      final iden = IdentityApiModel(
        id: row[0].toString().toUUID(),
        publicKey: row[1].toString(),
      );
      return iden;
    });
  }

  AsyncResultOptional<JugendlicherApiModel> getJugendlicher(UUID id) async {
    const sql = '''
      select 
        id, 
        name,
        sex,
        pass,
        birth_date,
        member_since,
        exit_date,
        exit_reason,
        replaced_by_id
      from jugendlicher
      where id = ?;
    ''';
    return Result.safeNullableAsync(() async {
      _getJugendlicherStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getJugendlicherStmnt!.select([id.toString()]);
      if (result.isEmpty) {
        return null;
      }
      final row = result.first;
      final jug = JugendlicherApiModel(
        id: row[0].toString().toUUID(),
        name: row[1].toString(),
        sex: Sex.fromInt(row[2] as int),
        pass: row[3]?.toString(),
        birthDate: DateTime.fromMillisecondsSinceEpoch(row[4] as int),
        memberSince: DateTime.fromMillisecondsSinceEpoch(row[5] as int),
        exitDate: row[6] != null
            ? DateTime.fromMillisecondsSinceEpoch(row[6] as int)
            : null,
        exitReason: row[7] != null ? row[7] as int : null,
        replacedById: row[8]?.toString().toUUID(),
      );
      return jug;
    });
  }

  AsyncResultOptional<KategorieApiModel> getKategorie(UUID id) async {
    const sql = 'select id, name from kategorien where id = ?;';
    return Result.safeNullableAsync(() async {
      _getKategorieStmnt ??= await _database.prepare(sql, peristent: true);
      final result = await _getKategorieStmnt!.select([id.toString()]);
      if (result.isEmpty) {
        return null;
      }
      final row = result.first;
      final kat = KategorieApiModel(
        id: row[0].toString().toUUID(),
        name: row[1].toString(),
      );
      return kat;
    });
  }

  AsyncResult<List<SignatureApiModel>> getSignaturesByEintragId(
    UUID eintragId,
  ) {
    const sql = '''
      select 
        eintrag_id,
        identity_id,
        signature,
        timestamp,
        version
      from signature
      where eintrag_id = ?;
    ''';
    return Result.safeAsync(() async {
      _getSignaturesByEintragIdStmnt ??= await _database.prepare(
        sql,
        peristent: true,
      );
      final result = await _getSignaturesByEintragIdStmnt!.select([
        eintragId.toString(),
      ]);
      return result.map((row) {
        return SignatureApiModel(
          eintragId: row[0].toString().toUUID(),
          identityId: row[1].toString().toUUID(),
          signature: row[2].toString(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(row[3] as int),
          version: row[4] as int,
        );
      }).toList();
    });
  }

  Future<int> getVersion() async {
    _version ??= await _getVersion();
    return _version!;
  }

  AsyncVoidResult setConfigValue(String key, String value) async {
    const sql = '''
      insert into config (field, val) 
        values (?, ?) 
        on conflict(field) do update set val = ?;
    ''';
    return Result.voidSafeAsync(() async {
      _setConfigStmnt ??= await _database.prepare(sql, peristent: true);
      _setConfigStmnt!.execute([key, value, value]);
    });
  }

  AsyncResult<JugendlicherApiModel> upsertJugendlicher(
    JugendlicherApiModel jugendlicher,
  ) async {
    return Result.safeAsync(() async {
      final insertId = jugendlicher.id;
      final existing = await getJugendlicher(insertId).unwrap();
      switch (existing) {
        case Some(value: final value):
          final isSimpleUpdate = jugendlicher.canBeUpdatedFrom(value);
          if (isSimpleUpdate) {
            return _insertNewJugendlicher(jugendlicher).unwrap();
          } else {
            final newJugendlicher = jugendlicher.copyWith(
              id: UUID.generate(),
              replacedById: insertId,
            );
            return upsertJugendlicher(newJugendlicher).unwrap();
          }
        case None():
          return _insertNewJugendlicher(jugendlicher).unwrap();
      }
    });
  }

  Future<int> _getVersion() async {
    const stmt = 'PRAGMA user_version;';
    final result = await _database.select(stmt);
    final version = result.first.first;
    if (version is int) {
      return version;
    } else {
      return int.parse(version.toString());
    }
  }

  AsyncResult<JugendlicherApiModel> _insertNewJugendlicher(
    JugendlicherApiModel jugendlicher,
  ) {
    const insertNewSql = '''
          insert or replace into jugendlicher (
            id, 
            name,
            sex,
            pass,
            birth_date,
            member_since,
            exit_date,
            exit_reason,
            replaced_by_id
          ) values (?, ?, ?, ?, ?, ?, ?, ?, ?)
          returning 
            id,
            name,
            sex,
            pass,
            birth_date,
            member_since,
            exit_date,
            exit_reason,
            replaced_by_id;
        ''';
    return Result.safeAsync(() async {
      _insertNewJugendlicherStmnt ??= await _database.prepare(
        insertNewSql,
        peristent: true,
      );
      final result = await _insertNewJugendlicherStmnt!.select([
        jugendlicher.id.toString(),
        jugendlicher.name,
        jugendlicher.sex.toInt(),
        jugendlicher.pass,
        jugendlicher.birthDate.millisecondsSinceEpoch,
        jugendlicher.memberSince.millisecondsSinceEpoch,
        jugendlicher.exitDate?.millisecondsSinceEpoch,
        jugendlicher.exitReason,
        jugendlicher.replacedById?.toString(),
      ]);
      final row = result.first;
      final newJug = JugendlicherApiModel(
        id: row[0].toString().toUUID(),
        name: row[1].toString(),
        sex: Sex.fromInt(row[2] as int),
        pass: row[3]?.toString(),
        birthDate: DateTime.fromMillisecondsSinceEpoch(row[4] as int),
        memberSince: DateTime.fromMillisecondsSinceEpoch(row[5] as int),
        exitDate: row[6] != null
            ? DateTime.fromMillisecondsSinceEpoch(row[6] as int)
            : null,
        exitReason: row[7] != null ? row[7] as int : null,
        replacedById: row[8]?.toString().toUUID(),
      );
      return newJug;
    });
  }

  Future<void> _migrateIfNeeded() async {
    final currentVersion = await getVersion();
    if (currentVersion < jldbCompatibleSinceVersion) {
      throw Exception('Dateiformat zu alt.');
    }
    await _runMigrationsFromVersion(fromVersion: currentVersion);
  }

  Future<void> _runMigrationsFromVersion({int fromVersion = 0}) async {
    final migrations = DatabaseMigrations.getMigrations(
      currentVersion: fromVersion,
    );

    for (final migration in migrations) {
      await _database.execute(migration);
    }
    _version = null;
  }

  static AsyncResult<Jldb> create(
    String filename, {
    required String domain,
  }) async {
    return Result.safeAsync(() async {
      final database = await SqliteWorker.spawn(filename, createDatabase: true);
      final service = Jldb._(filename, database);
      await service._runMigrationsFromVersion();
      await service.setConfigValue('domain', domain).unwrap();
      return service;
    });
  }

  static AsyncResult<Jldb> open(String filename) async {
    return Result.safeAsync(() async {
      final database = await SqliteWorker.spawn(
        filename,
        createDatabase: false,
      );
      final service = Jldb._(filename, database);
      await service._migrateIfNeeded();
      return service;
    });
  }
}
