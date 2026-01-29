import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

import '../gender.dart';

part 'betreuer.freezed.dart';

@freezed
abstract class Betreuer with _$Betreuer {
  const factory Betreuer({
    required String id,
    required String name,
    required Gender gender,
  }) = _Betreuer;

  static Betreuer fromJldbRecord(BetreuerApiModel record) {
    return Betreuer(
      id: record.id.toString(),
      name: record.name,
      gender: switch (record.sex) {
        Sex.diverse => Gender.diverse,
        Sex.female => Gender.female,
        Sex.male => Gender.male,
      },
    );
  }
}
