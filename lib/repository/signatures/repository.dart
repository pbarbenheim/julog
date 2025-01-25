import 'package:dart_pg/dart_pg.dart';
import 'package:flutter/foundation.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/eintrag/eintrag.dart';
import 'package:julog/repository/identity/identity.dart';
import 'package:julog/repository/identity/repository.dart';
import 'package:julog/repository/identity/signing_userids.dart';
import 'package:julog/repository/signatures/signatur.dart';
import 'package:sqlite3/sqlite3.dart';

class SignatureRepository {
  final JulogDatabase _database;
  final SigningUseridsRepository _useridsRepository;
  final IdentityRepository _identityRepository;

  // ignore: non_constant_identifier_names
  PreparedStatement? _sign_v2_query;
  // ignore: non_constant_identifier_names
  PreparedStatement? _sign_v2_insert;

  SignatureRepository(
      {required JulogDatabase database,
      required SigningUseridsRepository useridsRepository,
      required IdentityRepository identityRepository})
      : _database = database,
        _useridsRepository = useridsRepository,
        _identityRepository = identityRepository;

  void dispose() {
    _sign_v2_insert?.dispose();
    _sign_v2_query?.dispose();
  }

  bool verifySignature(Signatur signatur) {
    switch (signatur.signVersion) {
      case 2:
        return _verify_v2(signatur);
      default:
        throw UnsupportedError(
            "Unsupported signing version"); //TODO change error handling
    }
  }

  // ignore: non_constant_identifier_names
  bool _verify_v2(Signatur signatur) {
    _v2_initQuery();

    final opts = [
      signatur.eintrag.id,
      signatur.eintrag.id,
      signatur.eintrag.id,
      signatur.signedAt.millisecondsSinceEpoch,
      signatur.eintrag.id,
    ];

    final String eintragJson = _sign_v2_query!.select(opts).first["json"];

    final publicKey =
        _identityRepository.getIdentity(signatur.identity.userId).key!;

    try {
      final msg = OpenPGP.verifyDetached(
        eintragJson,
        signatur.signature,
        [publicKey],
        signatur.signedAt,
      );
      for (var verification in msg) {
        if (!verification.isVerified) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> _signWithCompute(
    PrivateKey privateKey,
    String password,
    String json,
    DateTime now,
  ) async {
    String computeSign(
        (String pk, String password, String json, int now) message) {
      final privateKey = OpenPGP.decryptPrivateKey(message.$1, message.$2);
      return OpenPGP.signDetachedCleartext(
        message.$3,
        [privateKey],
        time: DateTime.fromMillisecondsSinceEpoch(message.$4),
      ).armor();
    }

    return compute(
      computeSign,
      (privateKey.armor(), password, json, now.millisecondsSinceEpoch),
    );
  }

  Future<Signatur> sign(
      EintragHeader eintrag, String userId, String password) async {
    final now = DateTime.now();
    final String eintragJson = _sign_v2(eintrag, userId, password, now);
    final identity = _useridsRepository.getSigningIdentity(userId);

    final signature =
        await _signWithCompute(identity.privateKey, password, eintragJson, now);

    _sign_v2_insert!.execute(
        [eintrag.id, userId, signature, now.millisecondsSinceEpoch, 2]);

    final signatur = Signatur(
      identity: Identity(userId: userId),
      signature: signature,
      signedAt: now,
      signVersion: 2,
      eintrag: eintrag,
    );
    return signatur;
  }

  // ignore: non_constant_identifier_names
  void _v2_initQuery() {
    _sign_v2_query ??= _database.getPreparedPersistent("""
      select 
        json_object(
          'id', e.id,
          'beginn', e.beginn,
          'ende', e.ende,
          'kategorie', json_object(
            'id', k.id,
            'name', k.name
          ),
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
              json_group_array(
                json_object(
                  'id', j.id, 
                  'name', j.name, 
                  'anwesenheit', je.anwesenheit
                )
              ) as jugend
            from 
              jugendlicher as j, 
              eintrag_zu_jugendlicher as je
            where j.id = je.jugendlicher_id 
              and je.eintrag_id = ?
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
    """);
  }

  String _sign_v2(
    EintragHeader eintrag,
    String userId,
    String password,
    DateTime now,
  ) {
    _sign_v2_insert ??= _database.getPreparedPersistent("""
      insert into signatures
        (eintrag_id, userid, signature, signed_at, sign_version)
      values
        (?, ?, ?, ?, ?)
    """);

    _v2_initQuery();

    final opts = [
      eintrag.id,
      eintrag.id,
      eintrag.id,
      now.millisecondsSinceEpoch,
      eintrag.id,
    ];

    return _sign_v2_query!.select(opts).first["json"];
  }
}
