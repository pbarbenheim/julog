import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

import '../berichtsthema.dart';

part 'kategorie.freezed.dart';

@freezed
abstract class Kategorie with _$Kategorie {
  const factory Kategorie({
    required String id,
    required String name,

    /// `null` means "not yet assigned"; [Berichtsthema.sonstiges] is an
    /// explicit choice.
    Berichtsthema? berichtsthema,
  }) = _Kategorie;

  static Kategorie fromJldbRecord(KategorieApiModel record) {
    return Kategorie(
      id: record.id.toString(),
      name: record.name,
      berichtsthema: record.reportTopic == null
          ? null
          : Berichtsthema.fromReportTopic(record.reportTopic!),
    );
  }
}
