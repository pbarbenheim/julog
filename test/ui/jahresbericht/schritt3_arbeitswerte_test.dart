import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jldb/jldb.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';
import 'package:julog/l10n/app_localizations.dart';
import 'package:julog/provider/jldb/jldb.dart';
import 'package:julog/provider/jldb/julog_file.dart';
import 'package:julog/repository/berichtsentwurf/repository.dart';
import 'package:julog/repository/betreuer/repository.dart';
import 'package:julog/repository/eintrag/eintrag_repo.dart';
import 'package:julog/repository/kategorie/repository.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/ui/jahresbericht/assistent/assistent_screen.dart';
import 'package:julog/view_model/jahresbericht/assistent_viewmodel.dart';
import 'package:material_ui/material_ui.dart';

class _FakeJulogService extends JulogService {
  final Jldb _db;
  _FakeJulogService(this._db);

  @override
  JulogFile build() => JulogFile.loaded(jldb: _db);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (i >= 2 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      return;
    }
  }
}

const _fehlerText = 'Bitte eine ganze Zahl ab 0 eingeben.';

Finder _feld(String key) => find.byKey(Key('schritt3_feld_$key'));
Finder _zuruecknehmen(String key) =>
    find.byKey(Key('schritt3_zuruecknehmen_$key'));

void main() {
  late Jldb db;
  late ProviderContainer container;

  setUp(() async {
    db = (await Jldb.create(':memory:', domain: 'test.org').unwrap());
    container = ProviderContainer(
      overrides: [
        julogServiceProvider.overrideWith(() => _FakeJulogService(db)),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Two Einträge in 2025 under "Feuerwehrtechnische Ausbildung": 2 h and
  /// 6 h (a Tagesveranstaltung), one Betreuer each.
  Future<void> legeDatenAn(WidgetTester tester) => tester.runAsync(() async {
    final kategorie = await container.read(kategorieRepositoryProvider).save((
      name: 'Übung',
      berichtsthema: Berichtsthema.feuerwehrtechnik,
    )).unwrap();
    final betreuer = await container.read(betreuerRepositoryProvider).save((
      name: 'Bea',
      gender: Gender.female,
    )).unwrap();
    EintragCreateData eintrag(DateTime start, Duration dauer) => (
      start: start,
      end: start.add(dauer),
      kategorieId: kategorie.id,
      thema: 'Thema',
      ort: null,
      raum: null,
      dienstverlauf: null,
      besonderheiten: null,
      betreuerIds: [betreuer.id],
      anwesendeJugendlicherIds: <String>[],
      entschuldigteJugendlicherIds: <String>[],
    );
    final repo = container.read(eintragRepositoryProvider);
    await repo
        .save(eintrag(DateTime(2025, 3, 3, 18), const Duration(hours: 2)))
        .unwrap();
    await repo
        .save(eintrag(DateTime(2025, 5, 10, 9), const Duration(hours: 6)))
        .unwrap();
  });

  Future<void> oeffneSchritt3(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/jahresbericht/2025',
      routes: [
        GoRoute(
          path: '/jahresbericht/:jahr',
          builder: (_, state) => Scaffold(
            body: AssistentScreen(
              berichtsjahr: int.parse(state.pathParameters['jahr']!),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: const [Locale('de')],
        ),
      ),
    );
    await _settle(tester);
    await tester.tap(find.byKey(const Key('assistent_schritt_2')));
    await _settle(tester);
  }

  AssistentDaten daten() => container
      .read(jahresberichtAssistentViewModelProvider(2025))
      .requireValue;

  String feldText(WidgetTester tester, String key) =>
      tester.widget<TextField>(_feld(key)).controller!.text;

  testWidgets('shows every computed Arbeitswert with its label', (
    tester,
  ) async {
    await legeDatenAn(tester);
    await oeffneSchritt3(tester);

    for (final label in [
      'Gruppenabende: Feuerwehrtechnische Ausbildung',
      'Gruppenabende: Wettbewerbstraining',
      'Gruppenabende: Spiele und Kreatives',
      'Gruppenabende: Mit anderem Verein oder Gruppe',
      'Gruppenabende: Sport',
      'Gruppenabende: Erste Hilfe und Prävention',
      'Gruppenabende: Sonstiges',
      'Durchschnittliche Dauer je Gruppenabend (Minuten)',
      'Durchschnittliche Betreuerzahl je Gruppenabend',
      'Tagesveranstaltungen',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    expect(feldText(tester, 'Arbeit_Wert_01'), '2');
    expect(feldText(tester, 'Arbeit_Wert_02'), '0');
    expect(feldText(tester, 'Arbeit_Wert_10'), '240');
    expect(feldText(tester, 'Arbeit_Wert_12'), '1');
    expect(feldText(tester, 'Arbeit_Wert_13'), '1');
    // Nothing is overridden yet: no revert button, no override mark.
    expect(_zuruecknehmen('Arbeit_Wert_10'), findsNothing);
    expect(find.text('Überschrieben'), findsNothing);
  });

  testWidgets('overriding a value marks it and can be reverted', (
    tester,
  ) async {
    await legeDatenAn(tester);
    await oeffneSchritt3(tester);

    await tester.enterText(_feld('Arbeit_Wert_10'), '99');
    await tester.pump();

    expect(daten().entwurf.ueberschreibungen.toMap(), {'Arbeit_Wert_10': 99});
    expect(daten().berichtswert['Arbeit_Wert_10'], 99);
    expect(daten().berechnet['Arbeit_Wert_10'], 240);
    expect(find.text('Überschrieben'), findsOneWidget);
    expect(find.text('Berechnet: 240'), findsOneWidget);

    await tester.tap(_zuruecknehmen('Arbeit_Wert_10'));
    await tester.pump();

    expect(daten().entwurf.ueberschreibungen.toMap(), isEmpty);
    expect(feldText(tester, 'Arbeit_Wert_10'), '240');
    expect(find.text('Überschrieben'), findsNothing);
  });

  testWidgets('typing the computed value again is no override', (tester) async {
    await legeDatenAn(tester);
    await oeffneSchritt3(tester);

    await tester.enterText(_feld('Arbeit_Wert_01'), '5');
    await tester.pump();
    expect(daten().entwurf.ueberschreibungen.toMap(), {'Arbeit_Wert_01': 5});

    await tester.enterText(_feld('Arbeit_Wert_01'), '2');
    await tester.pump();
    expect(daten().entwurf.ueberschreibungen.toMap(), isEmpty);
  });

  testWidgets('overrides reject non-integer and negative input', (
    tester,
  ) async {
    await legeDatenAn(tester);
    await oeffneSchritt3(tester);

    for (final eingabe in ['-3', '1,5', 'abc', '']) {
      await tester.enterText(_feld('Arbeit_Wert_10'), eingabe);
      await tester.pump();
      expect(find.text(_fehlerText), findsOneWidget, reason: '"$eingabe"');
      expect(daten().entwurf.ueberschreibungen.toMap(), isEmpty);
    }

    await tester.enterText(_feld('Arbeit_Wert_10'), '0');
    await tester.pump();
    expect(find.text(_fehlerText), findsNothing);
    expect(daten().entwurf.ueberschreibungen.toMap(), {'Arbeit_Wert_10': 0});
  });

  testWidgets('manual values 11 and 20 are entered and validated', (
    tester,
  ) async {
    await oeffneSchritt3(tester);

    expect(feldText(tester, 'Arbeit_Wert_11'), '');
    expect(feldText(tester, 'Arbeit_Wert_20'), '');

    await tester.enterText(_feld('Arbeit_Wert_11'), '30');
    await tester.enterText(_feld('Arbeit_Wert_20'), '120');
    await tester.pump();
    expect(daten().entwurf.angaben.arbeitWert11, 30);
    expect(daten().entwurf.angaben.arbeitWert20, 120);

    for (final eingabe in ['-1', '2,5', 'x']) {
      await tester.enterText(_feld('Arbeit_Wert_11'), eingabe);
      await tester.pump();
      expect(find.text(_fehlerText), findsOneWidget, reason: '"$eingabe"');
      expect(daten().entwurf.angaben.arbeitWert11, 30);
    }

    // Clearing the field takes the answer back (not yet answered).
    await tester.enterText(_feld('Arbeit_Wert_11'), '');
    await tester.pump();
    expect(daten().entwurf.angaben.arbeitWert11, isNull);
    expect(find.text(_fehlerText), findsNothing);
  });

  testWidgets('entries survive leaving the step and resuming the draft', (
    tester,
  ) async {
    await legeDatenAn(tester);
    await oeffneSchritt3(tester);

    await tester.enterText(_feld('Arbeit_Wert_13'), '4');
    await tester.enterText(_feld('Arbeit_Wert_11'), '45');
    await tester.pump();

    // Leaving the step saves the draft.
    await tester.tap(find.byKey(const Key('assistent_weiter')));
    await _settle(tester);
    final gespeichert = await tester.runAsync(
      () => BerichtsentwurfRepository(jldb: db).getByYear(2025).unwrap(),
    );
    final entwurf = gespeichert!.unwrap();
    expect(entwurf.ueberschreibungen.toMap(), {'Arbeit_Wert_13': 4});
    expect(entwurf.angaben.arbeitWert11, 45);

    // Back on the step the values are shown, the override is marked.
    await tester.tap(find.byKey(const Key('assistent_zurueck')));
    await _settle(tester);
    expect(feldText(tester, 'Arbeit_Wert_13'), '4');
    expect(feldText(tester, 'Arbeit_Wert_11'), '45');
    expect(find.text('Überschrieben'), findsOneWidget);
    expect(find.text('Berechnet: 1'), findsOneWidget);
  });

  testWidgets('a saved draft resumes with its overrides and manual values', (
    tester,
  ) async {
    await legeDatenAn(tester);
    await tester.runAsync(() async {
      final repo = BerichtsentwurfRepository(jldb: db);
      await repo.save(2025).unwrap();
      await repo.update((
        year: 2025,
        angaben: ManuelleAngaben(arbeitWert11: 30, arbeitWert20: 80),
        ueberschreibungen: Ueberschreibungen({'Arbeit_Wert_12': 3}),
      )).unwrap();
    });
    await oeffneSchritt3(tester);

    expect(feldText(tester, 'Arbeit_Wert_11'), '30');
    expect(feldText(tester, 'Arbeit_Wert_20'), '80');
    expect(feldText(tester, 'Arbeit_Wert_12'), '3');
    expect(_zuruecknehmen('Arbeit_Wert_12'), findsOneWidget);
    expect(find.text('Berechnet: 1'), findsOneWidget);
  });
}
