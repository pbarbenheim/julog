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
    // ID of the Jugendlicher this one replaces, is id because we want to avoid cycles
    String? replacesId,
    required Set<String> eintragIds,
  }) = _Jugendlicher;

  String get currentId => replacedBy?.currentId ?? id;

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
      eintragIds: record.eintragIds.map((e) => e.toString()).toSet(),
      replacesId: record.replacesId?.toString(),
    );
  }
}
