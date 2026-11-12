import 'package:flutter_test/flutter_test.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart';

void main() {
  group('Alter der Mitglieder in vollen Jahren am Stichtag', () {
    Berichtswert mitGeburtstag(DateTime birth, {Gender gender = Gender.male}) =>
        bericht(
          2025,
          jugendliche: [jug(birthDate: birth, gender: gender)],
        );

    List<String> belegteAltersfelder(Berichtswert b) => b.felder.entries
        .where((e) => e.key.startsWith('Alter_Anz_') && e.value > 0)
        .map((e) => e.key)
        .toList();

    test(
      'jedes einzelne Alter 5 bis 18 hat ein eigenes zweistelliges Feld',
      () {
        for (var alter = 5; alter <= 18; alter++) {
          final b = mitGeburtstag(DateTime(2025 - alter, 6, 15));
          final key = 'Alter_Anz_${alter.toString().padLeft(2, '0')}_M';
          expect(belegteAltersfelder(b), [key], reason: 'Alter $alter');
          expect(b[key], 1, reason: 'Alter $alter');
        }
      },
    );

    test('Geburtstag am Stichtag: Alter ist bereits erreicht', () {
      final b = mitGeburtstag(DateTime(2015, 12, 31));
      expect(b['Alter_Anz_10_M'], 1);
      expect(b['Alter_Anz_09_M'], 0);
    });

    test('Geburtstag am Tag nach dem Stichtag: Alter noch nicht erreicht', () {
      final b = mitGeburtstag(DateTime(2016, 1, 1));
      expect(b['Alter_Anz_09_M'], 1);
      expect(b['Alter_Anz_10_M'], 0);
    });

    test('Geburtstag am 29.2. ist am Stichtag erreicht', () {
      final b = mitGeburtstag(DateTime(2012, 2, 29));
      expect(b['Alter_Anz_13_M'], 1);
    });

    test('unter 5: 4 Jahre und 0 Jahre, 5 Jahre ist schon einzeln', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(birthDate: DateTime(2021, 1, 1)),
          jug(birthDate: DateTime(2025, 3, 1)),
          jug(birthDate: DateTime(2020, 12, 31)),
        ],
      );
      expect(b['Alter_Anz_unter_5_M'], 2);
      expect(b['Alter_Anz_05_M'], 1);
    });

    test('4 Jahre minus ein Tag bis zum fünften Geburtstag ist unter 5', () {
      final b = mitGeburtstag(DateTime(2021, 1, 1));
      expect(b['Alter_Anz_unter_5_M'], 1);
      expect(b['Alter_Anz_05_M'], 0);
    });

    test('über 18: ab 19 Jahren, 18 bleibt einzeln', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(birthDate: DateTime(2006, 12, 31)), // genau 19
          jug(birthDate: DateTime(2006, 1, 1)),
          jug(birthDate: DateTime(2000, 1, 1)),
          jug(birthDate: DateTime(2007, 1, 1)), // 18
          jug(birthDate: DateTime(2007, 1, 2)), // 18
        ],
      );
      expect(b['Alter_Anz_über_18_M'], 3);
      expect(b['Alter_Anz_18_M'], 2);
    });

    test('Altersfelder werden nach Geschlecht getrennt', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(gender: Gender.male, birthDate: DateTime(2013, 5, 1)),
          jug(gender: Gender.female, birthDate: DateTime(2013, 5, 1)),
          jug(gender: Gender.female, birthDate: DateTime(2013, 5, 1)),
          jug(gender: Gender.diverse, birthDate: DateTime(2000, 5, 1)),
          jug(gender: Gender.diverse, birthDate: DateTime(2022, 5, 1)),
        ],
      );
      expect(b['Alter_Anz_12_M'], 1);
      expect(b['Alter_Anz_12_W'], 2);
      expect(b['Alter_Anz_12_D'], 0);
      expect(b['Alter_Anz_über_18_D'], 1);
      expect(b['Alter_Anz_unter_5_D'], 1);
    });

    test('Nichtmitglieder werden nicht nach Alter gezählt', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            birthDate: DateTime(2013, 5, 1),
            exitDate: DateTime(2025, 12, 31),
            exitReason: AustrittsGrund.schule,
          ),
          jug(
            birthDate: DateTime(2013, 5, 1),
            memberSince: DateTime(2026, 1, 1),
          ),
        ],
      );
      expect(belegteAltersfelder(b), isEmpty);
    });

    test('Alter wird für das gewählte Berichtsjahr berechnet', () {
      final j = jug(birthDate: DateTime(2010, 6, 1));
      expect(bericht(2020, jugendliche: [j])['Alter_Anz_10_M'], 1);
      expect(bericht(2025, jugendliche: [j])['Alter_Anz_15_M'], 1);
    });
  });
}
