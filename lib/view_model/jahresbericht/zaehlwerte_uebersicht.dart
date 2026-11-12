import '../../jahresbericht/jahresbericht.dart';
import '../../repository/model/model.dart';

/// Ein Zählwert, getrennt nach Geschlecht (männlich, weiblich, divers).
class GeschlechterWerte {
  final int maennlich;
  final int weiblich;
  final int divers;

  const GeschlechterWerte({
    required this.maennlich,
    required this.weiblich,
    required this.divers,
  });

  int get gesamt => maennlich + weiblich + divers;

  /// Liest `<praefix>_M`, `<praefix>_W` und `<praefix>_D` aus [wert].
  factory GeschlechterWerte.aus(Berichtswert wert, String praefix) =>
      GeschlechterWerte(
        maennlich: wert['${praefix}_M'],
        weiblich: wert['${praefix}_W'],
        divers: wert['${praefix}_D'],
      );
}

/// Die Zählwerte eines Jahresberichts, gruppiert für die Anzeige in
/// Schritt 1 des Assistenten (Mitglieder, Alter, Betreuer, Zugang, Abgang).
///
/// Nur lesend; die Werte kommen aus dem [Berichtswert].
class ZaehlwerteUebersicht {
  final GeschlechterWerte mitglieder;
  final GeschlechterWerte betreuer;

  final GeschlechterWerte alterUnter5;

  /// Alter 5 bis 18, je Lebensjahr eine Zeile.
  final List<({int alter, GeschlechterWerte werte})> alter;
  final GeschlechterWerte alterUeber18;

  final GeschlechterWerte zugangNeu;
  final GeschlechterWerte zugangAndereOrganisation;
  final GeschlechterWerte zugangKinderfeuerwehr;

  final GeschlechterWerte abgangEinsatzabteilung;
  final GeschlechterWerte abgangSonstige;

  /// Gründe der sonstigen Abgänge (Anzahl je Grund, ohne
  /// [AustrittsGrund.uebernahme], das ist ein Abgang in die
  /// Einsatzabteilung).
  final Map<AustrittsGrund, int> abgangGruende;

  const ZaehlwerteUebersicht._({
    required this.mitglieder,
    required this.betreuer,
    required this.alterUnter5,
    required this.alter,
    required this.alterUeber18,
    required this.zugangNeu,
    required this.zugangAndereOrganisation,
    required this.zugangKinderfeuerwehr,
    required this.abgangEinsatzabteilung,
    required this.abgangSonstige,
    required this.abgangGruende,
  });

  factory ZaehlwerteUebersicht.von(Berichtswert wert) {
    GeschlechterWerte g(String praefix) => GeschlechterWerte.aus(wert, praefix);
    return ZaehlwerteUebersicht._(
      mitglieder: g('Mitglieder_Anz'),
      betreuer: g('Betreuer_Anz'),
      alterUnter5: g('Alter_Anz_unter_5'),
      alter: [
        for (var a = 5; a <= 18; a++)
          (alter: a, werte: g('Alter_Anz_${a.toString().padLeft(2, '0')}')),
      ],
      alterUeber18: g('Alter_Anz_über_18'),
      zugangNeu: g('Zugang_Anz_Neu'),
      zugangAndereOrganisation: g('Zugang_Anz_AO'),
      zugangKinderfeuerwehr: g('Zugang_Anz_KF'),
      abgangEinsatzabteilung: g('Abgang_Anz_EA'),
      abgangSonstige: g('Abgang_Anz_SO'),
      abgangGruende: {
        AustrittsGrund.wohnortwechsel: wert['Grund_SO_Wohnort'],
        AustrittsGrund.noInterest: wert['Grund_SO_Interesse'],
        AustrittsGrund.schule: wert['Grund_SO_Schule'],
        AustrittsGrund.ausbildung: wert['Grund_SO_Beruf'],
        AustrittsGrund.ausschluss: wert['Grund_SO_Verweis'],
        AustrittsGrund.noUebernahme: wert['Grund_SO_Übernahme'],
      },
    );
  }
}
