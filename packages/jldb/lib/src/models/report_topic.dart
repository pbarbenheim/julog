/// The Berichtsthema a Kategorie is assigned to for the Jahresbericht.
///
/// The order matches `Arbeit_Wert_01` to `Arbeit_Wert_07`. A Kategorie
/// without a Berichtsthema is stored as `null`; [sonstiges] is an explicit
/// choice and distinct from that.
enum ReportTopic {
  feuerwehrtechnik,
  wettbewerbstraining,
  spieleUndKreatives,
  mitAnderemVereinOderGruppe,
  sport,
  ersteHilfeUndPraevention,
  sonstiges;

  int toInt() => switch (this) {
    ReportTopic.feuerwehrtechnik => 0,
    ReportTopic.wettbewerbstraining => 1,
    ReportTopic.spieleUndKreatives => 2,
    ReportTopic.mitAnderemVereinOderGruppe => 3,
    ReportTopic.sport => 4,
    ReportTopic.ersteHilfeUndPraevention => 5,
    ReportTopic.sonstiges => 6,
  };

  static ReportTopic fromInt(int value) => switch (value) {
    0 => ReportTopic.feuerwehrtechnik,
    1 => ReportTopic.wettbewerbstraining,
    2 => ReportTopic.spieleUndKreatives,
    3 => ReportTopic.mitAnderemVereinOderGruppe,
    4 => ReportTopic.sport,
    5 => ReportTopic.ersteHilfeUndPraevention,
    6 => ReportTopic.sonstiges,
    _ => throw ArgumentError('Invalid value for ReportTopic enum: $value'),
  };
}
