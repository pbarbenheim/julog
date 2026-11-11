import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jldb/jldb.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';
import 'package:julog/provider/jldb/jldb.dart';
import 'package:julog/provider/jldb/julog_file.dart';
import 'package:julog/repository/berichtsentwurf/repository.dart';
import 'package:julog/repository/jugendliche/repository.dart';
import 'package:julog/repository/model/berichtsentwurf/berichtsentwurf.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/view_model/jahresbericht/assistent_viewmodel.dart';

class _FakeJulogService extends JulogService {
  final Jldb _db;
  _FakeJulogService(this._db);

  @override
  JulogFile build() => JulogFile.loaded(jldb: _db);
}

void main() {
  late Jldb db;
  late ProviderContainer container;

  setUp(() async {
    db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    container = ProviderContainer(
      overrides: [
        julogServiceProvider.overrideWith(() => _FakeJulogService(db)),
      ],
    );
    addTearDown(container.dispose);
  });
  tearDown(() => db.close());

  Future<JahresberichtAssistentViewModel> open(int jahr) async {
    final provider = jahresberichtAssistentViewModelProvider(jahr);
    container.listen(provider, (_, _) {});
    await container.read(provider.future);
    return container.read(provider.notifier);
  }

  AssistentDaten daten(int jahr) => container
      .read(jahresberichtAssistentViewModelProvider(jahr))
      .requireValue;

  Future<void> addJugendlicher() =>
      container.read(jugendlicheRepositoryProvider).save((
        name: 'Max',
        gender: Gender.male,
        birthDate: DateTime(2012, 6, 15),
        memberSince: DateTime(2020, 1, 1),
        pass: null,
        herkunft: Herkunft.neu,
      )).unwrap();

  BerichtsentwurfRepository freshRepo() => BerichtsentwurfRepository(jldb: db);

  group('JahresberichtAssistentViewModel', () {
    test('creates the draft for the year and computes the Zählwerte', () async {
      await addJugendlicher();

      await open(2025);

      expect(daten(2025).entwurf.year, 2025);
      expect(daten(2025).entwurf.status, EntwurfStatus.entwurf);
      expect(daten(2025).berichtswert['Mitglieder_Anz_M'], 1);
      expect(await freshRepo().getByYear(2025).unwrap(), isA<Some>());
    });

    test('resumes an existing draft instead of creating a new one', () async {
      final repo = freshRepo();
      await repo.save(2025).unwrap();
      await repo.update((
        year: 2025,
        angaben: const ManuelleAngaben.leer().withFrage(1, true),
        ueberschreibungen: const Ueberschreibungen.keine(),
      )).unwrap();

      await open(2025);

      expect(daten(2025).entwurf.angaben.frage(1), true);
    });

    test(
      'staged changes are visible at once but saved only on speichern',
      () async {
        final vm = await open(2025);

        vm.aendereAngaben((a) => a.copyWith(arbeitWert20: 40));

        expect(daten(2025).entwurf.angaben.arbeitWert20, 40);
        expect(daten(2025).hatUngespeicherteAenderungen, isTrue);
        final before = (await freshRepo().getByYear(2025).unwrap()).unwrap();
        expect(before.angaben.arbeitWert20, isNull);

        await vm.speichern();

        expect(daten(2025).hatUngespeicherteAenderungen, isFalse);
        final after = (await freshRepo().getByYear(2025).unwrap()).unwrap();
        expect(after.angaben.arbeitWert20, 40);
      },
    );

    test(
      'overrides change the Berichtswert but not the computed value',
      () async {
        final vm = await open(2025);

        vm.aendereUeberschreibungen(
          (u) => Ueberschreibungen({...u.toMap(), 'Arbeit_Wert_10': 99}),
        );

        expect(daten(2025).berichtswert['Arbeit_Wert_10'], 99);
        expect(daten(2025).berechnet['Arbeit_Wert_10'], 0);
      },
    );

    test('speichern without changes does not touch the draft', () async {
      final vm = await open(2025);

      await vm.speichern();

      expect(daten(2025).hatUngespeicherteAenderungen, isFalse);
    });

    test('vorVerlassen runs the step hooks, then saves the draft', () async {
      final vm = await open(2025);
      var hookRuns = 0;
      final eigner = Object();
      vm.registriereVorVerlassen(eigner, () async {
        hookRuns++;
        vm.aendereAngaben((a) => a.withFrage(3, false));
      });

      await vm.vorVerlassen();

      expect(hookRuns, 1);
      final saved = (await freshRepo().getByYear(2025).unwrap()).unwrap();
      expect(saved.angaben.frage(3), false);
    });

    test('a removed hook is no longer run', () async {
      final vm = await open(2025);
      var hookRuns = 0;
      final eigner = Object();
      vm.registriereVorVerlassen(eigner, () async => hookRuns++);
      vm.entferneVorVerlassen(eigner);

      await vm.vorVerlassen();

      expect(hookRuns, 0);
    });

    test(
      'neuLaden picks up changed Stammdaten and keeps staged changes',
      () async {
        final vm = await open(2025);
        vm.aendereAngaben((a) => a.copyWith(arbeitWert11: 15));
        await addJugendlicher();

        await vm.neuLaden();

        expect(daten(2025).berichtswert['Mitglieder_Anz_M'], 1);
        expect(daten(2025).entwurf.angaben.arbeitWert11, 15);
        expect(daten(2025).hatUngespeicherteAenderungen, isTrue);
      },
    );
  });

  group('BerichtsentwuerfeViewModel', () {
    test('starten creates a draft for a year without one', () async {
      final provider = berichtsentwuerfeViewModelProvider;
      container.listen(provider, (_, _) {});
      expect(await container.read(provider.future), isEmpty);

      await container.read(provider.notifier).starten(2023);

      final liste = await container.read(provider.future);
      expect(liste.map((e) => e.year), [2023]);
    });

    test('starten keeps an existing draft untouched', () async {
      final repo = container.read(berichtsentwurfRepositoryProvider);
      await repo.save(2023).unwrap();
      await repo.update((
        year: 2023,
        angaben: const ManuelleAngaben.leer().withFrage(2, true),
        ueberschreibungen: const Ueberschreibungen.keine(),
      )).unwrap();
      final provider = berichtsentwuerfeViewModelProvider;
      container.listen(provider, (_, _) {});
      await container.read(provider.future);

      await container.read(provider.notifier).starten(2023);

      final liste = await container.read(provider.future);
      expect(liste, hasLength(1));
      expect(liste.single.angaben.frage(2), true);
    });
  });
}
