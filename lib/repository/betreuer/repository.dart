import 'package:julog/repository/betreuer/betreuer.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/util/geschlecht.dart';
import 'package:sqlite3/sqlite3.dart';

class BetreuerRepository {
  final JulogDatabase _database;

  PreparedStatement? _getAll;
  PreparedStatement? _insert;

  BetreuerRepository({required JulogDatabase database}) : _database = database;

  void dispose() {
    _getAll?.dispose();
    _insert?.dispose();
  }

  List<Betreuer> getAllBetreuer() {
    _getAll ??= _database
        .getPreparedPersistent("select id, name, geschlecht from betreuer");

    final result = _getAll!.select();
    return result
        .map((row) => Betreuer(
              id: row["id"],
              name: row["name"],
              geschlecht: Geschlecht.fromNumber(row["geschlecht"]),
            ))
        .toList();
  }

  Betreuer addBetreuer(String name, Geschlecht geschlecht,
      {bool force = false}) {
    final names = getAllBetreuer().map((e) => e.name);
    if (names.any((element) => element == name)) {
      if (!force) {
        throw Exception("schon vorhanden"); //TODO sinnvollere Exception
      }
    }

    _insert ??= _database.getPreparedPersistent("""
      insert into betreuer
        (name, geschlecht)
      values
        (?, ?)
      returning id
    """);

    final int id = _insert!.select([name, geschlecht.toNumber()]).first["id"];

    return Betreuer(id: id, name: name, geschlecht: geschlecht);
  }
}
