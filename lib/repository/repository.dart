import 'package:dart_pg/dart_pg.dart';
import 'package:sqlite3/sqlite3.dart';

class Repository {
  final Database _database;
  final String filename;
  late final String domainSetting;
  late final String dbVersion;

  PreparedStatement? _getAllIdentities;
  PreparedStatement? _getOneIdentity;

  Repository._(this.filename, String domainName)
      : _database = sqlite3.open(filename) {
    _init(domainName: domainName);
  }

  factory Repository(String filename) {
    return Repository._(filename, "dienstbuch.example.org");
  }

  factory Repository.create(String filename, String domainName) {
    return Repository._(filename, domainName);
  }

  void _init({String? domainName}) {
    if (!_isInstalled()) {
      _database.execute(_getInitScript(domainName ?? "dienstbuch.example.org"));
    }
    final statement = _database.prepare("select * from info");
    final result = statement.select();
    for (var row in result) {
      final field = row["field"] as String;
      final value = row["value"] as String;
      if (field == "version") {
        dbVersion = value;
        continue;
      }
      if (field == "domainName") {
        domainSetting = value;
        continue;
      }
    }
  }

  String _getInitScript(String domain) => '''
      create table if not exists info (
        field text primary key,
        value text not null
      );

      create table if not exists identites (
        userid text primary key,
        public_key text,
        trusting integer not null default 1
      );

      create table if not exists kategorien (
        id integer primary key autoincrement,
        name text not null
      );

      create table if not exists eintrag (
        id integer primary key autoincrement,
        beginn integer not null,
        ende integer not null,
        kategorie_id integer references kategorien (id),
        thema text,
        ort text,
        raum text,
        dienstverlauf text,
        besonderheiten text
      );

      create table if not exists eintrag_verbindungen (
        eintrag_a integer references eintrag (id),
        eintrag_b integer references eintrag (id),
        primary key (eintrag_a, eintrag_b)
      );

      create table if not exists betreuer (
        id integer primary key autoincrement,
        name text not null
      );

      create table if not exists eintrag_zu_betreuer (
        eintrag_id integer references eintrag (id),
        betreuer_id integer references betreuer (id),
        primary key (eintrag_id, betreuer_id)
      );

      create table if not exists signatures (
        eintrag_id integer references eintrag (id),
        userid text references identities (userid),
        signed_at integer not null,
        sign_version integer not null default 1,
        primary key (eintrag_id, userid),
        unique (eintrag_id, signed_at)
      );

      create table if not exists jugendliche (
        id integer primary key autoincrement,
        name text not null,
        passnummer text,
        geburtstag integer not null,
        eintrittsdatum integer not null,
        austrittsdatum integer,
        austrittsgrund text
      );

      create table if not exists eintrag_zu_jugendliche (
        eintrag_id integer references eintrag (id),
        jugendliche_id integer references jugendliche (id),
        anmerkung text
      );

      insert into info (field, value) values
      ('version', '1'),
      ('domainName', '$domain');

      pragma application_id = 448493213;
    ''';

  bool _isInstalled() {
    bool result = false;
    final statement = _database.prepare("select * from pragma_application_id");
    try {
      final applicationId = statement.select().first.values.first;
      if (applicationId == 448493213) {
        result = true;
      }
    } finally {
      statement.dispose();
    }
    return result;
  }

  void dispose() {
    _database.dispose();
  }

  List<Identity> getIdentities() {
    _getAllIdentities ??= _database
        .prepare("select userid, trusting from identities", persistent: true);

    final result = _getAllIdentities!.select();
    List<Identity> ids = [];
    for (var row in result) {
      ids.add(Identity._(
          userId: row["userid"],
          trusting: row["trusting"],
          database: _database));
    }
    return ids;
  }

  Identity getIdentity(String userId) {
    _getOneIdentity ??= _database.prepare(
        "select userid, public_key, trusting from identities where userid = ?",
        persistent: true);

    final result = _getOneIdentity!.select([userId]).first;
    return Identity._(
        userId: result["userid"],
        trusting: result["trusting"],
        key: result["public_key"],
        database: _database);
  }
}

class Identity {
  final String userId;
  PublicKey? key;
  final int trusting;
  final Database _database;

  Identity._({
    required this.userId,
    this.key,
    required this.trusting,
    required Database database,
  }) : _database = database;

  PublicKey loadPublicKey() {
    final armored = _database
        .select("select public_key from identities where userid = ?", [userId])
        .first
        .values
        .first as String;
    key = PublicKey.fromArmored(armored);
    return key!;
  }
}
