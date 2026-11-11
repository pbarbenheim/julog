/// Anzahl der Ja/Nein-Fragen des Jahresberichts (`Frage_01` bis `Frage_16`).
const anzahlFragen = 16;

const _unveraendert = Object();

/// Die Angaben des Jahresberichts, die Julog nicht berechnen kann.
///
/// Jede Angabe ist optional; `null` bzw. ein fehlender Eintrag heißt "noch
/// nicht beantwortet". Unveränderlich, mit Wertgleichheit. Ändern geht über
/// [copyWith] und [withFrage].
///
/// ## Persistierbare Form
///
/// [toMap] liefert eine flache Map mit den Feldnamen des XML-Formats als
/// Schlüssel, nur für beantwortete Angaben (eine leere Map = nichts
/// beantwortet). [fromMap] ist die Umkehrung:
///
/// | Schlüssel | Typ | Bedeutung |
/// |---|---|---|
/// | `Frage_01` … `Frage_16` | `bool` | Antwort Ja (`true`) / Nein (`false`) |
/// | `Arbeit_Wert_11` | `int` | durchschnittliche Vor-/Nachbereitungszeit |
/// | `Arbeit_Wert_20` | `int` | Stunden sonstige Arbeit |
/// | `Alter_Anz_EA_bis_27_M` / `_W` / `_D` | `int` | unter 27-Jährige in der Einsatzabteilung |
///
/// Die Schlüssel sind stabil; es kommen nur `bool` und `int` vor, also
/// verlustfrei als Spalten oder JSON speicherbar.
class ManuelleAngaben {
  final Map<int, bool> _fragen;

  /// Vorbereitungs-/Nachbereitungszeit je Gruppenabend in Minuten
  /// (`Arbeit_Wert_11`).
  final int? arbeitWert11;

  /// Stunden für sonstige Arbeit (`Arbeit_Wert_20`).
  final int? arbeitWert20;

  /// Unter 27-Jährige in der Einsatzabteilung, männlich / weiblich / divers.
  final int? einsatzabteilungM;
  final int? einsatzabteilungW;
  final int? einsatzabteilungD;

  /// Prüft die Eingaben und nimmt eine Kopie von [fragen] (Schlüssel
  /// 1…[anzahlFragen], Wert Ja = `true`). Zahlen müssen `>= 0` sein.
  ManuelleAngaben({
    Map<int, bool> fragen = const {},
    this.arbeitWert11,
    this.arbeitWert20,
    this.einsatzabteilungM,
    this.einsatzabteilungW,
    this.einsatzabteilungD,
  }) : _fragen = Map.unmodifiable(_pruefeFragen(fragen)) {
    _pruefeZahl('arbeitWert11', arbeitWert11);
    _pruefeZahl('arbeitWert20', arbeitWert20);
    _pruefeZahl('einsatzabteilungM', einsatzabteilungM);
    _pruefeZahl('einsatzabteilungW', einsatzabteilungW);
    _pruefeZahl('einsatzabteilungD', einsatzabteilungD);
  }

  /// Nichts beantwortet.
  const ManuelleAngaben.leer()
    : _fragen = const {},
      arbeitWert11 = null,
      arbeitWert20 = null,
      einsatzabteilungM = null,
      einsatzabteilungW = null,
      einsatzabteilungD = null;

  /// Gegenstück zu [toMap]. Wirft einen [ArgumentError] bei unbekannten
  /// Schlüsseln oder falschen Typen.
  factory ManuelleAngaben.fromMap(Map<String, Object?> map) {
    final fragen = <int, bool>{};
    int? ganzzahl(String key) {
      final v = map[key];
      if (v == null) return null;
      if (v is! int) throw ArgumentError.value(v, key, 'Ganze Zahl erwartet');
      return v;
    }

    for (final e in map.entries) {
      final nummer = _frageNummer(e.key);
      if (nummer != null) {
        final v = e.value;
        if (v is! bool) throw ArgumentError.value(v, e.key, 'bool erwartet');
        fragen[nummer] = v;
      } else if (!_zahlSchluessel.contains(e.key)) {
        throw ArgumentError.value(e.key, 'map', 'Unbekannter Schlüssel');
      }
    }
    return ManuelleAngaben(
      fragen: fragen,
      arbeitWert11: ganzzahl(_wert11Key),
      arbeitWert20: ganzzahl(_wert20Key),
      einsatzabteilungM: ganzzahl(_eaMKey),
      einsatzabteilungW: ganzzahl(_eaWKey),
      einsatzabteilungD: ganzzahl(_eaDKey),
    );
  }

  /// Die beantworteten Fragen (Fragenummer 1…[anzahlFragen] -> Ja/Nein).
  /// Unveränderlich; fehlende Nummern sind unbeantwortet.
  Map<int, bool> get fragen => _fragen;

  /// Antwort auf Frage [nummer] (1…[anzahlFragen]); `null` = unbeantwortet.
  bool? frage(int nummer) {
    RangeError.checkValueInInterval(nummer, 1, anzahlFragen, 'nummer');
    return _fragen[nummer];
  }

  /// Kopie mit neuer Antwort auf Frage [nummer]; `null` nimmt sie zurück.
  ManuelleAngaben withFrage(int nummer, bool? antwort) {
    RangeError.checkValueInInterval(nummer, 1, anzahlFragen, 'nummer');
    final neu = Map.of(_fragen);
    if (antwort == null) {
      neu.remove(nummer);
    } else {
      neu[nummer] = antwort;
    }
    return ManuelleAngaben(
      fragen: neu,
      arbeitWert11: arbeitWert11,
      arbeitWert20: arbeitWert20,
      einsatzabteilungM: einsatzabteilungM,
      einsatzabteilungW: einsatzabteilungW,
      einsatzabteilungD: einsatzabteilungD,
    );
  }

  /// Kopie mit geänderten Zahlenangaben. Nicht übergebene Werte bleiben
  /// erhalten, ausdrücklich übergebenes `null` setzt auf "unbeantwortet".
  ManuelleAngaben copyWith({
    Object? arbeitWert11 = _unveraendert,
    Object? arbeitWert20 = _unveraendert,
    Object? einsatzabteilungM = _unveraendert,
    Object? einsatzabteilungW = _unveraendert,
    Object? einsatzabteilungD = _unveraendert,
  }) {
    int? wert(Object? neu, int? alt) =>
        identical(neu, _unveraendert) ? alt : neu as int?;
    return ManuelleAngaben(
      fragen: _fragen,
      arbeitWert11: wert(arbeitWert11, this.arbeitWert11),
      arbeitWert20: wert(arbeitWert20, this.arbeitWert20),
      einsatzabteilungM: wert(einsatzabteilungM, this.einsatzabteilungM),
      einsatzabteilungW: wert(einsatzabteilungW, this.einsatzabteilungW),
      einsatzabteilungD: wert(einsatzabteilungD, this.einsatzabteilungD),
    );
  }

  /// Persistierbare Form, siehe Klassendokumentation.
  Map<String, Object> toMap() => {
    for (final nummer in (_fragen.keys.toList()..sort()))
      _frageKey(nummer): _fragen[nummer]!,
    _wert11Key: ?arbeitWert11,
    _wert20Key: ?arbeitWert20,
    _eaMKey: ?einsatzabteilungM,
    _eaWKey: ?einsatzabteilungW,
    _eaDKey: ?einsatzabteilungD,
  };

  @override
  bool operator ==(Object other) =>
      other is ManuelleAngaben &&
      other._fragen.length == _fragen.length &&
      _fragen.entries.every((e) => other._fragen[e.key] == e.value) &&
      other.arbeitWert11 == arbeitWert11 &&
      other.arbeitWert20 == arbeitWert20 &&
      other.einsatzabteilungM == einsatzabteilungM &&
      other.einsatzabteilungW == einsatzabteilungW &&
      other.einsatzabteilungD == einsatzabteilungD;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(
      _fragen.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    arbeitWert11,
    arbeitWert20,
    einsatzabteilungM,
    einsatzabteilungW,
    einsatzabteilungD,
  );

  @override
  String toString() => 'ManuelleAngaben(${toMap()})';
}

const _wert11Key = 'Arbeit_Wert_11';
const _wert20Key = 'Arbeit_Wert_20';
const _eaMKey = 'Alter_Anz_EA_bis_27_M';
const _eaWKey = 'Alter_Anz_EA_bis_27_W';
const _eaDKey = 'Alter_Anz_EA_bis_27_D';
const _zahlSchluessel = {_wert11Key, _wert20Key, _eaMKey, _eaWKey, _eaDKey};

String _frageKey(int nummer) => 'Frage_${nummer.toString().padLeft(2, '0')}';

int? _frageNummer(String key) {
  final m = RegExp(r'^Frage_(\d\d)$').firstMatch(key);
  if (m == null) return null;
  final nummer = int.parse(m.group(1)!);
  RangeError.checkValueInInterval(nummer, 1, anzahlFragen, key);
  return nummer;
}

Map<int, bool> _pruefeFragen(Map<int, bool> fragen) {
  for (final nummer in fragen.keys) {
    RangeError.checkValueInInterval(nummer, 1, anzahlFragen, 'fragen');
  }
  return Map.of(fragen);
}

void _pruefeZahl(String name, int? wert) {
  if (wert != null && wert < 0) {
    throw ArgumentError.value(wert, name, 'darf nicht negativ sein');
  }
}
