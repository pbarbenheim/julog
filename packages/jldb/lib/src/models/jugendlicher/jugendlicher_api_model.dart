import 'package:freezed_annotation/freezed_annotation.dart';

import '../exit_reason.dart';
import '../sex.dart';
import '../uuid.dart';

part 'jugendlicher_api_model.freezed.dart';

@freezed
abstract class JugendlicherApiModel with _$JugendlicherApiModel {
  const factory JugendlicherApiModel({
    required UUID id,
    required String name,
    required Sex sex,
    String? pass,
    required DateTime birthDate,
    required DateTime memberSince,
    DateTime? exitDate,
    ExitReason? exitReason,
    UUID? replacedById,
    UUID? replacesId,
    required Set<UUID> eintragIds,
  }) = _JugendlicherApiModel;

  const JugendlicherApiModel._();

  bool canBeUpdatedFrom(JugendlicherApiModel existingJug) {
    return id == existingJug.id && name == existingJug.name;
  }
}

@freezed
abstract class JugendlicherCreateDTO with _$JugendlicherCreateDTO {
  const factory JugendlicherCreateDTO({
    required String name,
    required Sex sex,
    String? pass,
    required DateTime birthDate,
    required DateTime memberSince,
    UUID? replacesId,
  }) = _JugendlicherCreateDTO;
}
