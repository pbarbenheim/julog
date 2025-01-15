import 'package:julog/repository/db/migrations.dart';
import 'package:sqlite3/sqlite3.dart';

class JulogDatabase {
  final String filename;
  late Database _database;

  JulogDatabase({required this.filename}) {
    init();
  }

  JulogDatabase.create({required this.filename, required String domain}) {
    init();
    _setDomainSetting(domain);
  }

  void init() {
    _database = sqlite3.open(filename, mode: OpenMode.readWriteCreate);
    final installed = _isInstalled();
    if (installed && (!isCompatible)) {
      throw DatabaseIncompatibleException(version);
    }
    migrate(installed);
  }

  void dispose() {
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

  void _setDomainSetting(String domain) {
    //TODO maybe check domain on content ?

    final stmt = "insert into info (field, value) values (?, ?)";
    _database.execute(stmt, ["domainName", domain]);
  }
}

class DatabaseIncompatibleException implements Exception {
  final int dbVersion;
  DatabaseIncompatibleException(this.dbVersion);
  @override
  String toString() => "DatabaseIncompatibleException: version $dbVersion";
}
