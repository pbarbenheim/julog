import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/kategorien/kategorie.dart';
import 'package:sqlite3/sqlite3.dart';

class KategorieRepository {
  final JulogDatabase _database;

  PreparedStatement? _getAll;
  PreparedStatement? _insert;

  KategorieRepository({required JulogDatabase database}) : _database = database;

  void dispose() {
    _getAll?.dispose();
    _insert?.dispose();
  }

  List<Kategorie> getAllKategorien() {
    _getAll ??=
        _database.getPreparedPersistent("select id, name from kategorien");

    return _getAll!
        .select()
        .map((row) => Kategorie(id: row["id"], name: row["name"]))
        .toList();
  }

  Kategorie addKategorie(String name, {bool force = false}) {
    final names = getAllKategorien().map((e) => e.name);

    if (names.contains(name) && !force) {
      throw Exception("gibt es schon"); //TODO sinnvollere Exception
    }

    _insert ??= _database.getPreparedPersistent("""
      insert into kategorien
        (name)
      values
        (?)
      returning id
    """);

    final id = _insert!.select([name]).first["id"];

    return Kategorie(id: id, name: name);
  }
}
