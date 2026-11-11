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

const _fehlerText = 'Bitte eine ganze Zahl ab 0 eingeben.';

Finder _feld(String gender) => find.byKey(Key('schritt5_feld_$gender'));

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

  Future<void> oeffneSchritt5(WidgetTester tester) async {
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
    await tester.tap(find.byKey(const Key('assistent_schritt_4')));
    await _settle(tester);
  }

  ManuelleAngaben angaben() => container
      .read(jahresberichtAssistentViewModelProvider(2025))
      .requireValue
      .entwurf
      .angaben;

  String feldText(WidgetTester tester, String gender) =>
      tester.widget<TextField>(_feld(gender)).controller!.text;

  testWidgets('shows three empty fields M/W/D for a fresh draft', (
    tester,
  ) async {
    await oeffneSchritt5(tester);

    for (final label in ['Männlich', 'Weiblich', 'Divers']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    for (final g in ['M', 'W', 'D']) {
      expect(feldText(tester, g), '');
    }
    // Empty fields are marked as not yet given.
    expect(find.text('Noch nicht angegeben'), findsNWidgets(3));
  });

  testWidgets('valid integers go into the draft', (tester) async {
    await oeffneSchritt5(tester);

    await tester.enterText(_feld('M'), '3');
    await tester.enterText(_feld('W'), '0');
    await tester.enterText(_feld('D'), '12');
    await tester.pump();

    expect(angaben().einsatzabteilungM, 3);
    expect(angaben().einsatzabteilungW, 0);
    expect(angaben().einsatzabteilungD, 12);
    expect(find.text('Noch nicht angegeben'), findsNothing);
    expect(find.text(_fehlerText), findsNothing);
  });

  testWidgets('non-integer and negative input is rejected', (tester) async {
    await oeffneSchritt5(tester);
    await tester.enterText(_feld('W'), '4');
    await tester.pump();

    for (final eingabe in ['-3', '1,5', '2.5', 'abc', '1e3']) {
      await tester.enterText(_feld('W'), eingabe);
      await tester.pump();
      expect(find.text(_fehlerText), findsOneWidget, reason: '"$eingabe"');
      expect(angaben().einsatzabteilungW, 4, reason: '"$eingabe"');
    }

    await tester.enterText(_feld('W'), '0');
    await tester.pump();
    expect(find.text(_fehlerText), findsNothing);
    expect(angaben().einsatzabteilungW, 0);
  });

  testWidgets('clearing a field takes the value back to unanswered', (
    tester,
  ) async {
    await oeffneSchritt5(tester);
    await tester.enterText(_feld('D'), '2');
    await tester.pump();
    await tester.enterText(_feld('D'), '');
    await tester.pump();

    expect(angaben().einsatzabteilungD, isNull);
    expect(find.text(_fehlerText), findsNothing);
  });

  testWidgets('a new year proposes the values of the previous year', (
    tester,
  ) async {
    await speichereEntwurf(
      tester,
      2024,
      ManuelleAngaben(
        einsatzabteilungM: 5,
        einsatzabteilungW: 2,
        einsatzabteilungD: 0,
      ),
    );
    await oeffneSchritt5(tester);

    expect(feldText(tester, 'M'), '5');
    expect(feldText(tester, 'W'), '2');
    expect(feldText(tester, 'D'), '0');
    expect(angaben().einsatzabteilungM, 5);
    expect(find.text('Noch nicht angegeben'), findsNothing);
  });

  testWidgets('entries survive leaving the step and resuming the draft', (
    tester,
  ) async {
    await oeffneSchritt5(tester);
    await tester.enterText(_feld('M'), '7');
    await tester.enterText(_feld('W'), '1');
    await tester.pump();

    await tester.tap(find.byKey(const Key('assistent_weiter')));
    await _settle(tester);
    final gespeichert = await tester.runAsync(
      () => BerichtsentwurfRepository(jldb: db).getByYear(2025).unwrap(),
    );
    final a = gespeichert!.unwrap().angaben;
    expect(a.einsatzabteilungM, 7);
    expect(a.einsatzabteilungW, 1);
    expect(a.einsatzabteilungD, isNull);

    await tester.tap(find.byKey(const Key('assistent_zurueck')));
    await _settle(tester);
    expect(feldText(tester, 'M'), '7');
    expect(feldText(tester, 'W'), '1');
    expect(feldText(tester, 'D'), '');
  });
}
