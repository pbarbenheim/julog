import 'package:jldb/jldb.dart';

/// Topic a Kategorie is reported under in the Jahresbericht.
///
/// The order matches `Arbeit_Wert_01` to `Arbeit_Wert_07`. A Kategorie
/// without a Berichtsthema is "not yet assigned" (`null`); [sonstiges] is an
/// explicit choice.
enum Berichtsthema {
  feuerwehrtechnik('Feuerwehrtechnische Ausbildung'),
  wettbewerbstraining('Wettbewerbstraining'),
  spieleUndKreatives('Spiele und Kreatives'),
  mitAnderemVereinOderGruppe('Mit anderem Verein oder Gruppe'),
  sport('Sport'),
  ersteHilfeUndPraevention('Erste Hilfe und Prävention'),
  sonstiges('Sonstiges');

  final String display;
  const Berichtsthema(this.display);

  static Berichtsthema fromReportTopic(ReportTopic topic) => switch (topic) {
    ReportTopic.feuerwehrtechnik => Berichtsthema.feuerwehrtechnik,
    ReportTopic.wettbewerbstraining => Berichtsthema.wettbewerbstraining,
    ReportTopic.spieleUndKreatives => Berichtsthema.spieleUndKreatives,
    ReportTopic.mitAnderemVereinOderGruppe =>
      Berichtsthema.mitAnderemVereinOderGruppe,
    ReportTopic.sport => Berichtsthema.sport,
    ReportTopic.ersteHilfeUndPraevention =>
      Berichtsthema.ersteHilfeUndPraevention,
    ReportTopic.sonstiges => Berichtsthema.sonstiges,
  };

  ReportTopic toReportTopic() => switch (this) {
    Berichtsthema.feuerwehrtechnik => ReportTopic.feuerwehrtechnik,
    Berichtsthema.wettbewerbstraining => ReportTopic.wettbewerbstraining,
    Berichtsthema.spieleUndKreatives => ReportTopic.spieleUndKreatives,
    Berichtsthema.mitAnderemVereinOderGruppe =>
      ReportTopic.mitAnderemVereinOderGruppe,
    Berichtsthema.sport => ReportTopic.sport,
    Berichtsthema.ersteHilfeUndPraevention =>
      ReportTopic.ersteHilfeUndPraevention,
    Berichtsthema.sonstiges => ReportTopic.sonstiges,
  };
}
