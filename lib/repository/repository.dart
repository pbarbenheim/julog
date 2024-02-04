import 'dart:convert';

import 'package:dart_pg/dart_pg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  final Database _database;
  final String filename;
  late final String domainSetting;
  late final String dbVersion;
  static const String _prefsPattern = "_userid_";
  static const String _lastOpenFileKey = "app_last_open_file";
  static final Codec<String, String> _userIdCodec = utf8.fuse(base64Url);
  final SharedPreferences prefs;

  PreparedStatement? _getAllIdentities;
  PreparedStatement? _getOneIdentity;
  PreparedStatement? _getAllBetreuer;
  PreparedStatement? _getAllJugendliche;
  PreparedStatement? _getOneJugendliche;
  PreparedStatement? _getAllKategorien;

  Repository._(this.prefs, this.filename, String domainName)
      : _database = sqlite3.open(filename) {
    _init(domainName: domainName);
    _initPrefs();
  }

  factory Repository._default(SharedPreferences prefs, String filename) {
    return Repository._(prefs, filename, "dienstbuch.example.org");
  }

  factory Repository._create(
      SharedPreferences prefs, String filename, String domainName) {
    return Repository._(prefs, filename, domainName);
  }

  void _initPrefs() async {
    prefs.setString(_lastOpenFileKey, _userIdCodec.encode(filename));
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

      create table if not exists identities (
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
        name text not null,
        geschlecht integer not null
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
        austrittsgrund text,
        geschlecht integer not null
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
    _getAllIdentities?.dispose();
    _getOneIdentity?.dispose();
    _getAllBetreuer?.dispose();
    _getAllJugendliche?.dispose();
    _getOneJugendliche?.dispose();
    _getAllKategorien?.dispose();
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

  List<String> getSigningUserIds() {
    final pref = prefs;

    return pref
        .getKeys()
        .where((element) => element.startsWith(_prefsPattern))
        .map((e) => e.substring(_prefsPattern.length))
        .map((e) => _userIdCodec.decode(e))
        .toList();
  }

  Future<String> signWithIdentity(
      String message, String userId, String password) async {
    final pref = prefs;

    final armored = pref.getString(_prefsPattern + _userIdCodec.encode(userId));
    if (armored == null) {
      throw Exception("SigningIdentity not found");
    }

    final privateKey = await OpenPGP.decryptPrivateKey(armored, password);
    final signature = await OpenPGP.signDetached(message, [privateKey]);
    return signature.armor();
  }

  Future<Identity> addSigningIdentity(
      String password, String name, String? comment) async {
    final identities = getIdentities();
    bool firstSigning = identities.isEmpty;
    final emails =
        identities.map((e) => userIdToComponents(e.userId).$3).toList();
    final emailBase = comment != null ? "$name $comment" : name;
    final email =
        "${emailBase.split(" ").map((e) => e.toLowerCase()).join(".")}@$domainSetting";

    final index = emails.indexOf(email);
    if (index != -1) {
      identities[index].setTrusting(0);
      throw Exception(
          "UserId bereits vorhanden. Keine neue Signatur erstellt. Die andere Signatur wurde auf nicht vertrauen gesetzt.");
    }

    final userId = [name, if (comment != null) "($comment)", email].join(" ");
    final privateKey = await compute(
        (message) async => await OpenPGP.generateKey(
              [userId],
              password,
              type: KeyGenerationType.rsa,
              rsaKeySize: RSAKeySize.s4096,
            ),
        null);

    final publicArmored = privateKey.toPublic.armor();
    final privateArmored = privateKey.armor();

    final pref = prefs;
    final result = await pref.setString(
        _prefsPattern + _userIdCodec.encode(userId), privateArmored);
    if (!result) {
      throw Exception(
          "Die Signatur konnte nicht abgespeichert werden. Es wurde keine Signatur erstellt");
    }

    final trusting = firstSigning ? 3 : 1;

    _database.execute('''
      insert into identities 
        (userid, public_key, trusting)
      values
        (?, ?, ?)
    ''', [userId, publicArmored, trusting]);

    return Identity._(
      userId: userId,
      trusting: trusting,
      database: _database,
      key: privateKey.toPublic,
    );
  }

  static (String, String, String) userIdToComponents(String userId) {
    var result = ("", "", "");
    var cstart = userId.indexOf("(");

    if (cstart == -1) {
      cstart = userId.indexOf("<");
    } else {
      final cend = userId.indexOf(")");
      result =
          (result.$1, userId.substring(cstart + 1, cend).trim(), result.$3);
    }
    final estart = userId.indexOf("<");
    result = (
      userId.substring(0, cstart).trim(),
      result.$2,
      userId.substring(estart + 1, userId.length - 2)
    );

    return result;
  }

  static String? getLastOpenFile(SharedPreferences prefs) {
    final value = prefs.getString(_lastOpenFileKey);
    if (value == null) {
      return null;
    }
    return _userIdCodec.decode(value);
  }

  List<Betreuer> getAllBetreuer() {
    _getAllBetreuer ??=
        _database.prepare("select * from betreuer", persistent: true);

    final result = _getAllBetreuer!.select();
    final List<Betreuer> betreuer = [];
    for (var row in result) {
      betreuer.add(Betreuer(
        id: row["id"],
        name: row["name"],
        geschlecht: Geschlecht.fromNumber(row["geschlecht"]),
      ));
    }
    return betreuer;
  }

  Betreuer addBetreuer(String name, Geschlecht geschlecht) {
    final names = getAllBetreuer().map((e) => e.name);
    if (names.any((element) => element == name)) {
      throw Exception("Der Name ist bereits vorhanden");
    }
    final result = _database.select('''
      insert into betreuer 
        (name, geschlecht)
      values
        (?, ?)
      returning *
    ''', [name, geschlecht.toNumber()]).first;

    return Betreuer(
      id: result["id"],
      name: result["name"],
      geschlecht: Geschlecht.fromNumber(result["geschlecht"]),
    );
  }

  static bool checkString(String s) {
    return !s.contains(RegExp(r'[\.\\\/\,\(\)\[\]\{\}\<\>\|]'));
  }

  Map<int, String> getAllJugendliche() {
    _getAllJugendliche ??= _database.prepare('''
      select id, name from jugendliche
    ''', persistent: true);

    final result = _getAllJugendliche!.select().map<MapEntry<int, String>>(
        (element) => MapEntry(element["id"], element["name"]));
    return Map.fromEntries(result);
  }

  Jugendlicher getJugendlicher(int id) {
    _getOneJugendliche ??= _database.prepare('''
      select *
      from jugendliche
      where id = ?
    ''', persistent: true);

    final result = _getOneJugendliche!.select([id]).first;
    final austrittsdatum = result["austrittsdatum"];
    return Jugendlicher(
      id: id,
      name: result["name"],
      passnummer: result["passnummer"],
      geburtstag: DateTime.fromMillisecondsSinceEpoch(result["geburtstag"]),
      eintrittsdatum:
          DateTime.fromMillisecondsSinceEpoch(result["eintrittsdatum"]),
      austrittsdatum: austrittsdatum != null
          ? DateTime.fromMillisecondsSinceEpoch(austrittsdatum)
          : null,
      austrittsgrund: result["austrittsgrund"],
      geschlecht: Geschlecht.fromNumber(result["geschlecht"]),
    );
  }

  int addJugendlicher({
    required String name,
    required DateTime geburtstag,
    required DateTime eintrittsdatum,
    required Geschlecht geschlecht,
    String? passnummer,
  }) {
    final result = _database.select('''
      insert into jugendliche
        (name, passnummer, geburtstag, eintrittsdatum, geschlecht)
      values
        (?, ?, ?, ?, ?)
      returning id
    ''', [
      name,
      passnummer,
      geburtstag.millisecondsSinceEpoch,
      eintrittsdatum.millisecondsSinceEpoch,
      geschlecht.toNumber(),
    ]).first;
    return result["id"];
  }

  List<Kategorie> getAllKategorien() {
    _getAllKategorien ??=
        _database.prepare("select * from kategorien", persistent: true);

    return _getAllKategorien!
        .select()
        .map((row) => Kategorie(id: row["id"], name: row["name"]))
        .toList();
  }

  Kategorie addKategorie(String name) {
    final names = getAllKategorien().map((e) => e.name);

    if (names.contains(name)) {
      throw Exception("Name bereits vorhanden");
    }

    final result = _database.select(
        "insert into kategorien (name) values (?) returning *", [name]).first;
    return Kategorie(id: result["id"], name: result["name"]);
  }
}

class Kategorie {
  final int id;
  final String name;

  const Kategorie({required this.id, required this.name});
}

class Jugendlicher {
  final int id;
  final String name;
  final String? passnummer;
  final DateTime geburtstag;
  final DateTime eintrittsdatum;
  final DateTime? austrittsdatum;
  final String? austrittsgrund;
  final Geschlecht geschlecht;

  Jugendlicher({
    required this.id,
    required this.name,
    required this.passnummer,
    required this.geburtstag,
    required this.eintrittsdatum,
    required this.austrittsdatum,
    required this.austrittsgrund,
    required this.geschlecht,
  });
}

class Betreuer {
  final int id;
  final String name;
  final Geschlecht geschlecht;

  Betreuer({required this.id, required this.name, required this.geschlecht});
}

enum Geschlecht {
  maennlich(0, "Männlich"),
  weiblich(1, "Weiblich"),
  divers(2, "Divers");

  final int id;
  final String text;

  const Geschlecht(this.id, this.text);

  int toNumber() {
    return id;
  }

  @override
  String toString() {
    return text;
  }

  static Geschlecht fromNumber(int number) {
    switch (number) {
      case 0:
        return Geschlecht.maennlich;
      case 1:
        return Geschlecht.weiblich;
      case 2:
        return Geschlecht.divers;
      default:
        throw Exception("Unzulässige Zahl");
    }
  }
}

class Identity {
  final String userId;
  PublicKey? key;
  int _trusting;
  final Database _database;

  Identity._({
    required this.userId,
    this.key,
    required int trusting,
    required Database database,
  })  : _database = database,
        _trusting = trusting;

  int get trusting => _trusting;

  PublicKey loadPublicKey() {
    final armored = _database
        .select("select public_key from identities where userid = ?", [userId])
        .first
        .values
        .first as String;
    key = PublicKey.fromArmored(armored);
    return key!;
  }

  void setTrusting(int newTrusting) {
    _database.execute("update identities set trusting = ? where userid = ?",
        [newTrusting, userId]);
    _trusting = newTrusting;
  }
}

class RepositoryNotifier extends Notifier<Repository?> {
  final String? _filename;
  RepositoryNotifier({String? filename}) : _filename = filename;

  @override
  Repository? build() {
    if (_filename != null) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return Repository._default(prefs, _filename);
    }
    return null;
  }

  bool get isSet => state != null;

  void dispose() {
    state?.dispose();
  }

  void openFile(String file) {
    final prefs = ref.watch(sharedPreferencesProvider);
    state = Repository._default(prefs, file);
  }

  void newFile(String file, String domain) {
    final prefs = ref.watch(sharedPreferencesProvider);
    state = Repository._create(prefs, file, domain);
  }
}

final repositoryProvider = NotifierProvider<RepositoryNotifier, Repository?>(
  () {
    return RepositoryNotifier();
  },
);

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());
