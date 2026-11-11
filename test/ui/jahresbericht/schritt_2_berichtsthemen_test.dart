import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jldb/jldb.dart';
import 'package:julog/l10n/app_localizations.dart';
import 'package:julog/provider/jldb/jldb.dart';
import 'package:julog/provider/jldb/julog_file.dart';
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

  Future<Kategorie> kategorie(
    WidgetTester tester,
    String name, {
    Berichtsthema? thema,
  }) async {
    final k = await tester.runAsync(
      () => container.read(kategorieRepositoryProvider).save((
        name: name,
        berichtsthema: thema,
      )).unwrap(),
    );
    return k!;
  }

  Future<void> eintrag(WidgetTester tester, Kategorie k, DateTime start) async {
    await tester.runAsync(
      () => container.read(eintragRepositoryProvider).save((
        start: start,
        end: start.add(const Duration(hours: 2)),
        kategorieId: k.id,
        thema: 'Thema',
        ort: null,
        raum: null,
        dienstverlauf: null,
        besonderheiten: null,
        betreuerIds: <String>[],
        anwesendeJugendlicherIds: <String>[],
        entschuldigteJugendlicherIds: <String>[],
      )).unwrap(),
    );
  }

  Future<void> pumpAtStep2(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
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
    await tester.tap(find.byKey(const Key('assistent_weiter')));
    await _settle(tester);
    expect(find.text('Schritt 2 von 6'), findsOneWidget);
  }

  testWidgets('lists exactly the used Kategorien without a Berichtsthema', (
    tester,
  ) async {
    final offen = await kategorie(tester, 'Übung');
    final zugeordnet = await kategorie(
      tester,
      'Sport',
      thema: Berichtsthema.sport,
    );
    await kategorie(tester, 'Ungenutzt');
    final anderesJahr = await kategorie(tester, 'Altlast');
    await eintrag(tester, offen, DateTime(2025, 3, 1, 18));
    await eintrag(tester, zugeordnet, DateTime(2025, 3, 2, 18));
    await eintrag(tester, anderesJahr, DateTime(2024, 3, 2, 18));

    await pumpAtStep2(tester);

    expect(find.byKey(Key('schritt2_kategorie_${offen.id}')), findsOneWidget);
    expect(find.text('Übung'), findsOneWidget);
    expect(find.text('Sport'), findsNothing);
    expect(find.text('Ungenutzt'), findsNothing);
    expect(find.text('Altlast'), findsNothing);
    expect(find.byKey(const Key('schritt2_keine_offen')), findsNothing);
  });

  testWidgets('assigning persists on the Kategorie and updates Arbeitswerte', (
    tester,
  ) async {
    final k = await kategorie(tester, 'Übung');
    await eintrag(tester, k, DateTime(2025, 3, 1, 18));
    await pumpAtStep2(tester);

    expect(
      container
          .read(jahresberichtAssistentViewModelProvider(2025))
          .requireValue
          .berichtswert['Arbeit_Wert_05'],
      0,
    );

    await tester.tap(find.byKey(Key('schritt2_thema_${k.id}')));
    await tester.pump();
    await tester.tap(find.text('Sport').last);
    await _settle(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    final gespeichert = await tester.runAsync(
      () => KategorieRepository(jldb: db).getAll().unwrap(),
    );
    expect(gespeichert!.single.berichtsthema, Berichtsthema.sport);
    final daten = container
        .read(jahresberichtAssistentViewModelProvider(2025))
        .requireValue;
    expect(daten.berichtswert['Arbeit_Wert_05'], 1);
    // The row stays visible so the choice can be corrected.
    expect(find.byKey(Key('schritt2_kategorie_${k.id}')), findsOneWidget);
  });

  testWidgets('Sonstiges is an explicit choice', (tester) async {
    final k = await kategorie(tester, 'Übung');
    await eintrag(tester, k, DateTime(2025, 3, 1, 18));
    await pumpAtStep2(tester);

    await tester.tap(find.byKey(Key('schritt2_thema_${k.id}')));
    await tester.pump();
    await tester.tap(find.text('Sonstiges').last);
    await _settle(tester);

    final gespeichert = await tester.runAsync(
      () => KategorieRepository(jldb: db).getAll().unwrap(),
    );
    expect(gespeichert!.single.berichtsthema, Berichtsthema.sonstiges);
  });

  testWidgets('shows a note and does not block when nothing is open', (
    tester,
  ) async {
    final k = await kategorie(tester, 'Sport', thema: Berichtsthema.sport);
    await eintrag(tester, k, DateTime(2025, 3, 1, 18));
    await pumpAtStep2(tester);

    expect(find.byKey(const Key('schritt2_keine_offen')), findsOneWidget);
    await tester.tap(find.byKey(const Key('assistent_weiter')));
    await _settle(tester);
    expect(find.text('Schritt 3 von 6'), findsOneWidget);
  });
}
