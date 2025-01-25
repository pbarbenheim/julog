import 'package:julog/repository/betreuer/betreuer.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/eintrag/eintrag.dart';
import 'package:julog/repository/identity/identity.dart';
import 'package:julog/repository/signatures/signatur.dart';
import 'package:julog/repository/jugendliche/jugendlicher.dart';
import 'package:julog/repository/kategorien/kategorie.dart';
import 'package:julog/repository/util/geschlecht.dart';
import 'package:sqlite3/sqlite3.dart';

class EintragRepository {
  final JulogDatabase _database;

  PreparedStatement? _getAll;

  PreparedStatement? _getOne;
  PreparedStatement? _getJugendliche;
  PreparedStatement? _getBetreuer;
  PreparedStatement? _getSignaturen;

  PreparedStatement? _insertEintrag;
  PreparedStatement? _insertBetreuer;
  PreparedStatement? _insertJugendliche;

  EintragRepository({required JulogDatabase database}) : _database = database;

  void dispose() {
    _getAll?.dispose();
    _getOne?.dispose();
    _getJugendliche?.dispose();
    _getBetreuer?.dispose();
    _getSignaturen?.dispose();
    _insertBetreuer?.dispose();
    _insertEintrag?.dispose();
    _insertJugendliche?.dispose();
  }

  List<EintragHeader> getAllEintraege() {
    _getAll ??= _database.getPreparedPersistent("""
      select
        e.id as id,
        e.beginn as beginn,
        e.thema as thema,
        k.id as kid,
        k.name as kname
      from
        eintrag as e,
        kategorien as k
      where
        k.id = e.kategorie_id
    """);

    return _getAll!
        .select()
        .map((row) => EintragHeader(
              id: row["id"],
              beginn: DateTime.fromMillisecondsSinceEpoch(row["beginn"]),
              kategorie: Kategorie(id: row["kid"], name: row["kname"]),
              thema: row["thema"],
            ))
        .toList();
  }

  Eintrag getEintrag(int id) {
    _getOne ??= _database.getPreparedPersistent("""
      select
        e.id as id,
        e.beginn as beginn,
        e.ende as ende,
        k.id as kid,
        k.name as kname,
        e.thema as thema,
        e.ort as ort,
        e.raum as raum,
        e.dienstverlauf as dienstverlauf,
        e.besonderheiten as besonderheiten
      from 
        eintrag as e, 
        kategorien as k
      where e.kategorie_id = k.id 
        and e.id = ?
    """);

    _getJugendliche ??= _database.getPreparedPersistent("""
      select
        j.id as id,
        j.name as name,
        j.ersetzt_durch as ersetzt_durch,
        je.anwesenheit as anwesenheit
      from
        jugendlicher as j,
        eintrag_zu_jugendlicher as je
      where j.id = je.jugendlicher_id
        and je.eintrag_id = ?
    """);

    _getBetreuer ??= _database.getPreparedPersistent("""
      select
        b.id as id,
        b.name as name,
        b.geschlecht as geschlecht
      from 
        betreuer as b,
        eintrag_zu_betreuer as be
      where b.id = be.betreuer_id
        and be.eintrag_id = ?
    """);

    _getSignaturen ??= _database.getPreparedPersistent("""
      select *
      from signatures
      where eintrag_id = ?
    """);

    final eintragRes = _getOne!.select([id]);
    if (eintragRes.isEmpty) {
      throw Exception(); //TODO bessere Exception
    }
    final result = eintragRes.first;

    final List<JugendlicherInEintrag> jugendliche = _getJugendliche!
        .select([id])
        .map((row) => JugendlicherInEintrag(
              jugendlicher: JugendlicherHeader(
                id: row["id"],
                name: row["name"],
                ersetztDurch: row["ersetzt_durch"],
              ),
              anwesenheit:
                  JugendlicherAnwesenheit.fromNumber(row["anwesenheit"]),
            ))
        .toList();

    final List<Betreuer> betreuer = _getBetreuer!
        .select([id])
        .map((row) => Betreuer(
            id: row["id"],
            name: row["name"],
            geschlecht: Geschlecht.fromNumber(row["geschlecht"])))
        .toList();

    final Kategorie kategorie = Kategorie(
      id: result["kid"],
      name: result["kname"],
    );

    final Eintrag eintrag = Eintrag(
      id: id,
      beginn: DateTime.fromMillisecondsSinceEpoch(result["beginn"]),
      ende: DateTime.fromMillisecondsSinceEpoch(result["ende"]),
      kategorie: kategorie,
      thema: result["thema"],
      betreuer: betreuer,
      jugendliche: jugendliche,
      besonderheiten: result["besonderheiten"],
      dienstverlauf: result["dienstverlauf"],
      ort: result["ort"],
      raum: result["raum"],
      signaturen: [],
    );

    final signaturen = _getSignaturen!.select([id]).map((row) => Signatur(
          identity: Identity(userId: row["userid"]),
          signature: row["signature"],
          signedAt: DateTime.fromMillisecondsSinceEpoch(row["signed_at"]),
          signVersion: row["sign_version"],
          eintrag: eintrag,
        ));

    for (var signatur in signaturen) {
      eintrag.signaturen.add(signatur);
    }

    return eintrag;
  }

  int addEintrag({
    required DateTime beginn,
    required DateTime ende,
    required Kategorie kategorie,
    required String thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    required List<Betreuer> betreuers,
    required List<JugendlicherInEintrag> jugendliche,
  }) {
    _insertEintrag ??= _database.getPreparedPersistent("""
      insert into eintrag
        (beginn, ende, kategorie_id, thema, ort, raum, dienstverlauf, besonderheiten)
      values
        (?, ?, ?, ?, ?, ?, ?, ?)
      returning id
    """);
    _insertJugendliche ??= _database.getPreparedPersistent("""
      insert into eintrag_zu_jugendlicher
        (eintrag_id, jugendlicher_id, anwesenheit)
      values
        (?, ?, ?)
    """);
    _insertBetreuer ??= _database.getPreparedPersistent("""
      insert into eintrag_zu_betreuer
        (eintrag_id, betreuer_id)
      values
        (?, ?)
    """);

    final id = _insertEintrag!.select([
      beginn.millisecondsSinceEpoch,
      ende.millisecondsSinceEpoch,
      kategorie.id,
      thema,
      ort,
      raum,
      dienstverlauf,
      besonderheiten,
    ]).first["id"];

    for (final betreuer in betreuers) {
      _insertBetreuer!.execute([id, betreuer.id]);
    }

    for (final jugendlicher in jugendliche) {
      if (jugendlicher.anwesenheit == JugendlicherAnwesenheit.unbestimmt) {
        continue;
      }
      _insertJugendliche!.execute([
        id,
        jugendlicher.jugendlicher.id,
        jugendlicher.anwesenheit.toNumber(),
      ]);
    }

    return id;
  }
}
