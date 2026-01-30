import 'dart:convert';
import 'dart:typed_data';

class Message {
  final Uint8List _bytes;
  Uint8List get bytes => _bytes;

  Message(this._bytes);

  Message.fromString(String messageString)
    : _bytes = utf8.encode(messageString);

  @override
  String toString() {
    return utf8.decode(_bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Message) return false;
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
