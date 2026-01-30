import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart' as pc;
import 'package:uuid/uuid.dart';

import 'private_key.dart';
import 'public_key.dart';
import 'identity.dart';

class KeyPair {
  late final PrivateKey _privateKey;
  late final PublicKey _publicKey;

  KeyPair(this._privateKey) : _publicKey = _privateKey.publicKey;

  KeyPair.generate({
    required Identity identity,
    required String password,
    int keySize = 4069,
  }) {
    final keyParams = pc.RSAKeyGeneratorParameters(
      BigInt.from(65537),
      keySize,
      64,
    );

    final fortuna = pc.FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    fortuna.seed(pc.KeyParameter(Uint8List.fromList(seeds)));

    final randomParams = pc.ParametersWithRandom(keyParams, fortuna);
    final keyGenerator = pc.RSAKeyGenerator();
    keyGenerator.init(randomParams);

    final pair = keyGenerator.generateKeyPair();
    final rsap = pair.privateKey;
    final rsaPublicKey = pair.publicKey;
    final id = Uuid().v4();

    _publicKey = createPublicKeyFromRsaKey(rsaPublicKey, identity, id);
    final encoded = encodePrivateKey(
      rsap.n!,
      rsap.privateExponent!,
      rsap.p!,
      rsap.q!,
      password,
    );
    _privateKey = createPrivateKeyFromRsaKey(rsap, _publicKey, encoded);
  }

  PublicKey get publicKey => _publicKey;
  PrivateKey get privateKey => _privateKey;

  static Future<KeyPair> generateAsync({
    required Identity identity,
    required String password,
    int keySize = 4096,
  }) => Future(
    () => KeyPair.generate(
      identity: identity,
      password: password,
      keySize: keySize,
    ),
  );
}
