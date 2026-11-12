import '../repository/model/model.dart';

/// Die berechneten Felder eines Jahresberichts.
///
/// Jeder Schlüssel entspricht einem Feldnamen des XML-Formats
/// (siehe `docs/jahresbericht-felder.md`), z. B. `Mitglieder_Anz_M`. Alle
/// Werte sind ganze Zahlen. Die Instanz ist unveränderlich.
class Berichtswert {
  final Map<String, int> _felder;

  /// Nimmt eine Kopie von [felder] und macht sie unveränderlich.
  Berichtswert(Map<String, int> felder)
    : _felder = Map.unmodifiable(Map.of(felder));

  /// Wert des Feldes [key]. Wirft einen [ArgumentError] für unbekannte Felder.
  int operator [](String key) =>
      _felder[key] ??
      (throw ArgumentError.value(key, 'key', 'Unbekanntes Feld'));

  /// Alle Felder in Ausgabereihenfolge.
  Map<String, int> get felder => _felder;

  @override
  bool operator ==(Object other) {
    if (other is! Berichtswert || other._felder.length != _felder.length) {
      return false;
    }
    return _felder.entries.every((e) => other._felder[e.key] == e.value);
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    _felder.entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  String toString() => 'Berichtswert($_felder)';
}

/// Das Arbeitswert-Feld je Berichtsthema, in der Reihenfolge von
/// `Arbeit_Wert_01` bis `_07`. Die einzige Quelle dieser Zuordnung.
const berichtsthemaFeld = {
  Berichtsthema.feuerwehrtechnik: 'Arbeit_Wert_01',
  Berichtsthema.wettbewerbstraining: 'Arbeit_Wert_02',
  Berichtsthema.spieleUndKreatives: 'Arbeit_Wert_03',
  Berichtsthema.mitAnderemVereinOderGruppe: 'Arbeit_Wert_04',
  Berichtsthema.sport: 'Arbeit_Wert_05',
  Berichtsthema.ersteHilfeUndPraevention: 'Arbeit_Wert_06',
  Berichtsthema.sonstiges: 'Arbeit_Wert_07',
};

const _dauerFeld = 'Arbeit_Wert_10';
const _betreuerProEintragFeld = 'Arbeit_Wert_12';
const _tagesveranstaltungenFeld = 'Arbeit_Wert_13';

/// Die berechneten Arbeitswerte in Ausgabereihenfolge: `Arbeit_Wert_01` bis
/// `_07` (je Berichtsthema), `_10`, `_12`, `_13`. Nur diese lassen sich
/// überschreiben (siehe [Ueberschreibungen]); `_11` und `_20` sind manuell.
final List<String> berechneteArbeitswertFelder = List.unmodifiable([
  ...berichtsthemaFeld.values,
  _dauerFeld,
  _betreuerProEintragFeld,
  _tagesveranstaltungenFeld,
]);

/// Ab dieser Dauer ist ein Eintrag eine Tagesveranstaltung.
const tagesveranstaltungAbDauer = Duration(hours: 5);

/// Vom Anwender überschriebene Arbeitswerte (Feldname -> ganze Zahl).
///
/// Überschreibbar sind nur die berechneten Arbeitswerte (`Arbeit_Wert_01`
/// bis `_07`, `_10`, `_12`, `_13`). Zählwerte und manuelle Angaben nicht;
/// der Konstruktor wirft dafür einen [ArgumentError]. Als einfache Map
/// ([toMap]) serialisierbar. Unveränderlich.
class Ueberschreibungen {
  /// Die Felder, die überschrieben werden dürfen.
  static final Set<String> ueberschreibbareFelder = Set.unmodifiable(
    berechneteArbeitswertFelder,
  );

  final Map<String, int> _werte;

  /// Prüft [werte] und nimmt eine Kopie. Werte müssen `>= 0` sein.
  Ueberschreibungen(Map<String, int> werte)
    : _werte = Map.unmodifiable(_pruefe(werte));

  const Ueberschreibungen.keine() : _werte = const {};

  static Map<String, int> _pruefe(Map<String, int> werte) {
    for (final e in werte.entries) {
      if (!ueberschreibbareFelder.contains(e.key)) {
        throw ArgumentError.value(
          e.key,
          'werte',
          'Feld ist nicht überschreibbar',
        );
      }
      if (e.value < 0) {
        throw ArgumentError.value(
          e.value,
          'werte',
          'Wert für ${e.key} darf nicht negativ sein',
        );
      }
    }
    return Map.of(werte);
  }

  /// Unveränderliche Map (Feldname -> Wert), z. B. zum Speichern.
  Map<String, int> toMap() => _werte;

  @override
  bool operator ==(Object other) {
    if (other is! Ueberschreibungen || other._werte.length != _werte.length) {
      return false;
    }
    return _werte.entries.every((e) => other._werte[e.key] == e.value);
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    _werte.entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  String toString() => 'Ueberschreibungen($_werte)';
}

const _geschlechter = {
  Gender.male: 'M',
  Gender.female: 'W',
  Gender.diverse: 'D',
};

const _zugangPraefix = {
  Herkunft.neu: 'Zugang_Anz_Neu',
  Herkunft.andereOrganisation: 'Zugang_Anz_AO',
  Herkunft.kinderfeuerwehr: 'Zugang_Anz_KF',
};

/// Ziel-Grundfeld je sonstigem Austrittsgrund. `uebernahme` ist ein Abgang in
/// die Einsatzabteilung und hat kein Grundfeld.
const _soGrundFeld = {
  AustrittsGrund.wohnortwechsel: 'Grund_SO_Wohnort',
  AustrittsGrund.noInterest: 'Grund_SO_Interesse',
  AustrittsGrund.schule: 'Grund_SO_Schule',
  AustrittsGrund.ausbildung: 'Grund_SO_Beruf',
  AustrittsGrund.ausschluss: 'Grund_SO_Verweis',
  AustrittsGrund.noUebernahme: 'Grund_SO_Übernahme',
};

String _altersPraefix(int alter) {
  if (alter < 5) return 'Alter_Anz_unter_5';
  if (alter > 18) return 'Alter_Anz_über_18';
  return 'Alter_Anz_${alter.toString().padLeft(2, '0')}';
}

/// Berechnet die Zählwerte des Jahresberichts für [berichtsjahr].
///
/// Stichtag ist der 31.12. des Berichtsjahres. Reine Funktion ohne
/// Abhängigkeit von Datenbank oder UI. Ersetzte Jugendliche (Namensänderung)
/// werden ausgelassen, die Kette zählt mit dem aktuellen Datensatz.
///
/// Arbeitswerte berücksichtigen alle [eintraege] mit Beginn im Berichtsjahr,
/// signiert oder nicht. Ein Eintrag zählt in dem Berichtsthema seiner
/// Kategorie aus [kategorien]; ohne Kategorie oder Thema zählt er in keinem
/// Thema (siehe [kategorienOhneBerichtsthema]). Ein Wert aus
/// [ueberschreibungen] ersetzt den berechneten.
Berichtswert berechneBerichtswert({
  required int berichtsjahr,
  required List<Jugendlicher> jugendliche,
  required List<Betreuer> betreuer,
  required List<Eintrag> eintraege,
  List<Kategorie> kategorien = const [],
  Ueberschreibungen ueberschreibungen = const Ueberschreibungen.keine(),
}) {
  final felder = <String, int>{};

  void anlegeNachGeschlecht(String prefix) {
    for (final suffix in _geschlechter.values) {
      felder['${prefix}_$suffix'] = 0;
    }
  }

  void zaehle(String prefix, Gender gender) {
    final key = '${prefix}_${_geschlechter[gender]}';
    felder[key] = felder[key]! + 1;
  }

  anlegeNachGeschlecht('Betreuer_Anz');
  anlegeNachGeschlecht('Mitglieder_Anz');
  for (final prefix in _zugangPraefix.values) {
    anlegeNachGeschlecht(prefix);
  }
  anlegeNachGeschlecht('Abgang_Anz_EA');
  anlegeNachGeschlecht('Abgang_Anz_SO');
  for (final feld in _soGrundFeld.values) {
    felder[feld] = 0;
  }
  anlegeNachGeschlecht('Alter_Anz_unter_5');
  for (var alter = 5; alter <= 18; alter++) {
    anlegeNachGeschlecht(_altersPraefix(alter));
  }
  anlegeNachGeschlecht('Alter_Anz_über_18');

  for (final feld in berechneteArbeitswertFelder) {
    felder[feld] = 0;
  }

  final stichtag = DateTime(berichtsjahr, 12, 31);

  for (final j in jugendliche.where((j) => j.replacedBy == null)) {
    final eintritt = _tag(j.memberSince);
    final austritt = j.exitDate == null ? null : _tag(j.exitDate!);

    final istMitglied =
        !eintritt.isAfter(stichtag) &&
        (austritt == null || austritt.isAfter(stichtag));
    if (istMitglied) {
      zaehle('Mitglieder_Anz', j.gender);
      zaehle(_altersPraefix(_alterAm(stichtag, j.birthDate)), j.gender);
    }

    if (eintritt.year == berichtsjahr) {
      zaehle(_zugangPraefix[j.herkunft]!, j.gender);
    }

    if (austritt != null && austritt.year == berichtsjahr) {
      final grund = j.exitReason;
      if (grund == AustrittsGrund.uebernahme) {
        zaehle('Abgang_Anz_EA', j.gender);
      } else {
        zaehle('Abgang_Anz_SO', j.gender);
        final grundFeld = _soGrundFeld[grund];
        if (grundFeld != null) felder[grundFeld] = felder[grundFeld]! + 1;
      }
    }
  }

  final eintraegeDesJahres = _eintraegeDesJahres(berichtsjahr, eintraege);

  final betreuerIdsDesJahres = {
    for (final e in eintraegeDesJahres) ...e.betreuerIds,
  };
  for (final b in betreuer.where((b) => betreuerIdsDesJahres.contains(b.id))) {
    zaehle('Betreuer_Anz', b.gender);
  }

  if (eintraegeDesJahres.isNotEmpty) {
    final themaDerKategorie = {
      for (final k in kategorien) k.id: k.berichtsthema,
    };
    var dauerSekunden = 0;
    var betreuerSumme = 0;
    for (final e in eintraegeDesJahres) {
      final thema = themaDerKategorie[e.kategorieId];
      if (thema != null) {
        final feld = berichtsthemaFeld[thema]!;
        felder[feld] = felder[feld]! + 1;
      }
      final dauer = e.end.difference(e.start);
      if (dauer >= tagesveranstaltungAbDauer) {
        felder[_tagesveranstaltungenFeld] =
            felder[_tagesveranstaltungenFeld]! + 1;
      }
      dauerSekunden += dauer.inSeconds;
      betreuerSumme += e.betreuerIds.length;
    }
    final n = eintraegeDesJahres.length;
    felder[_dauerFeld] = (dauerSekunden / 60 / n).round();
    felder[_betreuerProEintragFeld] = (betreuerSumme / n).round();
  }

  felder.addAll(ueberschreibungen.toMap());

  return Berichtswert(felder);
}

/// Die im Berichtsjahr benutzten Kategorien, denen noch kein Berichtsthema
/// zugeordnet ist.
///
/// Benutzt heißt: mindestens ein Eintrag mit Beginn im [berichtsjahr]. Jede
/// Kategorie erscheint einmal, in der Reihenfolge von [kategorien]. Einträge
/// mit unbekannter Kategorie-ID werden ignoriert.
List<Kategorie> kategorienOhneBerichtsthema({
  required int berichtsjahr,
  required List<Kategorie> kategorien,
  required List<Eintrag> eintraege,
}) {
  final benutzt = {
    for (final e in _eintraegeDesJahres(berichtsjahr, eintraege)) e.kategorieId,
  };
  return [
    for (final k in kategorien)
      if (k.berichtsthema == null && benutzt.contains(k.id)) k,
  ];
}

List<Eintrag> _eintraegeDesJahres(int berichtsjahr, List<Eintrag> eintraege) =>
    eintraege.where((e) => e.start.year == berichtsjahr).toList();

DateTime _tag(DateTime d) => DateTime(d.year, d.month, d.day);

/// Vollendete Lebensjahre von [geburt] am Tag [stichtag].
int _alterAm(DateTime stichtag, DateTime geburt) {
  var alter = stichtag.year - geburt.year;
  final geburtstagErreicht =
      stichtag.month > geburt.month ||
      (stichtag.month == geburt.month && stichtag.day >= geburt.day);
  if (!geburtstagErreicht) alter--;
  return alter;
}
