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
  late final SharedPreferences? prefs;
  static const String _prefsPattern = "_userid_";
  final Codec<String, String> _userIdCodec = utf8.fuse(base64Url);

  PreparedStatement? _getAllIdentities;
  PreparedStatement? _getOneIdentity;

  Repository._(this.filename, String domainName)
      : _database = sqlite3.open(filename) {
    _init(domainName: domainName);
    _initPrefs();
  }

  factory Repository._default(String filename) {
    return Repository._(filename, "dienstbuch.example.org");
  }

  factory Repository._create(String filename, String domainName) {
    return Repository._(filename, domainName);
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
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

  List<String> getSigningUserIds() {
    final pref = prefs!;

    return pref
        .getKeys()
        .where((element) => element.startsWith(_prefsPattern))
        .map((e) => e.substring(_prefsPattern.length))
        .map((e) => _userIdCodec.decode(e))
        .toList();
  }

  Future<String> signWithIdentity(
      String message, String userId, String password) async {
    final pref = prefs!;

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

    final pref = prefs!;
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
  @override
  Repository? build() {
    return null;
  }

  bool get isSet => state != null;

  void dispose() {
    state?.dispose();
  }

  openFile(String file) {
    state = Repository._default(file);
  }

  newFile(String file, domain) {
    state = Repository._create(file, "jf-dienstbuch-software.$domain");
  }
}

final repositoryProvider = NotifierProvider<RepositoryNotifier, Repository?>(
  () {
    return RepositoryNotifier();
  },
);
