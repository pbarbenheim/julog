import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

import '../../../jahresbericht/jahresbericht.dart';
import '../../../jahresbericht/manuelle_angaben.dart';

part 'berichtsentwurf.freezed.dart';

/// Status eines Berichtsentwurfs.
enum EntwurfStatus {
  entwurf,
  exportiert;

  static EntwurfStatus fromJldb(BerichtsentwurfStatus status) =>
      switch (status) {
        BerichtsentwurfStatus.entwurf => EntwurfStatus.entwurf,
        BerichtsentwurfStatus.exportiert => EntwurfStatus.exportiert,
      };
}

/// Der gespeicherte Stand eines Jahresberichts, einer je Berichtsjahr.
///
/// Hält die manuellen Angaben und die Überschreibungen der Arbeitswerte
/// (siehe Berichtslogik). Bewusst nicht in `model.dart` exportiert, weil die
/// Berichtslogik selbst `model.dart` importiert.
@freezed
abstract class Berichtsentwurf with _$Berichtsentwurf {
  const factory Berichtsentwurf({
    required int year,
    required ManuelleAngaben angaben,
    required Ueberschreibungen ueberschreibungen,
    required EntwurfStatus status,

    /// Zeitpunkt des letzten Exports; `null`, solange nicht exportiert.
    DateTime? exportedAt,
  }) = _Berichtsentwurf;

  static Berichtsentwurf fromJldbRecord(BerichtsentwurfApiModel record) {
    return Berichtsentwurf(
      year: record.year,
      angaben: ManuelleAngaben.fromMap(record.angaben),
      ueberschreibungen: Ueberschreibungen(record.ueberschreibungen),
      status: EntwurfStatus.fromJldb(record.status),
      exportedAt: record.exportedAt,
    );
  }
}
