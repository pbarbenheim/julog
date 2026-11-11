import 'package:flutter_test/flutter_test.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart' as b;

const _ueberschreibbar = [
  'Arbeit_Wert_01',
  'Arbeit_Wert_02',
  'Arbeit_Wert_03',
  'Arbeit_Wert_04',
  'Arbeit_Wert_05',
  'Arbeit_Wert_06',
  'Arbeit_Wert_07',
  'Arbeit_Wert_10',
  'Arbeit_Wert_12',
  'Arbeit_Wert_13',
];

void main() {
  group('Überschreibungen', () {
    for (final feld in _ueberschreibbar) {
      test('$feld lässt sich überschreiben', () {
        final kat = b.kategorie(thema: Berichtsthema.sport);
        final eintraege = [b.eintrag(kategorie: kat)];
        final berechnet = b.bericht(
          2025,
          kategorien: [kat],
          eintraege: eintraege,
        );
        final w = b.bericht(
          2025,
          kategorien: [kat],
          eintraege: eintraege,
          ueberschreibungen: {feld: 4242},
        );
        expect(w[feld], 4242);
        expect(berechnet[feld], isNot(4242));
      });
    }

    test('andere Felder bleiben unverändert', () {
      final kat = b.kategorie(thema: Berichtsthema.sport);
      final eintraege = [b.eintrag(kategorie: kat)];
      final berechnet = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: eintraege,
      );
      final w = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: eintraege,
        ueberschreibungen: {'Arbeit_Wert_05': 9},
      );
      expect(w['Arbeit_Wert_10'], berechnet['Arbeit_Wert_10']);
      expect(w['Arbeit_Wert_13'], berechnet['Arbeit_Wert_13']);
    });

    test('0 ist ein gültiger Überschreibungswert', () {
      final kat = b.kategorie(thema: Berichtsthema.sport);
      final w = b.bericht(
        2025,
        kategorien: [kat],
        eintraege: [b.eintrag(kategorie: kat)],
        ueberschreibungen: {'Arbeit_Wert_05': 0},
      );
      expect(w['Arbeit_Wert_05'], 0);
    });

    test('ohne Einträge ersetzt die Überschreibung den Wert 0', () {
      final w = b.bericht(2025, ueberschreibungen: {'Arbeit_Wert_10': 90});
      expect(w['Arbeit_Wert_10'], 90);
    });

    test('Zählwerte lassen sich nicht überschreiben', () {
      for (final feld in [
        'Mitglieder_Anz_M',
        'Betreuer_Anz_W',
        'Zugang_Anz_Neu_D',
        'Abgang_Anz_SO_M',
        'Grund_SO_Wohnort',
        'Alter_Anz_über_18_W',
        'Alter_Anz_05_M',
      ]) {
        expect(
          () => Ueberschreibungen({feld: 1}),
          throwsArgumentError,
          reason: feld,
        );
      }
    });

    test('manuelle und nicht berichtete Felder sind nicht überschreibbar', () {
      for (final feld in [
        'Arbeit_Wert_08',
        'Arbeit_Wert_09',
        'Arbeit_Wert_11',
        'Arbeit_Wert_14',
        'Arbeit_Wert_20',
        'Unbekannt',
      ]) {
        expect(
          () => Ueberschreibungen({feld: 1}),
          throwsArgumentError,
          reason: feld,
        );
      }
    });

    test('negative Werte werden abgelehnt', () {
      expect(
        () => Ueberschreibungen({'Arbeit_Wert_01': -1}),
        throwsArgumentError,
      );
    });

    test('ist als einfache Map serialisierbar und unveränderlich', () {
      final quelle = {'Arbeit_Wert_01': 3, 'Arbeit_Wert_13': 1};
      final u = Ueberschreibungen(quelle);
      quelle['Arbeit_Wert_01'] = 99;
      expect(u.toMap(), {'Arbeit_Wert_01': 3, 'Arbeit_Wert_13': 1});
      expect(() => u.toMap()['Arbeit_Wert_01'] = 5, throwsUnsupportedError);
      expect(Ueberschreibungen(u.toMap()), u);
      expect(const Ueberschreibungen.keine().toMap(), isEmpty);
    });
  });
}
