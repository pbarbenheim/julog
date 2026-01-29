import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

import '../gender.dart';

part 'jugendlicher.freezed.dart';

@freezed
abstract class Jugendlicher with _$Jugendlicher {
  const factory Jugendlicher({
    required String id,
    required String name,
    required Gender gender,
    String? pass,
    required DateTime birthDate,
    required DateTime memberSince,
    DateTime? exitDate,
    int? exitReason,
    Jugendlicher? replacedBy,
  }) = _Jugendlicher;

  const Jugendlicher._();

  static Jugendlicher fromJldbRecord(
    JugendlicherApiModel record, {
    Jugendlicher? replacedBy,
  }) {
    assert(
      (record.replacedById != null) == (replacedBy != null),
      'replacedBy must be provided if replacedById is set in the record',
    );
    return Jugendlicher(
      id: record.id.toString(),
      name: record.name,
      gender: switch (record.sex) {
        Sex.diverse => Gender.diverse,
        Sex.female => Gender.female,
        Sex.male => Gender.male,
      },
      pass: record.pass,
      birthDate: record.birthDate,
      memberSince: record.memberSince,
      exitDate: record.exitDate,
      exitReason: record.exitReason,
      replacedBy: replacedBy,
    );
  }

  JugendlicherApiModel toJldbRecord() {
    final replaced = replacedBy?.id;
    return JugendlicherApiModel(
      id: UUID.fromString(id),
      name: name,
      sex: switch (gender) {
        Gender.diverse => Sex.diverse,
        Gender.female => Sex.female,
        Gender.male => Sex.male,
      },
      pass: pass,
      birthDate: birthDate,
      memberSince: memberSince,
      exitDate: exitDate,
      exitReason: exitReason,
      replacedById: replaced != null ? UUID.fromString(replaced) : null,
    );
  }
}
