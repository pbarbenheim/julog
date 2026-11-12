import 'package:flutter_test/flutter_test.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart' as b;

List<String> _ids(List<Kategorie> kategorien) =>
    kategorien.map((k) => k.id).toList();

void main() {
  group('Kategorien ohne Berichtsthema', () {
    test('liefert im Jahr benutzte Kategorien ohne Berichtsthema', () {
      final ohne = b.kategorie();
      final mit = b.kategorie(thema: Berichtsthema.sport);
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: [ohne, mit],
        eintraege: [
          b.eintrag(kategorie: ohne),
          b.eintrag(kategorie: mit),
        ],
      );
      expect(_ids(result), [ohne.id]);
    });

    test('ausdrücklich "Sonstiges" gilt als zugeordnet', () {
      final kat = b.kategorie(thema: Berichtsthema.sonstiges);
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: [kat],
        eintraege: [b.eintrag(kategorie: kat)],
      );
      expect(result, isEmpty);
    });

    test('Kategorien nur in anderen Jahren fehlen', () {
      final kat = b.kategorie();
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: [kat],
        eintraege: [
          b.eintrag(kategorie: kat, start: DateTime(2024, 12, 31, 23, 59)),
          b.eintrag(kategorie: kat, start: DateTime(2026, 1, 1)),
        ],
      );
      expect(result, isEmpty);
    });

    test('maßgeblich ist der Beginn des Eintrags', () {
      final kat = b.kategorie();
      final e = b.eintrag(
        kategorie: kat,
        start: DateTime(2025, 12, 31, 22),
        end: DateTime(2026, 1, 1, 1),
      );
      expect(
        _ids(
          kategorienOhneBerichtsthema(
            berichtsjahr: 2025,
            kategorien: [kat],
            eintraege: [e],
          ),
        ),
        [kat.id],
      );
      expect(
        kategorienOhneBerichtsthema(
          berichtsjahr: 2026,
          kategorien: [kat],
          eintraege: [e],
        ),
        isEmpty,
      );
    });

    test('mehrfach benutzte Kategorie erscheint einmal', () {
      final kat = b.kategorie();
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: [kat],
        eintraege: [
          b.eintrag(kategorie: kat),
          b.eintrag(kategorie: kat),
        ],
      );
      expect(_ids(result), [kat.id]);
    });

    test('unbenutzte Kategorien ohne Thema fehlen', () {
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: [b.kategorie()],
        eintraege: const [],
      );
      expect(result, isEmpty);
    });

    test('signierte und unsignierte Einträge zählen gleich', () {
      final signiert = b.kategorie();
      final unsigniert = b.kategorie();
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: [signiert, unsigniert],
        eintraege: [
          b.eintrag(kategorie: signiert, isSigned: true),
          b.eintrag(kategorie: unsigniert),
        ],
      );
      expect(_ids(result), [signiert.id, unsigniert.id]);
    });

    test('Einträge mit unbekannter Kategorie-ID werden ignoriert', () {
      final result = kategorienOhneBerichtsthema(
        berichtsjahr: 2025,
        kategorien: const [],
        eintraege: [b.eintrag()],
      );
      expect(result, isEmpty);
    });
  });
}
