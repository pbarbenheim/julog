import 'package:flutter_test/flutter_test.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart' as b;

void main() {
  group('Betreuer', () {
    test('zählt nur Betreuer mit mindestens einem Eintrag des Jahres', () {
      final anna = b.betreuer(Gender.female);
      final bernd = b.betreuer(Gender.male);
      final chris = b.betreuer(Gender.diverse);
      final dora = b.betreuer(Gender.female);
      final w = b.bericht(
        2025,
        betreuer: [anna, bernd, chris, dora],
        eintraege: [
          b.eintrag(betreuerIds: {anna.id, bernd.id}),
          b.eintrag(betreuerIds: {anna.id, chris.id}),
        ],
      );
      expect(w['Betreuer_Anz_W'], 1);
      expect(w['Betreuer_Anz_M'], 1);
      expect(w['Betreuer_Anz_D'], 1);
    });

    test('ein Betreuer in mehreren Einträgen zählt einmal', () {
      final anna = b.betreuer(Gender.female);
      final w = b.bericht(
        2025,
        betreuer: [anna],
        eintraege: [
          b.eintrag(betreuerIds: {anna.id}),
          b.eintrag(betreuerIds: {anna.id}),
          b.eintrag(betreuerIds: {anna.id}),
        ],
      );
      expect(w['Betreuer_Anz_W'], 1);
    });

    test('Einträge außerhalb des Berichtsjahres zählen nicht', () {
      final anna = b.betreuer(Gender.female);
      final w = b.bericht(
        2025,
        betreuer: [anna],
        eintraege: [
          b.eintrag(
            start: DateTime(2024, 12, 31, 23, 59),
            betreuerIds: {anna.id},
          ),
          b.eintrag(start: DateTime(2026, 1, 1), betreuerIds: {anna.id}),
        ],
      );
      expect(w['Betreuer_Anz_W'], 0);
    });

    test('Eintrag am 1.1. und am 31.12. des Berichtsjahres zählt', () {
      final anna = b.betreuer(Gender.female);
      final bernd = b.betreuer(Gender.male);
      final w = b.bericht(
        2025,
        betreuer: [anna, bernd],
        eintraege: [
          b.eintrag(start: DateTime(2025, 1, 1, 0, 0), betreuerIds: {anna.id}),
          b.eintrag(
            start: DateTime(2025, 12, 31, 23, 59),
            betreuerIds: {bernd.id},
          ),
        ],
      );
      expect(w['Betreuer_Anz_W'], 1);
      expect(w['Betreuer_Anz_M'], 1);
    });

    test('maßgeblich ist der Beginn des Eintrags', () {
      final anna = b.betreuer(Gender.female);
      final ueberJahreswechsel = b.eintrag(
        start: DateTime(2025, 12, 31, 22),
        end: DateTime(2026, 1, 1, 1),
        betreuerIds: {anna.id},
      );
      expect(
        b.bericht(
          2025,
          betreuer: [anna],
          eintraege: [ueberJahreswechsel],
        )['Betreuer_Anz_W'],
        1,
      );
      expect(
        b.bericht(
          2026,
          betreuer: [anna],
          eintraege: [ueberJahreswechsel],
        )['Betreuer_Anz_W'],
        0,
      );
    });

    test('signierte und unsignierte Einträge zählen gleich', () {
      final anna = b.betreuer(Gender.female);
      final bernd = b.betreuer(Gender.male);
      final w = b.bericht(
        2025,
        betreuer: [anna, bernd],
        eintraege: [
          b.eintrag(betreuerIds: {anna.id}, isSigned: true),
          b.eintrag(betreuerIds: {bernd.id}, isSigned: false),
        ],
      );
      expect(w['Betreuer_Anz_W'], 1);
      expect(w['Betreuer_Anz_M'], 1);
    });

    test('unbekannte Betreuer-IDs in Einträgen werden ignoriert', () {
      final w = b.bericht(
        2025,
        eintraege: [
          b.eintrag(betreuerIds: {'gibt-es-nicht'}),
        ],
      );
      expect(w['Betreuer_Anz_M'], 0);
    });
  });
}
