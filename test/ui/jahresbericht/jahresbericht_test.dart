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
import 'package:julog/repository/jugendliche/repository.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/ui/jahresbericht/assistent/assistent_screen.dart';
import 'package:julog/ui/jahresbericht/jahresbericht_screen.dart';
import 'package:julog/view_model/jahresbericht/assistent_viewmodel.dart';
import 'package:material_ui/material_ui.dart';

class _FakeJulogService extends JulogService {
  final Jldb _db;
  _FakeJulogService(this._db);

  @override
  JulogFile build() => JulogFile.loaded(jldb: _db);
}

/// Lets real (non fake-async) database futures complete, then pumps until
/// nothing is loading any more.
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

void main() {
  late Jldb db;
  late ProviderContainer container;

  setUp(() async {
    // The in-memory database needs real async, not the test's fake clock.
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

  Future<void> pumpApp(WidgetTester tester, String initialLocation) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/jahresbericht',
          builder: (_, _) => const Scaffold(body: JahresberichtScreen()),
        ),
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
  }

  testWidgets('wizard: Weiter/Zurück reach all six steps', (tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, '/jahresbericht/2025');

    final titel = [
      'Jahr und Übersicht der Zählwerte',
      'Berichtsthemen zuordnen',
      'Arbeitswerte',
      'Fragen',
      'Einsatzabteilung',
      'Zusammenfassung und Export',
    ];

    for (var i = 0; i < 6; i++) {
      expect(find.text('Schritt ${i + 1} von 6'), findsOneWidget);
      if (i < 5) {
        await tester.tap(find.byKey(const Key('assistent_weiter')));
        await _settle(tester);
      }
    }
    // Placeholder of the last step is reachable.
    expect(find.text(titel[5]), findsWidgets);
    expect(find.byKey(const Key('assistent_weiter')), findsNothing);

    for (var i = 5; i > 0; i--) {
      await tester.tap(find.byKey(const Key('assistent_zurueck')));
      await _settle(tester);
    }
    expect(find.text('Schritt 1 von 6'), findsOneWidget);
    // Zurück is disabled on the first step.
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('assistent_zurueck')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('wizard step 1 shows the Zählwerte read-only with a hint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(
      () => container.read(jugendlicheRepositoryProvider).save((
        name: 'Max',
        gender: Gender.male,
        birthDate: DateTime(2012, 6, 15),
        memberSince: DateTime(2020, 1, 1),
        pass: null,
        herkunft: Herkunft.neu,
      )).unwrap(),
    );

    await pumpApp(tester, '/jahresbericht/2025');

    expect(find.text('Mitglieder am Stichtag'), findsOneWidget);
    expect(find.text('Betreuer'), findsOneWidget);
    expect(find.text('Zugang im Berichtsjahr'), findsOneWidget);
    expect(find.text('Abgang im Berichtsjahr'), findsOneWidget);
    expect(find.text('Alter der Mitglieder am Stichtag'), findsOneWidget);
    expect(find.text('Wohnortwechsel'), findsOneWidget);
    expect(find.byKey(const Key('schritt1_hinweis')), findsOneWidget);
    // Read-only: no input fields on the step.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('leaving a step saves the draft, closing returns to the list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, '/jahresbericht/2025');

    container
        .read(jahresberichtAssistentViewModelProvider(2025).notifier)
        .aendereAngaben((a) => a.copyWith(arbeitWert20: 40));
    await tester.tap(find.byKey(const Key('assistent_weiter')));
    await _settle(tester);

    final repo = BerichtsentwurfRepository(jldb: db);
    var gespeichert = await tester.runAsync(
      () => repo.getByYear(2025).unwrap(),
    );
    expect(gespeichert!.unwrap().angaben.arbeitWert20, 40);

    container
        .read(jahresberichtAssistentViewModelProvider(2025).notifier)
        .aendereAngaben((a) => a.withFrage(1, true));
    await tester.tap(find.byKey(const Key('assistent_schliessen')));
    await _settle(tester);

    gespeichert = await tester.runAsync(
      () => BerichtsentwurfRepository(jldb: db).getByYear(2025).unwrap(),
    );
    expect(gespeichert!.unwrap().angaben.frage(1), true);
    expect(find.byType(JahresberichtScreen), findsOneWidget);
    expect(find.byKey(const Key('jahresbericht_eintrag_2025')), findsOneWidget);
  });

  testWidgets('list: starts a report for the preselected year', (tester) async {
    await pumpApp(tester, '/jahresbericht');

    expect(find.text('Noch kein Jahresbericht angelegt.'), findsOneWidget);
    expect(find.text('${DateTime.now().year}'), findsWidgets);

    await tester.tap(find.byKey(const Key('jahresbericht_starten')));
    await _settle(tester);

    expect(find.byType(AssistentScreen), findsOneWidget);
    final gespeichert = await tester.runAsync(
      () => BerichtsentwurfRepository(
        jldb: db,
      ).getByYear(DateTime.now().year).unwrap(),
    );
    expect(gespeichert, isA<Some>());
  });

  testWidgets('list: shows status of drafts and continues one', (tester) async {
    final repo = BerichtsentwurfRepository(jldb: db);
    await tester.runAsync(() async {
      await repo.save(2023).unwrap();
      await repo.save(2024).unwrap();
      await repo.update((
        year: 2024,
        angaben: const ManuelleAngaben.leer().withFrage(1, true),
        ueberschreibungen: const Ueberschreibungen.keine(),
      )).unwrap();
      await repo.markExported(2023, DateTime(2024, 2, 3)).unwrap();
    });

    await pumpApp(tester, '/jahresbericht');

    expect(find.text('Berichtsjahr 2023'), findsOneWidget);
    expect(find.text('Exportiert am 3.2.2024'), findsOneWidget);
    expect(find.text('Berichtsjahr 2024'), findsOneWidget);
    expect(find.text('Entwurf'), findsOneWidget);

    await tester.tap(find.byKey(const Key('jahresbericht_eintrag_2024')));
    await _settle(tester);

    expect(find.byType(AssistentScreen), findsOneWidget);
    expect(find.text('Jahresbericht 2024'), findsWidgets);
  });
}
