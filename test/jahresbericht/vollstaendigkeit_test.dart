import 'package:flutter_test/flutter_test.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';
import 'package:julog/jahresbericht/vollstaendigkeit.dart';
import 'package:julog/repository/model/model.dart';

import 'builders.dart' as b;

ManuelleAngaben _alleFragen([ManuelleAngaben? basis]) {
  var a = basis ?? const ManuelleAngaben.leer();
  for (var n = 1; n <= 16; n++) {
    a = a.withFrage(n, n.isEven);
  }
  return a;
}

final _vollstaendig = _alleFragen(
  ManuelleAngaben(
    arbeitWert11: 60,
    arbeitWert20: 230,
    einsatzabteilungM: 15,
    einsatzabteilungW: 10,
    einsatzabteilungD: 0,
  ),
);

Vollstaendigkeit _pruefe(
  ManuelleAngaben angaben, {
  List<Kategorie> kategorien = const [],
  List<Eintrag> eintraege = const [],
}) => pruefeVollstaendigkeit(
  berichtsjahr: 2025,
  angaben: angaben,
  kategorien: kategorien,
  eintraege: eintraege,
);

void main() {
  group('pruefeVollstaendigkeit', () {
    test('vollständige Angaben ohne Einträge sind vollständig', () {
      final v = _pruefe(_vollstaendig);
      expect(v.istVollstaendig, isTrue);
      expect(v.fehlendeFragen, isEmpty);
      expect(v.arbeitWert11Fehlt, isFalse);
      expect(v.arbeitWert20Fehlt, isFalse);
      expect(v.fehlendeEinsatzabteilung, isEmpty);
      expect(v.kategorienOhneBerichtsthema, isEmpty);
    });

    test('leere Angaben melden alles als fehlend', () {
      final v = _pruefe(const ManuelleAngaben.leer());
      expect(v.istVollstaendig, isFalse);
      expect(v.fehlendeFragen, [for (var n = 1; n <= 16; n++) n]);
      expect(v.arbeitWert11Fehlt, isTrue);
      expect(v.arbeitWert20Fehlt, isTrue);
      expect(v.fehlendeEinsatzabteilung, [
        Gender.male,
        Gender.female,
        Gender.diverse,
      ]);
    });

    test('meldet fehlende Fragen mit ihrer Nummer', () {
      final angaben = _vollstaendig.withFrage(4, null).withFrage(13, null);
      final v = _pruefe(angaben);
      expect(v.istVollstaendig, isFalse);
      expect(v.fehlendeFragen, [4, 13]);
    });

    test('Nein gilt als beantwortet', () {
      final v = _pruefe(_vollstaendig.withFrage(1, false));
      expect(v.fehlendeFragen, isEmpty);
    });

    test('meldet fehlenden Wert 11 und Wert 20 getrennt', () {
      final ohne11 = _pruefe(_vollstaendig.copyWith(arbeitWert11: null));
      expect(ohne11.istVollstaendig, isFalse);
      expect(ohne11.arbeitWert11Fehlt, isTrue);
      expect(ohne11.arbeitWert20Fehlt, isFalse);

      final ohne20 = _pruefe(_vollstaendig.copyWith(arbeitWert20: null));
      expect(ohne20.istVollstaendig, isFalse);
      expect(ohne20.arbeitWert11Fehlt, isFalse);
      expect(ohne20.arbeitWert20Fehlt, isTrue);
    });

    test('0 ist ein gültiger Wert für Wert 11 und Wert 20', () {
      final v = _pruefe(
        _vollstaendig.copyWith(arbeitWert11: 0, arbeitWert20: 0),
      );
      expect(v.istVollstaendig, isTrue);
    });

    test('meldet jedes fehlende Geschlecht der Einsatzabteilung', () {
      final v = _pruefe(
        _vollstaendig.copyWith(
          einsatzabteilungW: null,
          einsatzabteilungD: null,
        ),
      );
      expect(v.istVollstaendig, isFalse);
      expect(v.fehlendeEinsatzabteilung, [Gender.female, Gender.diverse]);
    });

    test('meldet im Jahr benutzte Kategorien ohne Berichtsthema', () {
      final ohne = b.kategorie();
      final mit = b.kategorie(thema: Berichtsthema.sport);
      final v = _pruefe(
        _vollstaendig,
        kategorien: [ohne, mit],
        eintraege: [
          b.eintrag(kategorie: ohne),
          b.eintrag(kategorie: mit),
        ],
      );
      expect(v.istVollstaendig, isFalse);
      expect(v.kategorienOhneBerichtsthema, [ohne]);
    });

    test(
      'unbenutzte oder in anderem Jahr benutzte Kategorien stören nicht',
      () {
        final unbenutzt = b.kategorie();
        final anderesJahr = b.kategorie();
        final v = _pruefe(
          _vollstaendig,
          kategorien: [unbenutzt, anderesJahr],
          eintraege: [
            b.eintrag(kategorie: anderesJahr, start: DateTime(2024, 5, 5, 18)),
          ],
        );
        expect(v.istVollstaendig, isTrue);
      },
    );

    test('Kategorie mit ausdrücklich gewähltem Sonstiges ist zugeordnet', () {
      final kat = b.kategorie(thema: Berichtsthema.sonstiges);
      final v = _pruefe(
        _vollstaendig,
        kategorien: [kat],
        eintraege: [b.eintrag(kategorie: kat)],
      );
      expect(v.istVollstaendig, isTrue);
    });

    test('mehrere Mängel werden gleichzeitig gemeldet', () {
      final kat = b.kategorie();
      final v = _pruefe(
        _vollstaendig.withFrage(2, null).copyWith(arbeitWert20: null),
        kategorien: [kat],
        eintraege: [b.eintrag(kategorie: kat)],
      );
      expect(v.istVollstaendig, isFalse);
      expect(v.fehlendeFragen, [2]);
      expect(v.arbeitWert20Fehlt, isTrue);
      expect(v.kategorienOhneBerichtsthema, [kat]);
    });
  });
}
