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
  PreparedStatement? _getAllEintrage;
  PreparedStatement? _getOneEintrag;
  PreparedStatement? _getSignaturesFromEintrag;
  PreparedStatement? _getJugendlicheFromEintrag;
  PreparedStatement? _getBetreuerFromEintrag;

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
        signature text not null,
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
    _getAllEintrage?.dispose();
    _getOneEintrag?.dispose();
    _getSignaturesFromEintrag?.dispose();
    _getJugendlicheFromEintrag?.dispose();
    _getBetreuerFromEintrag?.dispose();
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
        key: PublicKey.fromArmored(result["public_key"]),
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

  Future<(String, DateTime)> _signWithIdentity(
      String message, String userId, String password) async {
    final pref = prefs;

    final armored = pref.getString(_prefsPattern + _userIdCodec.encode(userId));
    if (armored == null) {
      throw Exception("SigningIdentity not found");
    }

    final privateKey = await OpenPGP.decryptPrivateKey(armored, password);
    final DateTime date = DateTime.now();
    final signature =
        await OpenPGP.signDetached(message, [privateKey], date: date);
    return (signature.armor(), date);
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

    final userId =
        [name, if (comment != null) "($comment)", "<$email>"].join(" ");
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

  Map<int, (DateTime, String)> getAllEintrage() {
    _getAllEintrage ??= _database.prepare('''
      select 
        e.id as id, 
        e.beginn as beginn,
        k.name as kat
      from
        eintrag as e,
        kategorien as k
      where
        e.kategorie_id = k.id 
    ''', persistent: true);

    final results = _getAllEintrage!
        .select()
        .map((element) => MapEntry<int, (DateTime, String)>(
              element["id"],
              (
                DateTime.fromMillisecondsSinceEpoch(element["beginn"]),
                element["kat"],
              ),
            ));
    return Map.fromEntries(results);
  }

  Eintrag getEintrag(int id) {
    _getOneEintrag ??= _database.prepare('''
      select
        e.id as id,
        e.beginn as beginn,
        e.ende as ende,
        k.id as kat_id,
        k.name as kat_name,
        e.thema as thema,
        e.ort as ort,
        e.raum as raum,
        e.dienstverlauf as dienstverlauf,
        e.besonderheiten as besonderheiten
      from eintrag as e, kategorien as k
      where e.kategorie_id = k.id and e.id = ?
    ''', persistent: true);

    _getSignaturesFromEintrag ??= _database.prepare('''
      select *
      from signatures
      where eintrag_id = ?
    ''', persistent: true);

    _getJugendlicheFromEintrag ??= _database.prepare('''
      select j.id as id, j.name as name, je.anmerkung as anmerkung
      from jugendliche as j, eintrag_zu_jugendliche as je
      where j.id = je.jugendliche_id and je.eintrag_id = ?
    ''', persistent: true);

    _getBetreuerFromEintrag ??= _database.prepare('''
      select b.id as id, b.name as name, b.geschlecht as geschlecht
      from betreuer as b, eintrag_zu_betreuer as be
      where be.betreuer_id = b.id and be.eintrag_id = ?
    ''', persistent: true);

    final List<(int, String, String?)> jugendliche = _getJugendlicheFromEintrag!
        .select([id])
        .map<(int, String, String?)>(
            (row) => (row["id"], row["name"], row["anmerkung"]))
        .toList();

    final List<Betreuer> betreuer = _getBetreuerFromEintrag!
        .select([id])
        .map<Betreuer>(
          (row) => Betreuer(
              id: row["id"],
              name: row["name"],
              geschlecht: Geschlecht.fromNumber(row["geschlecht"])),
        )
        .toList();

    final List<Signatur> signaturen = _getSignaturesFromEintrag!
        .select([id])
        .map((row) => Signatur._(
              eintragId: id,
              userId: row["userid"],
              signVersion: row["sign_version"],
              signedAt: DateTime.fromMillisecondsSinceEpoch(row["signed_at"]),
              signature: row["signature"],
              repo: this,
            ))
        .toList();

    final row = _getOneEintrag!.select([id]).first;

    final Kategorie kategorie =
        Kategorie(id: row["kat_id"], name: row["kat_name"]);

    return Eintrag(
      id: id,
      beginn: DateTime.fromMillisecondsSinceEpoch(row["beginn"]),
      ende: DateTime.fromMillisecondsSinceEpoch(row["ende"]),
      kategorie: kategorie,
      thema: row["thema"],
      ort: row["ort"],
      raum: row["raum"],
      dienstverlauf: row["dienstverlauf"],
      besonderheiten: row["besonderheiten"],
      signaturen: signaturen,
      betreuer: betreuer,
      jugendliche: jugendliche,
      repo: this,
    );
  }

  String _getValueMatrix(int row, int columns) {
    List<String> res = [];
    for (var i = 0; i < row; i++) {
      List<String> werte = [];
      for (var j = 0; j < columns; j++) {
        werte.add("?");
      }
      res.add("(${werte.join(", ")})");
    }
    return res.join(", ");
  }

  int addEintrag({
    required DateTime beginn,
    required DateTime ende,
    int? kategorieId,
    String? thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    List<int> betreuerIds = const [],
    List<(int, String?)> jugendlicheIds = const [],
  }) {
    final id = _database.select('''
      insert into eintrag
        (beginn, ende, kategorie_id, thema, ort, raum, dienstverlauf, besonderheiten)
      values 
        (?, ?, ?, ?, ?, ?, ?, ?)
      returning id
    ''', [
      beginn.millisecondsSinceEpoch,
      ende.millisecondsSinceEpoch,
      kategorieId,
      thema,
      ort,
      raum,
      dienstverlauf,
      besonderheiten,
    ]).first["id"];

    final List<int> betreuerOpts = betreuerIds
        .map<List<int>>((e) => [id, e])
        .expand((element) => element)
        .toList();

    _database.execute('''
      insert into eintrag_zu_betreuer 
        (eintrag_id, betreuer_id) 
      values ${_getValueMatrix(betreuerIds.length, 2)}
    ''', betreuerOpts);

    List<dynamic> jugendlicheOpts = jugendlicheIds
        .map<List<dynamic>>((e) => [id, e.$1, e.$2])
        .expand((element) => element)
        .toList();

    _database.execute('''
      insert into eintrag_zu_jugendliche
        (eintrag_id, jugendliche_id, anmerkung)
      values ${_getValueMatrix(jugendlicheIds.length, 3)}
    ''', jugendlicheOpts);

    return id;
  }
}

class Eintrag {
  final int id;
  final DateTime beginn;
  final DateTime ende;
  final Kategorie? kategorie;
  final String? thema;
  final String? ort;
  final String? raum;
  final String? dienstverlauf;
  final String? besonderheiten;
  final List<Signatur> signaturen;
  final List<Betreuer> betreuer;
  final List<(int, String, String?)> jugendliche;
  final Repository _repo;

  Eintrag({
    required this.id,
    required this.beginn,
    required this.ende,
    required this.kategorie,
    required this.thema,
    required this.ort,
    required this.raum,
    required this.dienstverlauf,
    required this.besonderheiten,
    required this.signaturen,
    required this.betreuer,
    required this.jugendliche,
    required Repository repo,
  }) : _repo = repo;

  Future<Signatur> sign(String userId, String password) async {
    final Signatur signatur = await _sign_v1(userId, password, id, _repo);
    signaturen.add(signatur);
    return signatur;
  }

  // ignore: constant_identifier_names
  static const String _signQuery_v1 = '''
        select
          json_object(
            'id', e.id,
            'beginn', e.beginn,
            'ende', e.ende,
            'kategorie', json_object('id', k.id, 'name', k.name),
            'thema', e.thema,
            'ort', e.ort,
            'raum', e.raum,
            'dienstverlauf', e.dienstverlauf,
            'besonderheiten', e.besonderheiten,
            'betreuer', json(json_betreuer.betreu),
            'jugendliche', json(json_jugend.jugend),
            'signatures', json(json_signatures.sign)
          ) as json
        from 
          (
            select
              json_group_array(json_object('id', j.id, 'name', j.name, 'anmerkung', je.anmerkung)) as jugend
            from jugendliche as j, eintrag_zu_jugendliche as je
            where j.id = je.jugendliche_id and je.eintrag_id = ?
          ) as json_jugend,
          (
            select
              json_group_array(json_object('id', b.id, 'name', b.name)) as betreu
            from betreuer as b, eintrag_zu_betreuer as be
            where b.id = be.betreuer_id and be.eintrag_id = ?
          ) as json_betreuer,
          (
            select
              json_group_array(json_object(
                'userid', s.userid,
                'signature', s.signature,
                'signed_at', s.signed_at,
                'sign_version', s.sign_version
              )) as sign
            from signatures as s
            where s.eintrag_id = ? and s.signed_at < ?
          ) as json_signatures,
          eintrag as e,
          kategorien as k
        where e.kategorie_id = k.id
          and e.id = ?
      ''';

  // ignore: non_constant_identifier_names
  static Future<Signatur> _sign_v1(
      String userId, String password, int eintragId, Repository repo) async {
    final opts = [
      eintragId,
      eintragId,
      eintragId,
      DateTime.now().millisecondsSinceEpoch,
      eintragId
    ];

    final String eintrag =
        repo._database.select(_signQuery_v1, opts).first["json"];

    final (signature, date) =
        await repo._signWithIdentity(eintrag, userId, password);

    repo._database.execute('''
      insert into signatures
        (eintrag_id, userid, signature, signed_at, sign_version)
      values
        (?, ?, ?, ?, ?)
    ''', [eintragId, userId, signature, date.millisecondsSinceEpoch, 1]);

    return Signatur._(
      userId: userId,
      signature: signature,
      signedAt: date,
      signVersion: 1,
      eintragId: eintragId,
      repo: repo,
    );
  }
}

class Signatur {
  final String userId;
  final String signature;
  final DateTime signedAt;
  final int signVersion;
  final int eintragId;
  final Repository _repo;

  Signatur._({
    required this.userId,
    required this.signature,
    required this.signedAt,
    required this.signVersion,
    required this.eintragId,
    required Repository repo,
  }) : _repo = repo;

  Future<bool> verify() async {
    switch (signVersion) {
      case 1:
        return await _verify_v1(userId, eintragId, signedAt, signature, _repo);
      default:
        return false;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<bool> _verify_v1(
    String userId,
    int eintragId,
    DateTime signedAt,
    String signature,
    Repository repo,
  ) async {
    final opts = [
      eintragId,
      eintragId,
      eintragId,
      signedAt.millisecondsSinceEpoch,
      eintragId,
    ];
    final String eintrag =
        repo._database.select(Eintrag._signQuery_v1, opts).first["json"];

    final PublicKey publicKey = repo.getIdentity(userId).loadPublicKey();

    try {
      final msg = await OpenPGP.verifyDetached(
        eintrag,
        signature,
        [publicKey],
        date: signedAt,
      );
      for (var verification in msg.verifications) {
        if (!verification.verified) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
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
