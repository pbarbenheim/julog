import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/jugendliche/jugendlicher.dart';
import 'package:julog/repository/util/geschlecht.dart';
import 'package:sqlite3/sqlite3.dart';

class JugendlicherRepository {
  final JulogDatabase _database;

  PreparedStatement? _getAll;
  PreparedStatement? _get;
  PreparedStatement? _insert;

  JugendlicherRepository({required JulogDatabase database})
      : _database = database;

  void dispose() {
    _get?.dispose();
    _getAll?.dispose();
    _insert?.dispose();
  }

  List<JugendlicherHeader> getAllJugendliche({
    bool excludeReplaced = true,
    bool onlyActive = true,
  }) {
    _getAll ??= _database.getPreparedPersistent("""
      select id, name, austrittsgrund, ersetzt_durch
      from jugendlicher
    """);

    Iterable<Row> result = _getAll!.select();
    if (excludeReplaced) {
      result = result.where((r) => r["ersetzt_durch"] == null);
    }
    if (onlyActive) {
      result = result.where((r) => r["austrittsgrund"] == null);
    }

    return result
        .map((row) => JugendlicherHeader(
              id: row["id"],
              name: row["name"],
              ersetztDurch: row["ersetzt_durch"],
            ))
        .toList();
  }

  Jugendlicher getJugendlicher(int id, {bool followLinks = true}) {
    _get ??= _database.getPreparedPersistent("""
      select *
      from jugendlicher
      where id = ?
    """);

    final result = _get!.select([id]).first;
    final austrittsdatum = result["austrittsdatum"];
    final j = Jugendlicher(
      id: id,
      name: result["name"],
      geburtstag: DateTime.fromMillisecondsSinceEpoch(result["geburtstag"]),
      eintrittsdatum:
          DateTime.fromMillisecondsSinceEpoch(result["eintrittsdatum"]),
      geschlecht: Geschlecht.fromNumber(result["geschlecht"]),
      passnummer: result["passnummer"],
      austrittsgrund: result["austrittsgrund"],
      ersetztDurch: result["ersetzt_durch"],
      austrittsdatum: austrittsdatum != null
          ? DateTime.fromMillisecondsSinceEpoch(austrittsdatum)
          : null,
    );

    if (followLinks && j.isErsetzt) {
      return getJugendlicher(j.ersetztDurch!, followLinks: true);
    }
    return j;
  }

  int addJugendlicher({
    required String name,
    required Geschlecht geschlecht,
    required DateTime geburtstag,
    required DateTime eintrittsdatum,
    String? passnummer,
  }) {
    _insert ??= _database.getPreparedPersistent("""
      insert into jugendliche
        (name, passnummer, geburtstag, eintrittsdatum, geschlecht)
      values
        (?, ?, ?, ?, ?)
      returning id
    """);

    final id = _insert!.select([
      name,
      passnummer,
      geburtstag.millisecondsSinceEpoch,
      eintrittsdatum.millisecondsSinceEpoch,
      geschlecht.toNumber(),
    ]).first["id"];

    return id;
  }
}
