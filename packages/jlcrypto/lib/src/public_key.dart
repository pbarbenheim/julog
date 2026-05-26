import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart' as pc;

import 'identity.dart';
import 'message.dart';
import 'signature.dart';

@internal
PublicKey createPublicKeyFromRsaKey(
  pc.RSAPublicKey rsaPublicKey,
  KeyOwner keyOwner,
  String id,
) {
  return PublicKey._(rsaPublicKey, keyOwner, id);
}

class PublicKey {
  late final pc.RSAPublicKey _rsaPublicKey;
  late final KeyOwner _keyOwner;
  late final String _id;

  KeyOwner get keyOwner => _keyOwner;
  String get id => _id;

  PublicKey._(this._rsaPublicKey, this._keyOwner, this._id);

  PublicKey.fromString(String publicKeyString) {
    final json =
        jsonDecode(utf8.decode(base64Decode(publicKeyString)))
            as Map<String, dynamic>;

    final identityJson = json['identity'] as Map<String, dynamic>;
    final BigInt modulus = BigInt.parse(json['modulus'] as String);
    final BigInt exponent = BigInt.parse(json['exponent'] as String);
    _keyOwner = KeyOwner(
      identityJson['name']!,
      identityJson['function']!,
      identityJson['mail']!,
    );
    _id = json['id'] as String;
    _rsaPublicKey = pc.RSAPublicKey(modulus, exponent);
  }

  factory PublicKey.fromEncodedPrivate(String encodedPrivateKey) {
    final json =
        jsonDecode(utf8.decode(base64Decode(encodedPrivateKey)))
            as Map<String, dynamic>;
    return PublicKey.fromString(json['public'] as String);
  }

  bool verifySHA512Signature(Message message, Signature signature) =>
      _verifySignature(message, signature, 'SHA-512/RSA');

  bool _verifySignature(
    Message message,
    Signature signature,
    String algorithm,
  ) {
    final signer = pc.Signer(algorithm);
    pc.AsymmetricKeyParameter<pc.RSAPublicKey> params = pc.PublicKeyParameter(
      _rsaPublicKey,
    );
    final pcSignature = pc.RSASignature(signature.bytes);
    signer.init(false, params);
    return signer.verifySignature(message.bytes, pcSignature);
  }

  @override
  String toString() {
    final json = jsonEncode({
      'id': _id,
      'identity': {
        'name': _keyOwner.name,
        'function': _keyOwner.function,
        'mail': _keyOwner.mail,
      },
      'modulus': _rsaPublicKey.modulus.toString(),
      'exponent': _rsaPublicKey.exponent.toString(),
    });
    return base64Encode(utf8.encode(json));
  }
}
