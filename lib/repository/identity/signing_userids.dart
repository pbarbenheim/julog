import 'dart:convert';

import 'package:dart_pg/dart_pg.dart';
import 'package:flutter/foundation.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/identity/identity.dart';
import 'package:julog/repository/identity/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:julog/repository/util/util.dart';

class SigningUseridsRepository {
  final JulogDatabase _database;
  final SharedPreferencesWithCache _prefs;
  final IdentityRepository _identityRepository;
  static const String _prefsPattern = "userid_";
  static final Codec<String, String> _userIdCodec = utf8.fuse(base64Url);

  SigningUseridsRepository({
    required JulogDatabase database,
    required SharedPreferencesWithCache prefs,
    required IdentityRepository identityRepository,
  })  : _database = database,
        _prefs = prefs,
        _identityRepository = identityRepository;

  void dispose() {
    // NOOP because there is no db query
  }

  List<Identity> getSigningUserIds() {
    return _prefs.keys
        .where((e) => e.startsWith(_prefsPattern))
        .map((e) => e.substring(_prefsPattern.length))
        .map((e) => _userIdCodec.decode(e))
        .map((e) => Identity(userId: e))
        .toList();
  }

  Future<Identity> addSigningIdentity(
    String password,
    String name, {
    String? comment,
    bool force = false,
  }) async {
    final identities = getSigningUserIds();

    final emails = identities.map((e) => Util.userIdToComponents(e.userId).$3);
    final emailBase = comment != null ? "$name $comment" : name;
    final email =
        "${emailBase.split(" ").map((e) => e.toLowerCase()).join(".")}@${_database.domainSetting}";

    if (emails.contains(email)) {
      if (!force) {
        throw Exception(); //TODO change to more useful exception
      }
    }

    PrivateKey genPrivateKey((String userId, String password) message) {
      return PrivateKey.generate([message.$1], message.$2,
          type: KeyType.rsa, rsaKeySize: RSAKeySize.ultraHigh);
    }

    final userId =
        [name, if (comment != null) "($comment)", "<$email>"].join(" ");
    final privateKey = await compute(genPrivateKey, (userId, password));

    final publicKey = PublicKey(privateKey.publicKey.packetList);
    final privateArmored = privateKey.armor();

    await _prefs.setString(
        _prefsPattern + _userIdCodec.encode(userId), privateArmored);

    final id = Identity(userId: userId, key: publicKey);
    _identityRepository.insertIdentity(id);
    return id;
  }

  List<Identity> getSigningUserIdsNotInFile() {
    final signings = getSigningUserIds();

    final ids = _identityRepository.getIdentities();

    return signings.where((s) => ids.any((i) => i.userId == s.userId)).toList();
  }

  SigningIdentity getSigningIdentity(String userId) {
    final key = _prefsPattern + _userIdCodec.encode(userId);
    final armored = _prefs.getString(key);
    if (armored == null) {
      throw Exception(); //TODO more useful exception
    }
    return SigningIdentity(
        userId: userId, privateKey: PrivateKey.fromArmored(armored));
  }

  void importSigningUserIdsToFile(List<String> userIds) {
    for (var userId in userIds) {
      final private = getSigningIdentity(userId).privateKey;
      _identityRepository.insertIdentity(Identity(
        userId: userId,
        key: PublicKey(private.publicKey.packetList),
      ));
    }
  }
}
