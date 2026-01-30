import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart' as pc;

import 'identity.dart';
import 'public_key.dart';
import 'signature.dart';
import 'message.dart';
import 'aes.dart';

@internal
PrivateKey createPrivateKeyFromRsaKey(
  pc.RSAPrivateKey rsaPrivateKey,
  PublicKey publicKey,
  String encodedPrivateKey,
) {
  return PrivateKey._(rsaPrivateKey, publicKey, encodedPrivateKey);
}

@internal
String encodePrivateKey(
  BigInt n,
  BigInt privateExponent,
  BigInt p,
  BigInt q,
  String password,
) {
  final privateKey = jsonEncode({
    'modulus': n.toString(),
    'privateExponent': privateExponent.toString(),
    'p': p.toString(),
    'q': q.toString(),
  });
  return encrypt(privateKey, password);
}

class PrivateKey {
  pc.RSAPrivateKey? _rsaPrivateKey;
  late final PublicKey _publicKey;
  late final String _encodedPrivateKey;

  Identity get identity => _publicKey.identity;
  String get id => _publicKey.id;
  PublicKey get publicKey => _publicKey;

  PrivateKey._(this._rsaPrivateKey, this._publicKey, this._encodedPrivateKey);

  PrivateKey.fromString(String privateKeyString, String password) {
    final json =
        jsonDecode(utf8.decode(base64Decode(privateKeyString)))
            as Map<String, dynamic>;
    _encodedPrivateKey = json['private'] as String;
    _publicKey = PublicKey.fromString(json['public'] as String);
    final decrypted =
        jsonDecode(decrypt(_encodedPrivateKey, password))
            as Map<String, dynamic>;
    _rsaPrivateKey = pc.RSAPrivateKey(
      BigInt.parse(decrypted['modulus'] as String),
      BigInt.parse(decrypted['privateExponent'] as String),
      BigInt.parse(decrypted['p'] as String),
      BigInt.parse(decrypted['q'] as String),
    );
  }

  Signature signSHA512(Message message) => _sign(message, 'SHA-512/RSA');

  Signature _sign(Message message, String algorithm) {
    if (_rsaPrivateKey == null) {
      throw StateError('Private key is not initialized.');
    }
    final signer = pc.Signer(algorithm);
    pc.AsymmetricKeyParameter<pc.RSAPrivateKey> params = pc.PrivateKeyParameter(
      _rsaPrivateKey!,
    );
    signer.init(true, params);
    final pcSignature =
        signer.generateSignature(message.bytes) as pc.RSASignature;
    return Signature(pcSignature.bytes);
  }

  @override
  String toString() {
    final json = jsonEncode({
      'private': _encodedPrivateKey,
      'public': _publicKey.toString(),
    });
    return base64Encode(utf8.encode(json));
  }
}
