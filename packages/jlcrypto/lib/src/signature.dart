import 'dart:convert';
import 'dart:typed_data';

class Signature {
  final Uint8List _bytes;

  Uint8List get bytes => _bytes;

  Signature(this._bytes);

  Signature.fromString(String signatureString)
    : _bytes = base64Decode(signatureString);

  @override
  String toString() {
    return base64Encode(_bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Signature) return false;
    if (other._bytes.length != _bytes.length) return false;

    for (var i = 0; i < _bytes.length; i++) {
      if (_bytes[i] != other._bytes[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => _bytes.hashCode;
}
