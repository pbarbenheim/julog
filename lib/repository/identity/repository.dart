import 'package:dart_pg/dart_pg.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/identity/identity.dart';
import 'package:sqlite3/sqlite3.dart';

class IdentityRepository {
  PreparedStatement? _getAllIdentities;
  PreparedStatement? _getIdentity;
  PreparedStatement? _insert;

  final JulogDatabase _database;

  IdentityRepository({required JulogDatabase database}) : _database = database;

  void dispose() {
    _getAllIdentities?.dispose();
    _getIdentity?.dispose();
    _insert?.dispose();
  }

  List<Identity> getIdentities() {
    _getAllIdentities ??=
        _database.getPreparedPersistent("select userid from identities");
    final result = _getAllIdentities!.select();
    return result
        .map(
          (e) => Identity(userId: e["userid"]),
        )
        .toList();
  }

  Identity getIdentity(String userId) {
    _getIdentity ??= _database.getPreparedPersistent(
      "select public_key from identities where userid = ?",
    );

    final result = _getIdentity!.select([userId]);
    return Identity(
      userId: userId,
      key: PublicKey.fromArmored(result.first["public_key"]),
    );
  }

  void insertIdentity(Identity identity) {
    _insert ??= _database.getPreparedPersistent(
        "insert into identities (userid, public_key) values (?, ?)");
    _insert!.execute([identity.userId, identity.key?.armor()]);
  }
}
