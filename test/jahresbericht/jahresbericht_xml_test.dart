import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:julog/jahresbericht/jahresbericht_xml.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart' as b;

/// Schlüssel -> Wert (`null` für leere Felder) in Dokumentreihenfolge. Die
/// Fixture schreibt Umlaute als Zeichenreferenz (`&#xDC;`); diese werden
/// aufgelöst.
List<MapEntry<String, int?>> _parseFelder(String xml) {
  String decode(String s) => s.replaceAllMapped(
    RegExp(r'&#x([0-9A-Fa-f]+);'),
    (r) => String.fromCharCode(int.parse(r.group(1)!, radix: 16)),
  );
  return [
    for (final m in RegExp(
      r'<field key="([^"]+)"(?:/>|>([^<]*)</field>)',
    ).allMatches(xml))
      MapEntry(
        decode(m.group(1)!),
        m.group(2) == null || m.group(2)!.isEmpty
            ? null
            : int.parse(m.group(2)!),
      ),
  ];
}

Map<String, int?> _felder(String xml) => Map.fromEntries(_parseFelder(xml));

const _jahr = 2025;

/// Antworten der Beispiel-Fixture (Ja = true).
const _jaFragen = {1, 2, 3, 5, 6, 7, 8, 10};

ManuelleAngaben _fixtureAngaben() {
  var a = ManuelleAngaben(
    arbeitWert11: 60,
    arbeitWert20: 230,
    einsatzabteilungM: 15,
    einsatzabteilungW: 10,
    einsatzabteilungD: 0,
  );
  for (var n = 1; n <= 16; n++) {
    a = a.withFrage(n, _jaFragen.contains(n));
  }
  return a;
}

/// Domänendaten, die die Zählwerte und Arbeitswerte der Fixture ergeben.
class _Daten {
  final List<Jugendlicher> jugendliche = [];
  final List<Betreuer> betreuer = [];
  final List<Eintrag> eintraege = [];
  final List<Kategorie> kategorien = [];

  _Daten() {
    // Mitglieder: Anzahl je Alter 10..18, (männlich, weiblich).
    const alter = {
      10: (4, 3),
      11: (7, 6),
      12: (14, 6),
      13: (2, 3),
      14: (6, 3),
      15: (5, 1),
      16: (8, 1),
      17: (5, 0),
      18: (2, 1),
    };
    var neuM = 10;
    var neuW = 4;
    for (final e in alter.entries) {
      final geburt = DateTime(_jahr - e.key, 6, 15);
      for (var i = 0; i < e.value.$1; i++) {
        jugendliche.add(
          b.jug(
            gender: Gender.male,
            birthDate: geburt,
            memberSince: neuM-- > 0 ? DateTime(_jahr, 3, 1) : null,
          ),
        );
      }
      for (var i = 0; i < e.value.$2; i++) {
        jugendliche.add(
          b.jug(
            gender: Gender.female,
            birthDate: geburt,
            memberSince: neuW-- > 0 ? DateTime(_jahr, 3, 1) : null,
          ),
        );
      }
    }
    // Zwei Übernahmen in die Einsatzabteilung.
    for (var i = 0; i < 2; i++) {
      jugendliche.add(
        b.jug(
          birthDate: DateTime(2007, 6, 15),
          exitDate: DateTime(_jahr, 9, 1),
          exitReason: AustrittsGrund.uebernahme,
        ),
      );
    }

    betreuer
      ..addAll([for (var i = 0; i < 17; i++) b.betreuer(Gender.male)])
      ..addAll([for (var i = 0; i < 5; i++) b.betreuer(Gender.female)]);
    final betreuerIds = {for (final x in betreuer) x.id};

    // Einträge je Berichtsthema (Arbeit_Wert_01, 03, 04, 05, 06, 07).
    const proThema = {
      Berichtsthema.feuerwehrtechnik: 248,
      Berichtsthema.spieleUndKreatives: 15,
      Berichtsthema.mitAnderemVereinOderGruppe: 10,
      Berichtsthema.sport: 5,
      Berichtsthema.ersteHilfeUndPraevention: 14,
      Berichtsthema.sonstiges: 5,
    };
    var tage = 14;
    for (final e in proThema.entries) {
      final kat = b.kategorie(thema: e.key);
      kategorien.add(kat);
      for (var i = 0; i < e.value; i++) {
        final start = DateTime(_jahr, 5, 5, 18);
        final lang = e.key == Berichtsthema.feuerwehrtechnik && tage-- > 0;
        eintraege.add(
          b.eintrag(
            kategorie: kat,
            start: start,
            end: start.add(
              lang ? const Duration(hours: 5) : const Duration(minutes: 80),
            ),
            betreuerIds: betreuerIds,
          ),
        );
      }
    }
  }
}

String _xml({
  _Daten? daten,
  ManuelleAngaben? angaben,
  Map<String, int> ueberschreibungen = const {},
}) {
  final d = daten ?? _Daten();
  return erzeugeJahresberichtXml(
    berichtsjahr: _jahr,
    jugendliche: d.jugendliche,
    betreuer: d.betreuer,
    eintraege: d.eintraege,
    kategorien: d.kategorien,
    angaben: angaben ?? _fixtureAngaben(),
    ueberschreibungen: Ueberschreibungen(ueberschreibungen),
  );
}

void main() {
  final fixture = _parseFelder(
    File('test/fixtures/jahresbericht_beispiel.xml').readAsStringSync(),
  );

  group('erzeugeJahresberichtXml', () {
    test(
      'ist inhaltlich gleich der Beispiel-Fixture (außer Organisationen)',
      () {
        final erzeugt = _felder(_xml());
        final erwartet = Map.fromEntries(fixture);
        expect(erzeugt.keys, unorderedEquals(erwartet.keys));
        for (final e in erwartet.entries) {
          if (e.key == 'Organisationen') continue;
          expect(erzeugt[e.key], e.value, reason: e.key);
        }
      },
    );

    test('Organisationen ist immer 1', () {
      expect(_felder(_xml())['Organisationen'], 1);
    });

    test('Felder stehen in der Reihenfolge der Beispiel-Fixture', () {
      expect(
        _parseFelder(_xml()).map((e) => e.key).toList(),
        fixture.map((e) => e.key).toList(),
      );
    });

    test(
      'jede Frage hat genau eines von _JA/_NEIN mit 1, das andere mit 0',
      () {
        final felder = _felder(_xml());
        for (var n = 1; n <= 16; n++) {
          final nn = n.toString().padLeft(2, '0');
          final ja = felder['Frage_${nn}_MML_JA'];
          final nein = felder['Frage_${nn}_MML_NEIN'];
          expect(ja, _jaFragen.contains(n) ? 1 : 0, reason: 'Frage $n JA');
          expect(nein, _jaFragen.contains(n) ? 0 : 1, reason: 'Frage $n NEIN');
        }
      },
    );

    test('nicht ausgegebene Arbeitswerte 08, 09 und 14 bis 19 fehlen', () {
      final felder = _felder(_xml());
      for (final n in [8, 9, 14, 15, 16, 17, 18, 19]) {
        expect(
          felder.containsKey('Arbeit_Wert_${n.toString().padLeft(2, '0')}'),
          isFalse,
          reason: 'Arbeit_Wert_$n',
        );
      }
    });

    test('manuelle Angaben erscheinen im XML', () {
      final felder = _felder(
        _xml(
          angaben: _fixtureAngaben().copyWith(
            arbeitWert11: 45,
            arbeitWert20: 12,
            einsatzabteilungM: 1,
            einsatzabteilungW: 2,
            einsatzabteilungD: 3,
          ),
        ),
      );
      expect(felder['Arbeit_Wert_11'], 45);
      expect(felder['Arbeit_Wert_20'], 12);
      expect(felder['Alter_Anz_EA_bis_27_M'], 1);
      expect(felder['Alter_Anz_EA_bis_27_W'], 2);
      expect(felder['Alter_Anz_EA_bis_27_D'], 3);
    });

    test('Überschreibungen von Arbeitswerten gelten im XML', () {
      final felder = _felder(_xml(ueberschreibungen: {'Arbeit_Wert_13': 3}));
      expect(felder['Arbeit_Wert_13'], 3);
      expect(felder['Arbeit_Wert_01'], 248);
    });

    test('Umlaute stehen in Schlüsseln als echte Zeichen', () {
      final xml = _xml();
      expect(xml, contains('key="Grund_SO_Übernahme"'));
      expect(xml, contains('key="Alter_Anz_über_18_M"'));
      expect(xml, isNot(contains('&#x')));
    });

    test('ist ein UTF-8-Dokument mit Wurzelelement xml', () {
      final xml = _xml();
      expect(xml, startsWith('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(xml.trimRight(), endsWith('</xml>'));
      expect(xml, contains('<xml>'));
    });

    test('Bytes sind UTF-8 und ergeben dasselbe Dokument', () {
      final d = _Daten();
      final bytes = erzeugeJahresberichtXmlBytes(
        berichtsjahr: _jahr,
        jugendliche: d.jugendliche,
        betreuer: d.betreuer,
        eintraege: d.eintraege,
        kategorien: d.kategorien,
        angaben: _fixtureAngaben(),
      );
      final text = utf8.decode(bytes);
      expect(text, _xml(daten: d));
      // Ü = U+00DC = C3 9C in UTF-8, ü = C3 BC.
      final ue = utf8.encode('key="Grund_SO_Ü');
      expect(_enthaelt(bytes, ue), isTrue);
      expect(_felder(text)['Alter_Anz_über_18_M'], 0);
    });

    test('unvollständige Angaben werden mit der Prüfung abgelehnt', () {
      try {
        _xml(angaben: _fixtureAngaben().withFrage(7, null));
        fail('UnvollstaendigerBerichtException erwartet');
      } on UnvollstaendigerBerichtException catch (e) {
        expect(e.vollstaendigkeit.istVollstaendig, isFalse);
        expect(e.vollstaendigkeit.fehlendeFragen, [7]);
      }
    });

    test('benutzte Kategorie ohne Berichtsthema wird abgelehnt', () {
      final d = _Daten();
      final ohne = b.kategorie();
      d.kategorien.add(ohne);
      d.eintraege.add(b.eintrag(kategorie: ohne));
      expect(
        () => _xml(daten: d),
        throwsA(isA<UnvollstaendigerBerichtException>()),
      );
    });
  });
}

bool _enthaelt(List<int> haystack, List<int> needle) {
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var ok = true;
    for (var j = 0; j < needle.length && ok; j++) {
      ok = haystack[i + j] == needle[j];
    }
    if (ok) return true;
  }
  return false;
}
