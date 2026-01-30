import 'package:freezed_annotation/freezed_annotation.dart';

import '../uuid.dart';

part 'signature_api_model.freezed.dart';

@freezed
abstract class SignatureApiModel with _$SignatureApiModel {
  const factory SignatureApiModel({
    required UUID eintragId,
    required UUID identityId,
    required String signature,
    required DateTime timestamp,
    required int version,
  }) = _SignatureApiModel;
}
