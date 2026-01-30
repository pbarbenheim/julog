import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

String encrypt(String plainText, String passPhrase) {
  final key = _passphraseToKey(passPhrase, bitLength: 256);
  final iv = _generateRandomBytes(16)!;

  final paddedPlainText = _pad(utf8.encode(plainText), 16);

  final cipherText = _aesCbcEncrypt(key, iv, paddedPlainText);

  // Combine IV and cipherText for storage/transmission

  final combined = Uint8List(iv.length + cipherText.length)
    ..setAll(0, iv)
    ..setAll(iv.length, cipherText);

  return base64Encode(combined);
}

String decrypt(String cipherTextBase64, String passPhrase) {
  final combined = base64Decode(cipherTextBase64);

  final iv = combined.sublist(0, 16);
  final cipherText = combined.sublist(16);

  final key = _passphraseToKey(passPhrase, bitLength: 256);

  final paddedPlainText = _aesCbcDecrypt(key, iv, cipherText);

  final plainText = _unpad(paddedPlainText);

  return utf8.decode(plainText);
}

Uint8List _aesCbcEncrypt(
  Uint8List key,
  Uint8List iv,
  Uint8List paddedPlaintext,
) {
  if (![128, 192, 256].contains(key.length * 8)) {
    throw ArgumentError.value(key, 'key', 'invalid key length for AES');
  }
  if (iv.length * 8 != 128) {
    throw ArgumentError.value(iv, 'iv', 'invalid IV length for AES');
  }
  if (paddedPlaintext.length * 8 % 128 != 0) {
    throw ArgumentError.value(
      paddedPlaintext,
      'paddedPlaintext',
      'invalid length for AES',
    );
  }

  final cbc = BlockCipher('AES/CBC')
    ..init(true, ParametersWithIV(KeyParameter(key), iv));

  final cipherText = Uint8List(paddedPlaintext.length);

  var offset = 0;
  while (offset < paddedPlaintext.length) {
    offset += cbc.processBlock(paddedPlaintext, offset, cipherText, offset);
  }
  assert(offset == paddedPlaintext.length);

  return cipherText;
}

Uint8List _aesCbcDecrypt(Uint8List key, Uint8List iv, Uint8List cipherText) {
  if (![128, 192, 256].contains(key.length * 8)) {
    throw ArgumentError.value(key, 'key', 'invalid key length for AES');
  }
  if (iv.length * 8 != 128) {
    throw ArgumentError.value(iv, 'iv', 'invalid IV length for AES');
  }
  if (cipherText.length * 8 % 128 != 0) {
    throw ArgumentError.value(
      cipherText,
      'cipherText',
      'invalid length for AES',
    );
  }

  final cbc = BlockCipher('AES/CBC')
    ..init(false, ParametersWithIV(KeyParameter(key), iv));

  final paddedPlainText = Uint8List(cipherText.length);

  var offset = 0;
  while (offset < cipherText.length) {
    offset += cbc.processBlock(cipherText, offset, paddedPlainText, offset);
  }
  assert(offset == cipherText.length);

  return paddedPlainText;
}

Uint8List _pad(Uint8List bytes, int blockSizeBytes) {
  final padLength = blockSizeBytes - (bytes.length % blockSizeBytes);

  final padded = Uint8List(bytes.length + padLength)..setAll(0, bytes);
  Padding('PKCS7').addPadding(padded, bytes.length);

  return padded;
}

Uint8List _unpad(Uint8List padded) =>
    padded.sublist(0, padded.length - Padding('PKCS7').padCount(padded));

Uint8List _passphraseToKey(
  String passPhrase, {
  String salt = '',
  int iterations = 30000,
  required int bitLength,
}) {
  if (![128, 192, 256].contains(bitLength)) {
    throw ArgumentError.value(bitLength, 'bitLength', 'invalid for AES');
  }
  final numBytes = bitLength ~/ 8;

  final kd = KeyDerivator('SHA-256/HMAC/PBKDF2')
    ..init(Pbkdf2Parameters(utf8.encode(salt), iterations, numBytes));

  return kd.process(utf8.encode(passPhrase));
}

Uint8List? _generateRandomBytes(int numBytes) {
  if (_secureRandom == null) {
    final rand = Random.secure();
    final seed = Uint8List.fromList(
      List<int>.generate(32, (_) => rand.nextInt(256)),
    );
    // First invocation: create _secureRandom and seed it
    _secureRandom = SecureRandom('Fortuna');
    _secureRandom!.seed(KeyParameter(seed));
  }

  // Use it to generate the random bytes

  final iv = _secureRandom!.nextBytes(numBytes);
  return iv;
}

SecureRandom? _secureRandom;
