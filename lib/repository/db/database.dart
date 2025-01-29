import 'package:julog/repository/betreuer/repository.dart';
import 'package:julog/repository/db/migrations.dart';
import 'package:julog/repository/eintrag/repository.dart';
import 'package:julog/repository/identity/repository.dart';
import 'package:julog/repository/identity/signing_userids.dart';
import 'package:julog/repository/jugendliche/repository.dart';
import 'package:julog/repository/kategorien/repository.dart';
import 'package:julog/repository/signatures/repository.dart';
import 'package:julog/repository/util/global_settings.dart';
import 'package:sqlite3/sqlite3.dart';

class JulogDatabase {
  final String filename;
  late Database _database;
  final GlobalSettings globalSettings;

  late final SignatureRepository signatureRepository;
  late final SigningUseridsRepository signingUseridsRepository;
  late final KategorieRepository kategorieRepository;
  late final JugendlicherRepository jugendlicherRepository;
  late final IdentityRepository identityRepository;
  late final EintragRepository eintragRepository;
  late final BetreuerRepository betreuerRepository;

  JulogDatabase({
    required this.filename,
    required this.globalSettings,
  }) {
    _init();
    _dependencyBuild();
  }

  JulogDatabase.create({
    required this.filename,
    required String domain,
    required this.globalSettings,
  }) {
    _init();
    _setDomainSetting(domain);
    _dependencyBuild();
  }

  void _init() {
    _database = sqlite3.open(filename, mode: OpenMode.readWriteCreate);
    final installed = _isInstalled();
    if (installed && (!isCompatible)) {
      throw DatabaseIncompatibleException(version);
    }
    migrate(installed);
  }

  void _dependencyBuild() {
    betreuerRepository = BetreuerRepository(database: this);
    identityRepository = IdentityRepository(database: this);
    kategorieRepository = KategorieRepository(database: this);
    jugendlicherRepository = JugendlicherRepository(database: this);
    eintragRepository = EintragRepository(database: this);
    signingUseridsRepository = SigningUseridsRepository(
      database: this,
      prefs: globalSettings.sharedPreferences,
      identityRepository: identityRepository,
    );
    signatureRepository = SignatureRepository(
      database: this,
      useridsRepository: signingUseridsRepository,
      identityRepository: identityRepository,
    );
  }

  void dispose() {
    signatureRepository.dispose();
    signingUseridsRepository.dispose();
    eintragRepository.dispose();
    jugendlicherRepository.dispose();
    kategorieRepository.dispose();
    identityRepository.dispose();
    betreuerRepository.dispose();

    _database.dispose();
  }

  int? _version;
  int get version {
    return _version ??= _getVersion();
  }

  String? _domainSetting;
  String get domainSetting {
    return _domainSetting ??= _getDomainSetting();
  }

  bool get isCompatible {
    return version == 2; //May change in the future
  }

  int _getVersion() {
    final stmt = "PRAGMA user_version;";
    final result = _database.select(stmt);
    final version = result.first.columnAt(0);
    if (version is int) {
      return version;
    } else {
      return int.parse(version);
    }
  }

  String _getDomainSetting() {
    final stmt = "select value from info where field = ?";
    final result = _database.select(stmt, ['domainName']);
    return result.first.columnAt(0);
  }

  void migrate(bool installed) {
    final migrations = DatabaseMigrations.getMigrations(
      currentVersion: installed ? version : 0,
    );

    for (final migration in migrations) {
      _database.execute(migration);
    }
  }

  bool _isInstalled() {
    try {
      final applicationId =
          _database.select("pragma application_id;").first.columnAt(0);
      final int appId;
      if (applicationId is int) {
        appId = applicationId;
      } else {
        appId = int.parse(applicationId);
      }
      return appId == 448493213;
    } catch (e) {
      return false;
    }
  }

  static bool validDomain(String domain) {
    final RegExp regex =
        RegExp(r'^(([A-Za-z0-9-]{1,63}\.)+)[A-Za-z0-9-]{2,63}$');
    return regex.hasMatch(domain);
  }

  void _setDomainSetting(String domain) {
    if (!validDomain(domain)) {
      //TODO better exception handling
      throw Exception("Domain konnte nicht validiert werden");
    }

    final stmt = "insert into info (field, value) values (?, ?)";
    _database.execute(stmt, ["domainName", domain]);
  }

  PreparedStatement getPreparedPersistent(String sql) {
    return _database.prepare(sql, persistent: true);
  }
}

class DatabaseIncompatibleException implements Exception {
  final int dbVersion;
  DatabaseIncompatibleException(this.dbVersion);
  @override
  String toString() => "DatabaseIncompatibleException: version $dbVersion";
}
