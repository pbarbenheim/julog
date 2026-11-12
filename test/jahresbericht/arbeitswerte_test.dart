import 'package:flutter_test/flutter_test.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart' as b;

const _themenFelder = {
  Berichtsthema.feuerwehrtechnik: 'Arbeit_Wert_01',
  Berichtsthema.wettbewerbstraining: 'Arbeit_Wert_02',
  Berichtsthema.spieleUndKreatives: 'Arbeit_Wert_03',
  Berichtsthema.mitAnderemVereinOderGruppe: 'Arbeit_Wert_04',
  Berichtsthema.sport: 'Arbeit_Wert_05',
  Berichtsthema.ersteHilfeUndPraevention: 'Arbeit_Wert_06',
  Berichtsthema.sonstiges: 'Arbeit_Wert_07',
};

void main() {
  group('Arbeit_Wert_01 bis 07: Einträge je Berichtsthema', () {
    for (final entry in _themenFelder.entries) {
      test('${entry.key.display} zählt in ${entry.value}', () {
        final kat = b.kategorie(thema: entry.key);
        final w = b.bericht(
          2025,
          kategorien: [kat],
          eintraege: [
            b.eintrag(kategorie: kat),
            b.eintrag(kategorie: kat),
          ],
        );
        for (final feld in _themenFelder.values) {
          expect(w[feld], feld == entry.value ? 2 : 0, reason: feld);
        }
      });
    }

    test('mehrere Kategorien mit gleichem Thema werden summiert', () {
      final k1 = b.kategorie(thema: Berichtsthema.sport);
      final k2 = b.kategorie(thema: Berichtsthema.sport);
      final k3 = b.kategorie(thema: Berichtsthema.spieleUndKreatives);
      final w = b.bericht(
        2025,
        kategorien: [k1, k2, k3],
        eintraege: [
          b.eintrag(kategorie: k1),
          b.eintrag(kategorie: k2),
          b.eintrag(kategorie: k3),
        ],
      );
      expect(w['Arbeit_Wert_05'], 2);
      expect(w['Arbeit_Wert_03'], 1);
    });

    test('Kategorie ohne Berichtsthema zählt in keinem Thema', () {
      final kat = b.kategorie();
      final w = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: [b.eintrag(kategorie: kat)],
      );
      for (final feld in _themenFelder.values) {
        expect(w[feld], 0, reason: feld);
      }
    });

    test('Einträge außerhalb des Berichtsjahres zählen nicht', () {
      final kat = b.kategorie(thema: Berichtsthema.sport);
      final eintraege = [
        b.eintrag(kategorie: kat, start: DateTime(2024, 12, 31, 23, 59)),
        b.eintrag(kategorie: kat, start: DateTime(2025, 1, 1, 0, 0)),
        b.eintrag(kategorie: kat, start: DateTime(2025, 12, 31, 23, 59)),
        b.eintrag(kategorie: kat, start: DateTime(2026, 1, 1, 0, 0)),
      ];
      final w = b.bericht(2025, kategorien: [kat], eintraege: eintraege);
      expect(w['Arbeit_Wert_05'], 2);
    });

    test('signierte und unsignierte Einträge zählen gleich', () {
      final kat = b.kategorie(thema: Berichtsthema.sport);
      final w = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: [
          b.eintrag(kategorie: kat, isSigned: true),
          b.eintrag(kategorie: kat, isSigned: false),
        ],
      );
      expect(w['Arbeit_Wert_05'], 2);
    });
  });

  group('Arbeit_Wert_13: Tagesveranstaltungen', () {
    test('Dauer genau 5 Stunden zählt, 4:59 nicht', () {
      final w = b.bericht(
        2025,
        eintraege: [
          b.eintrag(
            start: DateTime(2025, 5, 5, 9),
            end: DateTime(2025, 5, 5, 14),
          ),
          b.eintrag(
            start: DateTime(2025, 5, 6, 9),
            end: DateTime(2025, 5, 6, 13, 59),
          ),
        ],
      );
      expect(w['Arbeit_Wert_13'], 1);
    });

    test('Tagesveranstaltungen zählen zusätzlich im Berichtsthema', () {
      final kat = b.kategorie(thema: Berichtsthema.sport);
      final w = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: [
          b.eintrag(
            kategorie: kat,
            start: DateTime(2025, 5, 5, 9),
            end: DateTime(2025, 5, 5, 17),
          ),
          b.eintrag(kategorie: kat),
        ],
      );
      expect(w['Arbeit_Wert_13'], 1);
      expect(w['Arbeit_Wert_05'], 2);
    });

    test('Einträge außerhalb des Berichtsjahres zählen nicht', () {
      final w = b.bericht(
        2025,
        eintraege: [
          b.eintrag(
            start: DateTime(2024, 5, 5, 9),
            end: DateTime(2024, 5, 5, 17),
          ),
        ],
      );
      expect(w['Arbeit_Wert_13'], 0);
    });
  });

  group('Arbeit_Wert_10: durchschnittliche Dauer in Minuten', () {
    Eintrag mitMinuten(int minuten) => b.eintrag(
      start: DateTime(2025, 5, 5, 18),
      end: DateTime(2025, 5, 5, 18).add(Duration(minutes: minuten)),
    );

    test('Mittelwert über alle Einträge des Jahres', () {
      final w = b.bericht(
        2025,
        eintraege: [
          mitMinuten(60),
          mitMinuten(120),
          mitMinuten(180),
          b.eintrag(
            start: DateTime(2024, 5, 5, 18),
            end: DateTime(2024, 5, 5, 23),
          ),
        ],
      );
      expect(w['Arbeit_Wert_10'], 120);
    });

    test('rundet x,5 auf', () {
      // (60 + 61) / 2 = 60,5
      final w = b.bericht(2025, eintraege: [mitMinuten(60), mitMinuten(61)]);
      expect(w['Arbeit_Wert_10'], 61);
    });

    test('rundet unter x,5 ab und über x,5 auf', () {
      // (60 + 60 + 61) / 3 = 60,33
      expect(
        b.bericht(
          2025,
          eintraege: [mitMinuten(60), mitMinuten(60), mitMinuten(61)],
        )['Arbeit_Wert_10'],
        60,
      );
      // (60 + 61 + 61) / 3 = 60,67
      expect(
        b.bericht(
          2025,
          eintraege: [mitMinuten(60), mitMinuten(61), mitMinuten(61)],
        )['Arbeit_Wert_10'],
        61,
      );
    });
  });

  group('Arbeit_Wert_12: durchschnittliche Betreuerzahl', () {
    Eintrag mitBetreuern(int anzahl) =>
        b.eintrag(betreuerIds: {for (var i = 0; i < anzahl; i++) 'bet-$i'});

    test('Mittelwert über alle Einträge des Jahres', () {
      final w = b.bericht(
        2025,
        eintraege: [
          mitBetreuern(1),
          mitBetreuern(2),
          mitBetreuern(3),
          b.eintrag(
            start: DateTime(2026, 1, 1),
            betreuerIds: {'a', 'b', 'c', 'd', 'e', 'f'},
          ),
        ],
      );
      expect(w['Arbeit_Wert_12'], 2);
    });

    test('Einträge ohne Betreuer zählen mit 0 in den Durchschnitt', () {
      final w = b.bericht(
        2025,
        eintraege: [mitBetreuern(3), mitBetreuern(0), mitBetreuern(0)],
      );
      expect(w['Arbeit_Wert_12'], 1);
    });

    test('rundet x,5 auf', () {
      // (1 + 2) / 2 = 1,5
      final w = b.bericht(2025, eintraege: [mitBetreuern(1), mitBetreuern(2)]);
      expect(w['Arbeit_Wert_12'], 2);
    });

    test('rundet unter x,5 ab', () {
      // (1 + 1 + 2) / 3 = 1,33
      final w = b.bericht(
        2025,
        eintraege: [mitBetreuern(1), mitBetreuern(1), mitBetreuern(2)],
      );
      expect(w['Arbeit_Wert_12'], 1);
    });
  });

  group('Jahr ohne Einträge', () {
    test('liefert 0 für alle Arbeitswerte', () {
      final kat = b.kategorie(thema: Berichtsthema.sport);
      final w = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: [b.eintrag(kategorie: kat, start: DateTime(2024, 5, 5))],
      );
      for (final feld in [
        ...List.generate(7, (i) => 'Arbeit_Wert_0${i + 1}'),
        'Arbeit_Wert_10',
        'Arbeit_Wert_12',
        'Arbeit_Wert_13',
      ]) {
        expect(w[feld], 0, reason: feld);
      }
    });
  });

  test('Arbeit_Wert_08, 09 und 14 bis 19 kommen nicht vor', () {
    final w = b.bericht(2025);
    for (final nr in ['08', '09', '14', '15', '16', '17', '18', '19']) {
      expect(w.felder.containsKey('Arbeit_Wert_$nr'), isFalse, reason: nr);
    }
  });
}
