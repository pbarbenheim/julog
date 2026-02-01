import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../../provider/secure_storage/secure_storage.dart';
import '../model/identity/identity.dart';
import '../repository_base.dart';
import 'exception.dart';

part 'repository.g.dart';

typedef IdentityCreateData = ({
  String name,
  String function,
  String mail,
  String password,
});

class IdentityRepository
    extends JulogRepository<Identity, IdentityApiModel, IdentityCreateData> {
  final Jldb _jldb;
  final FlutterSecureStorage _secureStorage;

  IdentityRepository._({
    required Jldb jldb,
    required FlutterSecureStorage secureStorage,
  }) : _jldb = jldb,
       _secureStorage = secureStorage;

  AsyncResultOptional<OpenIdentity> openIdentity(String id, String password) =>
      Result.safeNullableAsync(() async {
        final recordResult = await _jldb.getIdentity(UUID.fromString(id));
        final record = recordResult.unwrap();
        if (record is None<IdentityApiModel>) {
          return null;
        }
        final privateKeyString = await _secureStorage.read(
          key: 'private_key_${record.unwrap().id.toString()}',
        );
        if (privateKeyString == null) {
          throw PrivateKeyNotFoundException();
        }
        final privateKey = await compute(
          (message) => crypto.PrivateKey.fromString(
            message.privateKeyString,
            message.password,
          ),
          (privateKeyString: privateKeyString, password: password),
        );

        return OpenIdentity(id: id, privateKey: privateKey);
      });

  @protected
  @override
  AsyncResult<Identity> createInJldb(
    IdentityCreateData data,
  ) => Result.safeAsync(() async {
    final newId = UUID.generate();
    final keypair = await compute(
      (message) => crypto.KeyPair.generate(
        identity: crypto.Identity(message.name, message.function, message.mail),
        password: message.password,
      ),
      data,
    );

    await _secureStorage.write(
      key: 'private_key_${newId.toString()}',
      value: keypair.privateKey.toString(),
    );

    return _jldb
        .createIdentity(
          IdentityApiModel(id: newId, publicKey: keypair.publicKey.toString()),
        )
        .map((savedRecord) {
          final identity = Identity.fromApiModel(savedRecord, true);
          return identity;
        })
        .unwrap();
  });

  @protected
  @override
  AsyncResult<List<IdentityApiModel>> fetchAllFromJldb() {
    return _jldb.getAllIdentities();
  }

  @protected
  @override
  Future<Identity> fromJldbRecord(IdentityApiModel record) async {
    final id = record.id.toString();
    final privateKey = await _secureStorage.read(key: 'private_key_$id');
    final bool isLocal;
    if (privateKey != null) {
      isLocal = true;
    } else {
      isLocal = false;
    }
    return Identity.fromApiModel(record, isLocal);
  }

  @protected
  @override
  String getId(Identity item) => item.id;
}

@Riverpod(keepAlive: true)
IdentityRepository identityRepository(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return IdentityRepository._(jldb: jldb.jldb, secureStorage: secureStorage);
}
