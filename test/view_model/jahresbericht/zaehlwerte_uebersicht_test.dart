import 'package:flutter_test/flutter_test.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/view_model/jahresbericht/zaehlwerte_uebersicht.dart';

import '../../jahresbericht/builders.dart';

void main() {
  group('ZaehlwerteUebersicht', () {
    test('groups Mitglieder and Betreuer by Geschlecht with a total', () {
      final wert = bericht(
        2025,
        jugendliche: [
          jug(gender: Gender.male),
          jug(gender: Gender.male),
          jug(gender: Gender.female),
          jug(gender: Gender.diverse),
        ],
      );

      final uebersicht = ZaehlwerteUebersicht.von(wert);

      expect(uebersicht.mitglieder.maennlich, 2);
      expect(uebersicht.mitglieder.weiblich, 1);
      expect(uebersicht.mitglieder.divers, 1);
      expect(uebersicht.mitglieder.gesamt, 4);
      expect(uebersicht.betreuer.gesamt, 0);
    });

    test('lists the ages 5 to 18 individually plus under 5 and over 18', () {
      // Born 2012-06-15 -> 13 years on 31.12.2025.
      final uebersicht = ZaehlwerteUebersicht.von(
        bericht(2025, jugendliche: [jug(birthDate: DateTime(2012, 6, 15))]),
      );

      expect(uebersicht.alter.map((z) => z.alter), [
        for (var a = 5; a <= 18; a++) a,
      ]);
      expect(uebersicht.alter.firstWhere((z) => z.alter == 13).werte.gesamt, 1);
      expect(
        uebersicht.alter.where((z) => z.alter != 13).every((z) {
          return z.werte.gesamt == 0;
        }),
        isTrue,
      );
      expect(uebersicht.alterUnter5.gesamt, 0);
      expect(uebersicht.alterUeber18.gesamt, 0);
    });

    test('splits Zugang by Herkunft and Abgang by EA/sonstige', () {
      final uebersicht = ZaehlwerteUebersicht.von(
        bericht(
          2025,
          jugendliche: [
            jug(memberSince: DateTime(2025, 3, 1), herkunft: Herkunft.neu),
            jug(
              memberSince: DateTime(2025, 3, 1),
              herkunft: Herkunft.kinderfeuerwehr,
              gender: Gender.female,
            ),
            jug(
              exitDate: DateTime(2025, 5, 1),
              exitReason: AustrittsGrund.uebernahme,
            ),
            jug(
              exitDate: DateTime(2025, 5, 1),
              exitReason: AustrittsGrund.schule,
            ),
          ],
        ),
      );

      expect(uebersicht.zugangNeu.gesamt, 1);
      expect(uebersicht.zugangAndereOrganisation.gesamt, 0);
      expect(uebersicht.zugangKinderfeuerwehr.weiblich, 1);
      expect(uebersicht.abgangEinsatzabteilung.gesamt, 1);
      expect(uebersicht.abgangSonstige.gesamt, 1);
      expect(uebersicht.abgangGruende[AustrittsGrund.schule], 1);
      expect(uebersicht.abgangGruende[AustrittsGrund.wohnortwechsel], 0);
      expect(
        uebersicht.abgangGruende.containsKey(AustrittsGrund.uebernahme),
        isFalse,
      );
    });
  });
}
