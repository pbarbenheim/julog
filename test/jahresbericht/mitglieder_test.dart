import 'package:flutter_test/flutter_test.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart';

void main() {
  group('Mitglieder am Stichtag', () {
    test('ohne Daten sind alle Mitgliederzahlen 0', () {
      final b = bericht(2025);
      expect(b['Mitglieder_Anz_M'], 0);
      expect(b['Mitglieder_Anz_W'], 0);
      expect(b['Mitglieder_Anz_D'], 0);
    });

    test('Mitglieder werden nach Geschlecht getrennt gezählt', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(gender: Gender.male),
          jug(gender: Gender.male),
          jug(gender: Gender.female),
          jug(gender: Gender.diverse),
          jug(gender: Gender.diverse),
          jug(gender: Gender.diverse),
        ],
      );
      expect(b['Mitglieder_Anz_M'], 2);
      expect(b['Mitglieder_Anz_W'], 1);
      expect(b['Mitglieder_Anz_D'], 3);
    });

    test('Eintritt am 31.12. zählt als Mitglied und Zugang', () {
      final b = bericht(
        2025,
        jugendliche: [jug(memberSince: DateTime(2025, 12, 31))],
      );
      expect(b['Mitglieder_Anz_M'], 1);
      expect(b['Zugang_Anz_Neu_M'], 1);
    });

    test('Eintritt am 1.1. des Folgejahres zählt weder noch', () {
      final b = bericht(
        2025,
        jugendliche: [jug(memberSince: DateTime(2026, 1, 1))],
      );
      expect(b['Mitglieder_Anz_M'], 0);
      expect(b['Zugang_Anz_Neu_M'], 0);
    });

    test('Eintritt am 1.1. des Berichtsjahres zählt als Zugang', () {
      final b = bericht(
        2025,
        jugendliche: [jug(memberSince: DateTime(2025, 1, 1))],
      );
      expect(b['Mitglieder_Anz_M'], 1);
      expect(b['Zugang_Anz_Neu_M'], 1);
    });

    test('Eintritt am 31.12. des Vorjahres ist kein Zugang', () {
      final b = bericht(
        2025,
        jugendliche: [jug(memberSince: DateTime(2024, 12, 31))],
      );
      expect(b['Mitglieder_Anz_M'], 1);
      expect(b['Zugang_Anz_Neu_M'], 0);
    });

    test('Austritt genau am Stichtag: nur Abgang, kein Mitglied', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            exitDate: DateTime(2025, 12, 31),
            exitReason: AustrittsGrund.uebernahme,
          ),
        ],
      );
      expect(b['Mitglieder_Anz_M'], 0);
      expect(b['Abgang_Anz_EA_M'], 1);
    });

    test('Austritt am Tag nach dem Stichtag: Mitglied, kein Abgang', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            exitDate: DateTime(2026, 1, 1),
            exitReason: AustrittsGrund.uebernahme,
          ),
        ],
      );
      expect(b['Mitglieder_Anz_M'], 1);
      expect(b['Abgang_Anz_EA_M'], 0);
    });

    test('Austritt vor dem Berichtsjahr: weder Mitglied noch Abgang', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            exitDate: DateTime(2024, 12, 31),
            exitReason: AustrittsGrund.schule,
          ),
        ],
      );
      expect(b['Mitglieder_Anz_M'], 0);
      expect(b['Abgang_Anz_SO_M'], 0);
    });

    test('Uhrzeiten in Datumsfeldern ändern das Ergebnis nicht', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(memberSince: DateTime(2025, 12, 31, 23, 59)),
          jug(
            exitDate: DateTime(2025, 12, 31, 0, 0, 1),
            exitReason: AustrittsGrund.schule,
          ),
        ],
      );
      expect(b['Mitglieder_Anz_M'], 1);
    });

    test('vergangene Berichtsjahre ergeben sich aus den Stammdaten', () {
      final jugendliche = [
        jug(
          memberSince: DateTime(2019, 3, 1),
          exitDate: DateTime(2022, 6, 1),
          exitReason: AustrittsGrund.schule,
        ),
      ];
      expect(bericht(2021, jugendliche: jugendliche)['Mitglieder_Anz_M'], 1);
      expect(bericht(2022, jugendliche: jugendliche)['Mitglieder_Anz_M'], 0);
      expect(bericht(2022, jugendliche: jugendliche)['Abgang_Anz_SO_M'], 1);
    });
  });
}
