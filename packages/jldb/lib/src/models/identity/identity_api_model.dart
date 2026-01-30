import 'package:freezed_annotation/freezed_annotation.dart';

import '../uuid.dart';

part 'identity_api_model.freezed.dart';

@freezed
abstract class IdentityApiModel with _$IdentityApiModel {
  const factory IdentityApiModel({
    required UUID id,
    required String publicKey,
  }) = _IdentityApiModel;
}
