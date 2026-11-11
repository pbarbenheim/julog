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

Finder _frage(int n) => find.byKey(Key('schritt4_frage_$n'));
Finder _antwort(int n, String text) =>
    find.descendant(of: _frage(n), matching: find.text(text));
Finder _offen(int n) => find.byKey(Key('schritt4_offen_$n'));

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

  Future<void> speichereEntwurf(
    WidgetTester tester,
    int jahr,
    ManuelleAngaben angaben,
  ) => tester.runAsync(() async {
    final repo = BerichtsentwurfRepository(jldb: db);
    await repo.save(jahr).unwrap();
    await repo.update((
      year: jahr,
      angaben: angaben,
      ueberschreibungen: const Ueberschreibungen.keine(),
    )).unwrap();
  });

  Future<void> oeffneSchritt4(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 4000);
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
    await tester.tap(find.byKey(const Key('assistent_schritt_3')));
    await _settle(tester);
  }

  AssistentDaten daten() => container
      .read(jahresberichtAssistentViewModelProvider(2025))
      .requireValue;

  testWidgets('shows all 16 questions in four groups with their texts', (
    tester,
  ) async {
    await oeffneSchritt4(tester);

    for (final gruppe in [
      'Teilnahme',
      'Aktivitäten',
      'Wettbewerbe',
      'Sonstiges',
    ]) {
      expect(find.text(gruppe), findsOneWidget, reason: gruppe);
    }
    for (var n = 1; n <= 16; n++) {
      expect(_frage(n), findsOneWidget, reason: 'Frage $n');
    }
    for (final text in [
      'Teilnahme am Gemeinschaftsleben',
      'Teilnahme an externen Bildungsveranstaltungen',
      'Teilnahme an internen Bildungsveranstaltungen der JF/KF',
      'Internationale Jugendarbeit',
      'Natur / Umweltschutz',
      'Aktive Mitgliederwerbung',
      'An der Schule / in Kindergärten',
      'Jugendflamme',
      'Bundeswettbewerb',
      'Leistungsspange',
      'CTIF',
      'Landesspezifischer Wettbewerb',
      'Die JF/KF hat mehr Interessierte, als sie aufnehmen kann',
      'Die JF/KF hat Nachwuchssorgen',
      'Die JF/KF hat zu wenig Betreuer',
      'Die JF/KF hat einen eigenen Sprecher',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('unanswered questions are marked until answered', (tester) async {
    await oeffneSchritt4(tester);

    for (var n = 1; n <= 16; n++) {
      expect(_offen(n), findsOneWidget, reason: 'Frage $n');
    }
    expect(find.text('16 Fragen noch offen'), findsOneWidget);

    await tester.tap(_antwort(5, 'Ja'));
    await tester.pump();
    expect(daten().entwurf.angaben.frage(5), isTrue);
    expect(_offen(5), findsNothing);
    expect(_offen(6), findsOneWidget);
    expect(find.text('15 Fragen noch offen'), findsOneWidget);

    await tester.tap(_antwort(6, 'Nein'));
    await tester.pump();
    expect(daten().entwurf.angaben.frage(6), isFalse);
    expect(_offen(6), findsNothing);
  });

  testWidgets('an answer can be changed and taken back to unanswered', (
    tester,
  ) async {
    await oeffneSchritt4(tester);

    await tester.tap(_antwort(9, 'Ja'));
    await tester.pump();
    await tester.tap(_antwort(9, 'Nein'));
    await tester.pump();
    expect(daten().entwurf.angaben.frage(9), isFalse);

    // Tapping the selected answer again takes it back.
    await tester.tap(_antwort(9, 'Nein'));
    await tester.pump();
    expect(daten().entwurf.angaben.frage(9), isNull);
    expect(_offen(9), findsOneWidget);
  });

  testWidgets('all answered shows no open marks', (tester) async {
    await speichereEntwurf(
      tester,
      2025,
      ManuelleAngaben(fragen: {for (var n = 1; n <= 16; n++) n: n.isEven}),
    );
    await oeffneSchritt4(tester);

    for (var n = 1; n <= 16; n++) {
      expect(_offen(n), findsNothing, reason: 'Frage $n');
    }
    expect(find.textContaining('noch offen'), findsNothing);
    expect(find.text('Alle Fragen beantwortet'), findsOneWidget);
  });

  testWidgets('a new year proposes the answers of the previous year', (
    tester,
  ) async {
    await speichereEntwurf(
      tester,
      2024,
      ManuelleAngaben(fragen: {1: true, 2: false}),
    );
    await oeffneSchritt4(tester);

    expect(daten().entwurf.angaben.frage(1), isTrue);
    expect(_offen(1), findsNothing);
    expect(_offen(2), findsNothing);
    expect(_offen(3), findsOneWidget);
    expect(find.text('14 Fragen noch offen'), findsOneWidget);
  });

  testWidgets('answers survive leaving the step and resuming the draft', (
    tester,
  ) async {
    await oeffneSchritt4(tester);

    await tester.tap(_antwort(13, 'Ja'));
    await tester.tap(_antwort(14, 'Nein'));
    await tester.pump();

    await tester.tap(find.byKey(const Key('assistent_weiter')));
    await _settle(tester);
    final gespeichert = await tester.runAsync(
      () => BerichtsentwurfRepository(jldb: db).getByYear(2025).unwrap(),
    );
    expect(gespeichert!.unwrap().angaben.fragen, {13: true, 14: false});

    await tester.tap(find.byKey(const Key('assistent_zurueck')));
    await _settle(tester);
    expect(_offen(13), findsNothing);
    expect(_offen(14), findsNothing);
    expect(_offen(15), findsOneWidget);
    expect(find.text('14 Fragen noch offen'), findsOneWidget);
  });
}
