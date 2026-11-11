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
Berichtswert berechneBerichtswert({
  required int berichtsjahr,
  required List<Jugendlicher> jugendliche,
  required List<Betreuer> betreuer,
  required List<Eintrag> eintraege,
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

  final betreuerIdsDesJahres = {
    for (final e in eintraege.where((e) => e.start.year == berichtsjahr))
      ...e.betreuerIds,
  };
  for (final b in betreuer.where((b) => betreuerIdsDesJahres.contains(b.id))) {
    zaehle('Betreuer_Anz', b.gender);
  }

  return Berichtswert(felder);
}

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
