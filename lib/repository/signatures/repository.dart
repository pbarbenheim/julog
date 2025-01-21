import 'package:dart_pg/dart_pg.dart';
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
        throw UnsupportedError("Unsupported signing version"); //TODO change
    }
  }

  // ignore: non_constant_identifier_names
  bool _verify_v2(Signatur signatur) {
    _v2_initQuery();

    final opts = [
      signatur.eintrag.id,
      signatur.eintrag.id,
      signatur.eintrag.id,
      signatur.signedAt,
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

  Future<Signatur> sign(Eintrag eintrag, String userId, String password) async {
    final Signatur signatur = await _sign_v2(eintrag, userId, password);
    eintrag.signaturen.add(signatur);
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
                  'anmerkung', je.anmerkung
                )
              ) as jugend
            from 
              jugendliche as j, 
              eintrag_zu_jugendliche as je
            where j.id = je.jugendliche_id 
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

  // ignore: non_constant_identifier_names
  Future<Signatur> _sign_v2(
    Eintrag eintrag,
    String userId,
    String password,
  ) async {
    _sign_v2_insert ??= _database.getPreparedPersistent("""
      insert into signatures
        (eintrag_id, userid, signature, signed_at, sign_version)
      values
        (?, ?, ?, ?, ?)
    """);

    _v2_initQuery();

    final identity = _useridsRepository.getSigningIdentity(userId);

    final now = DateTime.now();
    final opts = [
      eintrag.id,
      eintrag.id,
      eintrag.id,
      now.millisecondsSinceEpoch,
      eintrag.id,
    ];

    final String eintragJson = _sign_v2_query!.select(opts).first["json"];

    final privateKey = identity.privateKey.decrypt(password);
    final signatureRaw =
        OpenPGP.signDetachedCleartext(eintragJson, [privateKey], time: now);

    _sign_v2_insert!.execute([
      eintrag.id,
      userId,
      signatureRaw.armor(),
      now.millisecondsSinceEpoch,
      2
    ]);

    final signatur = Signatur(
      identity: Identity(userId: userId),
      signature: signatureRaw.armor(),
      signedAt: now,
      signVersion: 2,
      eintrag: eintrag,
    );
    eintrag.signaturen.add(signatur);
    return signatur;
  }
}
