import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;

import 'package:julog/assembly/eintrag_assembly.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/ui/eintrag/pdf_export.dart';

late crypto.PublicKey _testPublicKey;

Identity _identity(String id) =>
    ClosedIdentity(id: id, publicKey: _testPublicKey, isLocal: false);

ShowingSignature _sig(String id) => ShowingSignature(
  id: id,
  eintragId: 'e1',
  identity: _identity('i1'),
  signature: crypto.Signature(Uint8List.fromList([1, 2, 3, 4, 5])),
  timestamp: DateTime(2024, 3, 1, 10),
  version: 4,
  isValid: true,
);

Jugendlicher _jugendlicher(String id, String name) => Jugendlicher(
  id: id,
  name: name,
  gender: Gender.male,
  birthDate: DateTime(2005),
  memberSince: DateTime(2020),
  eintragIds: {},
);

SelectedEintrag _minimalEintrag() => SelectedEintrag(
  id: 'e1',
  start: DateTime(2024, 3, 1, 10),
  end: DateTime(2024, 3, 1, 12),
  kategorie: const Kategorie(id: 'k1', name: 'Gruppenstunde'),
  betreuer: [],
  anwesendeJugendliche: [],
  entschuldigteJugendliche: [],
  undefinierteJugendliche: [],
  signatures: [],
  possibleSigners: [],
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    final pair = await crypto.KeyPair.generateAsync(
      identity: crypto.KeyOwner('Test', 'Gruppenführer', 'test@example.com'),
      password: 'pw',
      keySize: 1024,
    );
    _testPublicKey = pair.publicKey;
  });

  group('generateEintragPdf', () {
    test('minimal eintrag — returns non-empty bytes', () async {
      final bytes = await generateEintragPdf(eintrag: _minimalEintrag());
      expect(bytes, isNotEmpty);
    });

    test('all optional fields null — does not throw', () async {
      final eintrag = _minimalEintrag();
      expect(() => generateEintragPdf(eintrag: eintrag), returnsNormally);
      final bytes = await generateEintragPdf(eintrag: eintrag);
      expect(bytes, isNotEmpty);
    });

    test('fully populated eintrag — returns non-empty bytes', () async {
      final eintrag = SelectedEintrag(
        id: 'e1',
        start: DateTime(2024, 3, 1, 10),
        end: DateTime(2024, 3, 1, 12),
        kategorie: const Kategorie(id: 'k1', name: 'Gruppenstunde'),
        thema: 'Erste Hilfe',
        ort: 'Vereinsheim',
        raum: 'Saal A',
        dienstverlauf: 'Übung durchgeführt.',
        besonderheiten: 'Keine Besonderheiten.',
        betreuer: [
          const Betreuer(id: 'b1', name: 'Anna Schmidt', gender: Gender.female),
        ],
        anwesendeJugendliche: [_jugendlicher('j1', 'Max Muster')],
        entschuldigteJugendliche: [_jugendlicher('j2', 'Lisa Muster')],
        undefinierteJugendliche: [_jugendlicher('j3', 'Tom Muster')],
        signatures: [_sig('s1'), _sig('s2')],
        possibleSigners: [_identity('i1')],
      );

      final bytes = await generateEintragPdf(eintrag: eintrag);
      expect(bytes, isNotEmpty);
    });

    test('empty undefinierteJugendliche — section absent (no throw)', () async {
      final eintrag = SelectedEintrag(
        id: 'e1',
        start: DateTime(2024, 3, 1, 10),
        end: DateTime(2024, 3, 1, 12),
        kategorie: const Kategorie(id: 'k1', name: 'Gruppenstunde'),
        betreuer: [],
        anwesendeJugendliche: [_jugendlicher('j1', 'Max Muster')],
        entschuldigteJugendliche: [],
        undefinierteJugendliche: [],
        signatures: [],
        possibleSigners: [],
      );

      final bytes = await generateEintragPdf(eintrag: eintrag);
      expect(bytes, isNotEmpty);
    });
  });
}
