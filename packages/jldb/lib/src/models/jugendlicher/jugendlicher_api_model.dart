import 'package:freezed_annotation/freezed_annotation.dart';

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
    int? exitReason,
    UUID? replacedById,
  }) = _JugendlicherApiModel;

  const JugendlicherApiModel._();

  bool canBeUpdatedFrom(JugendlicherApiModel existingJug) {
    return id == existingJug.id && name == existingJug.name;
  }
}
