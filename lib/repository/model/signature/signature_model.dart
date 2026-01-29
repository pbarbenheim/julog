import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;

part 'signature_model.freezed.dart';

@freezed
abstract class Signature with _$Signature {
  const Signature._();
  const factory Signature({
    required String eintragId,
    required String identityId,
    required crypto.Signature signature,
    required DateTime timestamp,
    required int version,
    required bool isValid,
  }) = _Signature;

  String get id => '$eintragId:$identityId';

  static Signature fromApiModel(SignatureApiModel model, bool isValid) {
    return Signature(
      eintragId: model.eintragId.toString(),
      identityId: model.identityId.toString(),
      signature: crypto.Signature.fromString(model.signature),
      timestamp: model.timestamp,
      version: model.version,
      isValid: isValid,
    );
  }
}
