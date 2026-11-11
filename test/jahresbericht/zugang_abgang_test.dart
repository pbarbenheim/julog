import 'package:flutter_test/flutter_test.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart';

const _soGrundFelder = [
  'Grund_SO_Wohnort',
  'Grund_SO_Interesse',
  'Grund_SO_Schule',
  'Grund_SO_Beruf',
  'Grund_SO_Verweis',
  'Grund_SO_Übernahme',
];

void main() {
  group('Zugang nach Herkunft', () {
    test('Neu, AO und KF werden getrennt nach Geschlecht gezählt', () {
      final tag = DateTime(2025, 4, 1);
      final b = bericht(
        2025,
        jugendliche: [
          jug(herkunft: Herkunft.neu, memberSince: tag),
          jug(herkunft: Herkunft.neu, memberSince: tag, gender: Gender.female),
          jug(herkunft: Herkunft.andereOrganisation, memberSince: tag),
          jug(
            herkunft: Herkunft.andereOrganisation,
            memberSince: tag,
            gender: Gender.diverse,
          ),
          jug(
            herkunft: Herkunft.kinderfeuerwehr,
            memberSince: tag,
            gender: Gender.female,
          ),
          jug(
            herkunft: Herkunft.kinderfeuerwehr,
            memberSince: tag,
            gender: Gender.female,
          ),
        ],
      );
      expect(b['Zugang_Anz_Neu_M'], 1);
      expect(b['Zugang_Anz_Neu_W'], 1);
      expect(b['Zugang_Anz_Neu_D'], 0);
      expect(b['Zugang_Anz_AO_M'], 1);
      expect(b['Zugang_Anz_AO_W'], 0);
      expect(b['Zugang_Anz_AO_D'], 1);
      expect(b['Zugang_Anz_KF_M'], 0);
      expect(b['Zugang_Anz_KF_W'], 2);
      expect(b['Zugang_Anz_KF_D'], 0);
    });

    test('Zugang außerhalb des Berichtsjahres wird nicht gezählt', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            herkunft: Herkunft.kinderfeuerwehr,
            memberSince: DateTime(2024, 6, 1),
          ),
        ],
      );
      expect(b['Zugang_Anz_KF_M'], 0);
    });

    test('im selben Jahr eingetreten und ausgetreten: Zugang und Abgang, '
        'aber kein Mitglied', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            herkunft: Herkunft.andereOrganisation,
            memberSince: DateTime(2025, 2, 1),
            exitDate: DateTime(2025, 9, 1),
            exitReason: AustrittsGrund.noInterest,
          ),
        ],
      );
      expect(b['Zugang_Anz_AO_M'], 1);
      expect(b['Abgang_Anz_SO_M'], 1);
      expect(b['Mitglieder_Anz_M'], 0);
    });
  });

  group('Abgang', () {
    Jugendlicher mitGrund(AustrittsGrund grund, {Gender g = Gender.male}) =>
        jug(gender: g, exitDate: DateTime(2025, 7, 1), exitReason: grund);

    test('Uebernahme ergibt Abgang EA und keinen SO-Grund', () {
      final b = bericht(
        2025,
        jugendliche: [mitGrund(AustrittsGrund.uebernahme)],
      );
      expect(b['Abgang_Anz_EA_M'], 1);
      expect(b['Abgang_Anz_SO_M'], 0);
      for (final feld in _soGrundFelder) {
        expect(b[feld], 0, reason: feld);
      }
    });

    final zuordnung = {
      AustrittsGrund.wohnortwechsel: 'Grund_SO_Wohnort',
      AustrittsGrund.noInterest: 'Grund_SO_Interesse',
      AustrittsGrund.schule: 'Grund_SO_Schule',
      AustrittsGrund.ausbildung: 'Grund_SO_Beruf',
      AustrittsGrund.ausschluss: 'Grund_SO_Verweis',
      AustrittsGrund.noUebernahme: 'Grund_SO_Übernahme',
    };

    test('jeder AustrittsGrund ist einem Ziel zugeordnet', () {
      expect({
        ...zuordnung.keys,
        AustrittsGrund.uebernahme,
      }, AustrittsGrund.values.toSet());
    });

    for (final entry in zuordnung.entries) {
      test('${entry.key.name} ergibt Abgang SO und ${entry.value}', () {
        final b = bericht(
          2025,
          jugendliche: [mitGrund(entry.key, g: Gender.female)],
        );
        expect(b['Abgang_Anz_SO_W'], 1);
        expect(b['Abgang_Anz_EA_W'], 0);
        for (final feld in _soGrundFelder) {
          expect(b[feld], feld == entry.value ? 1 : 0, reason: feld);
        }
      });
    }

    test('Abgang EA wird nach Geschlecht getrennt gezählt', () {
      final b = bericht(
        2025,
        jugendliche: [
          mitGrund(AustrittsGrund.uebernahme, g: Gender.male),
          mitGrund(AustrittsGrund.uebernahme, g: Gender.female),
          mitGrund(AustrittsGrund.uebernahme, g: Gender.female),
          mitGrund(AustrittsGrund.uebernahme, g: Gender.diverse),
        ],
      );
      expect(b['Abgang_Anz_EA_M'], 1);
      expect(b['Abgang_Anz_EA_W'], 2);
      expect(b['Abgang_Anz_EA_D'], 1);
    });

    test('SO-Gründe sind Gesamtzahlen ohne Geschlechtertrennung', () {
      final b = bericht(
        2025,
        jugendliche: [
          mitGrund(AustrittsGrund.schule, g: Gender.male),
          mitGrund(AustrittsGrund.schule, g: Gender.female),
          mitGrund(AustrittsGrund.schule, g: Gender.diverse),
          mitGrund(AustrittsGrund.ausbildung),
        ],
      );
      expect(b['Grund_SO_Schule'], 3);
      expect(b['Grund_SO_Beruf'], 1);
      expect(b['Abgang_Anz_SO_M'], 2);
      expect(b['Abgang_Anz_SO_W'], 1);
      expect(b['Abgang_Anz_SO_D'], 1);
    });

    test('Abgänge außerhalb des Berichtsjahres werden nicht gezählt', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            exitDate: DateTime(2024, 12, 31),
            exitReason: AustrittsGrund.schule,
          ),
          jug(
            exitDate: DateTime(2026, 1, 1),
            exitReason: AustrittsGrund.schule,
          ),
        ],
      );
      expect(b['Grund_SO_Schule'], 0);
      expect(b['Abgang_Anz_SO_M'], 0);
    });

    test('Abgang am 1.1. des Berichtsjahres zählt', () {
      final b = bericht(
        2025,
        jugendliche: [
          jug(
            exitDate: DateTime(2025, 1, 1),
            exitReason: AustrittsGrund.uebernahme,
          ),
        ],
      );
      expect(b['Abgang_Anz_EA_M'], 1);
    });
  });

  group('Ersetzungskette', () {
    test('Namensänderung ergibt genau ein Mitglied', () {
      final neu = jug(
        gender: Gender.female,
        birthDate: DateTime(2013, 5, 1),
        memberSince: DateTime(2022, 3, 1),
        replacesId: 'alt',
      );
      final alt = jug(
        gender: Gender.female,
        birthDate: DateTime(2013, 5, 1),
        memberSince: DateTime(2022, 3, 1),
        replacedBy: neu,
      );
      final b = bericht(2025, jugendliche: [alt, neu]);
      expect(b['Mitglieder_Anz_W'], 1);
      expect(b['Alter_Anz_12_W'], 1);
    });

    test('Namensänderung im Zugangsjahr ergibt genau einen Zugang', () {
      final neu = jug(
        memberSince: DateTime(2025, 3, 1),
        herkunft: Herkunft.kinderfeuerwehr,
        replacesId: 'alt',
      );
      final alt = jug(
        memberSince: DateTime(2025, 3, 1),
        herkunft: Herkunft.kinderfeuerwehr,
        replacedBy: neu,
      );
      final b = bericht(2025, jugendliche: [alt, neu]);
      expect(b['Zugang_Anz_KF_M'], 1);
      expect(b['Mitglieder_Anz_M'], 1);
    });

    test('Austritt des aktuellen Datensatzes ergibt genau einen Abgang', () {
      final neu = jug(
        memberSince: DateTime(2021, 3, 1),
        exitDate: DateTime(2025, 8, 1),
        exitReason: AustrittsGrund.uebernahme,
        replacesId: 'alt',
      );
      final alt = jug(memberSince: DateTime(2021, 3, 1), replacedBy: neu);
      final b = bericht(2025, jugendliche: [alt, neu]);
      expect(b['Abgang_Anz_EA_M'], 1);
      expect(b['Mitglieder_Anz_M'], 0);
    });

    test('mehrgliedrige Kette ergibt genau ein Mitglied', () {
      final c = jug(replacesId: 'b');
      final b2 = jug(replacedBy: c, replacesId: 'a');
      final a = jug(replacedBy: b2);
      expect(bericht(2025, jugendliche: [a, b2, c])['Mitglieder_Anz_M'], 1);
    });
  });
}
