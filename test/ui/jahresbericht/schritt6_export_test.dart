import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jldb/jldb.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/jahresbericht/jahresbericht_xml.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';
import 'package:julog/l10n/app_localizations.dart';
import 'package:julog/provider/jldb/jldb.dart';
import 'package:julog/provider/jldb/julog_file.dart';
import 'package:julog/repository/berichtsentwurf/repository.dart';
import 'package:julog/repository/betreuer/repository.dart';
import 'package:julog/repository/eintrag/eintrag_repo.dart';
import 'package:julog/repository/jugendliche/repository.dart';
import 'package:julog/repository/kategorie/repository.dart';
import 'package:julog/repository/model/berichtsentwurf/berichtsentwurf.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/ui/jahresbericht/assistent/assistent_screen.dart';
import 'package:julog/view_model/jahresbericht/export_ziel.dart';
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

/// Taps the export button and waits for the whole export (real file I/O).
Future<void> _exportiere(WidgetTester tester) async {
  await tester.tap(_exportKnopf);
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    final knopf = tester.widget<FilledButton>(_exportKnopf);
    if (i >= 1 && knopf.onPressed != null) return;
  }
}

final _exportKnopf = find.byKey(const Key('schritt6_export'));
final _fehltKarte = find.byKey(const Key('schritt6_fehlt'));

class _MarkExportedFehlschlag extends BerichtsentwurfRepository {
  _MarkExportedFehlschlag({required super.jldb});

  @override
  AsyncVoidResult markExported(int year, [DateTime? exportedAt]) async =>
      Failure(Exception('Platte voll'));
}

void main() {
  late Jldb db;
  late ProviderContainer container;
  late Directory zielOrdner;

  /// Was der (gefälschte) Speichern-Dialog antwortet; `null` = abgebrochen.
  late String? Function(String vorgeschlagenerName) zielAntwort;
  late List<String> vorgeschlageneNamen;

  /// Replaces the Berichtsentwurf repository (e.g. to make markExported fail).
  BerichtsentwurfRepository Function(Jldb db)? entwurfRepository;

  ProviderContainer baueContainer() => ProviderContainer(
    overrides: [
      julogServiceProvider.overrideWith(() => _FakeJulogService(db)),
      jahresberichtExportZielProvider.overrideWithValue((name, _) async {
        vorgeschlageneNamen.add(name);
        return zielAntwort(name);
      }),
      if (entwurfRepository != null)
        berichtsentwurfRepositoryProvider.overrideWithValue(
          entwurfRepository!(db),
        ),
    ],
  );

  setUp(() async {
    entwurfRepository = null;
    db = (await Jldb.create(':memory:', domain: 'test.org').unwrap());
    zielOrdner = Directory.systemTemp.createTempSync('julog_export_test');
    vorgeschlageneNamen = [];
    zielAntwort = (name) => '${zielOrdner.path}/$name';
    container = baueContainer();
  });
  tearDown(() async {
    container.dispose();
    await db.close();
    zielOrdner.deleteSync(recursive: true);
  });

  /// 2025: one Mitglied (Max, m), one Betreuerin (Bea, w), two Einträge
  /// (2 h and 6 h) in a category with the given Berichtsthema.
  Future<void> legeDatenAn(
    WidgetTester tester, {
    Berichtsthema? thema = Berichtsthema.feuerwehrtechnik,
  }) => tester.runAsync(() async {
    await container.read(jugendlicheRepositoryProvider).save((
      name: 'Max',
      gender: Gender.male,
      birthDate: DateTime(2012, 6, 15),
      memberSince: DateTime(2020, 1, 1),
      pass: null,
      herkunft: Herkunft.neu,
    )).unwrap();
    final kategorie = await container.read(kategorieRepositoryProvider).save((
      name: 'Übung',
      berichtsthema: thema,
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

  Future<void> oeffneSchritt6(WidgetTester tester) async {
    if (entwurfRepository != null) {
      container.dispose();
      container = baueContainer();
    }
    tester.view.physicalSize = const Size(1600, 6000);
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
    await tester.tap(find.byKey(const Key('assistent_schritt_5')));
    await _settle(tester);
  }

  void setzeVollstaendigeAngaben() {
    container
        .read(jahresberichtAssistentViewModelProvider(2025).notifier)
        .aendereAngaben(
          (_) => ManuelleAngaben(
            fragen: {for (var n = 1; n <= anzahlFragen; n++) n: n.isEven},
            arbeitWert11: 30,
            arbeitWert20: 120,
            einsatzabteilungM: 3,
            einsatzabteilungW: 2,
            einsatzabteilungD: 0,
          ),
        );
  }

  Berichtsentwurf? entwurfInDb() => container
      .read(jahresberichtAssistentViewModelProvider(2025))
      .requireValue
      .entwurf;

  Future<Berichtsentwurf> gespeicherterEntwurf(WidgetTester tester) async =>
      (await tester.runAsync(
        () => container
            .read(berichtsentwurfRepositoryProvider)
            .getByYear(2025)
            .unwrap(),
      ))!.unwrap();

  group('incomplete report', () {
    testWidgets('says what is missing and where, and blocks the export', (
      tester,
    ) async {
      await legeDatenAn(tester, thema: null);
      await oeffneSchritt6(tester);

      expect(_fehltKarte, findsOneWidget);
      expect(
        find.textContaining('Schritt 2 (Berichtsthemen zuordnen)'),
        findsOneWidget,
      );
      expect(find.textContaining('Übung'), findsOneWidget);
      expect(find.textContaining('Schritt 3 (Arbeitswerte)'), findsNWidgets(2));
      expect(find.textContaining('Schritt 4 (Fragen)'), findsOneWidget);
      expect(
        find.textContaining('Schritt 5 (Einsatzabteilung)'),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(_exportKnopf).onPressed, isNull);
    });

    testWidgets('only lists the parts that are actually missing', (
      tester,
    ) async {
      await legeDatenAn(tester);
      await oeffneSchritt6(tester);
      container
          .read(jahresberichtAssistentViewModelProvider(2025).notifier)
          .aendereAngaben(
            (_) => ManuelleAngaben(
              fragen: {for (var n = 1; n <= anzahlFragen; n++) n: true},
              arbeitWert11: 30,
              arbeitWert20: 120,
              einsatzabteilungM: 3,
              einsatzabteilungW: 2,
            ),
          );
      await tester.pump();

      expect(find.textContaining('Schritt 2'), findsNothing);
      expect(find.textContaining('Schritt 3'), findsNothing);
      expect(find.textContaining('Schritt 4'), findsNothing);
      expect(find.textContaining('Schritt 5'), findsOneWidget);
      expect(tester.widget<FilledButton>(_exportKnopf).onPressed, isNull);
    });
  });

  testWidgets('shows Zählwerte, Arbeitswerte and manual answers', (
    tester,
  ) async {
    await legeDatenAn(tester);
    await oeffneSchritt6(tester);
    setzeVollstaendigeAngaben();
    container
        .read(jahresberichtAssistentViewModelProvider(2025).notifier)
        .aendereUeberschreibungen(
          (_) => Ueberschreibungen({'Arbeit_Wert_10': 99}),
        );
    await tester.pump();

    expect(_fehltKarte, findsNothing);
    // Zählwerte: one male Mitglied, one female Betreuerin.
    expect(find.byKey(const Key('schritt6_wert_Mitglieder_Anz_M')), findsOne);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('schritt6_wert_Mitglieder_Anz_M')))
          .data,
      '1',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('schritt6_wert_Betreuer_Anz_W')))
          .data,
      '1',
    );
    // Arbeitswerte: 2 Gruppenabende feuerwehrtechnisch, 240 min computed but
    // overridden to 99.
    expect(
      tester
          .widget<Text>(find.byKey(const Key('schritt6_wert_Arbeit_Wert_01')))
          .data,
      '2',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('schritt6_wert_Arbeit_Wert_10')))
          .data,
      '99',
    );
    expect(find.text('Überschrieben'), findsOneWidget);
    expect(find.text('Berechnet: 240'), findsOneWidget);
    // Manual answers.
    expect(
      tester
          .widget<Text>(find.byKey(const Key('schritt6_wert_Arbeit_Wert_11')))
          .data,
      '30',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('schritt6_wert_Arbeit_Wert_20')))
          .data,
      '120',
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('schritt6_wert_Alter_Anz_EA_bis_27_M')),
          )
          .data,
      '3',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('schritt6_frage_1'))).data,
      'Nein',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('schritt6_frage_2'))).data,
      'Ja',
    );
    expect(tester.widget<FilledButton>(_exportKnopf).onPressed, isNotNull);
  });

  group('export', () {
    testWidgets('writes the XML to the chosen target and marks the draft', (
      tester,
    ) async {
      await legeDatenAn(tester);
      await oeffneSchritt6(tester);
      setzeVollstaendigeAngaben();
      await tester.pump();
      expect(entwurfInDb()!.status, EntwurfStatus.entwurf);

      await _exportiere(tester);

      expect(vorgeschlageneNamen, ['jahresbericht_2025.xml']);
      final datei = File('${zielOrdner.path}/jahresbericht_2025.xml');
      expect(datei.existsSync(), isTrue);
      final xml = datei.readAsStringSync();
      expect(xml, startsWith('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(xml, contains('<field key="Organisationen">1</field>'));
      expect(xml, contains('<field key="Mitglieder_Anz_M">1</field>'));
      expect(xml, contains('<field key="Betreuer_Anz_W">1</field>'));
      expect(xml, contains('<field key="Arbeit_Wert_01">2</field>'));
      expect(xml, contains('<field key="Arbeit_Wert_10">240</field>'));
      expect(xml, contains('<field key="Arbeit_Wert_11">30</field>'));
      expect(xml, contains('<field key="Arbeit_Wert_13">1</field>'));
      expect(xml, contains('<field key="Frage_02_MML_JA">1</field>'));
      expect(xml, contains('<field key="Frage_01_MML_JA">0</field>'));
      expect(xml, contains('<field key="Alter_Anz_EA_bis_27_M">3</field>'));
      expect(
        datei.readAsBytesSync(),
        erzeugeJahresberichtXmlBytes(
          berichtsjahr: 2025,
          jugendliche: container
              .read(jahresberichtAssistentViewModelProvider(2025))
              .requireValue
              .jugendliche,
          betreuer: container
              .read(jahresberichtAssistentViewModelProvider(2025))
              .requireValue
              .betreuer,
          eintraege: container
              .read(jahresberichtAssistentViewModelProvider(2025))
              .requireValue
              .eintraege,
          kategorien: container
              .read(jahresberichtAssistentViewModelProvider(2025))
              .requireValue
              .kategorien,
          angaben: entwurfInDb()!.angaben,
        ),
      );

      final gespeichert = await gespeicherterEntwurf(tester);
      expect(gespeichert.status, EntwurfStatus.exportiert);
      expect(gespeichert.exportedAt, isNotNull);
      // The pending answers were persisted before exporting.
      expect(gespeichert.angaben.arbeitWert11, 30);
      expect(find.textContaining('Zuletzt exportiert am'), findsOneWidget);
    });

    testWidgets('cancelling the dialog writes nothing and keeps the status', (
      tester,
    ) async {
      await legeDatenAn(tester);
      await oeffneSchritt6(tester);
      setzeVollstaendigeAngaben();
      await tester.pump();
      zielAntwort = (_) => null;

      await _exportiere(tester);

      expect(vorgeschlageneNamen, hasLength(1));
      expect(zielOrdner.listSync(), isEmpty);
      final gespeichert = await gespeicherterEntwurf(tester);
      expect(gespeichert.status, EntwurfStatus.entwurf);
      expect(gespeichert.exportedAt, isNull);
    });

    testWidgets('can be repeated and updates the export date', (tester) async {
      await legeDatenAn(tester);
      await oeffneSchritt6(tester);
      setzeVollstaendigeAngaben();
      await tester.pump();

      await _exportiere(tester);
      final erstes = (await gespeicherterEntwurf(tester)).exportedAt!;

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );
      await _exportiere(tester);

      final zweites = await gespeicherterEntwurf(tester);
      expect(zweites.status, EntwurfStatus.exportiert);
      expect(zweites.exportedAt!.isAfter(erstes), isTrue);
      expect(vorgeschlageneNamen, hasLength(2));
    });

    testWidgets('the year list shows exported with date afterwards', (
      tester,
    ) async {
      await legeDatenAn(tester);
      await oeffneSchritt6(tester);
      setzeVollstaendigeAngaben();
      await tester.pump();
      // Keep the list provider alive so the export has to refresh it.
      final listeSub = container.listen(
        berichtsentwuerfeViewModelProvider,
        (_, _) {},
      );
      addTearDown(listeSub.close);
      Future<List<Berichtsentwurf>> ladeListe() async {
        for (var i = 0; i < 50; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          final wert = container.read(berichtsentwuerfeViewModelProvider);
          if (wert.hasValue && !wert.isLoading) return wert.requireValue;
        }
        fail('Jahresliste wurde nicht geladen');
      }

      expect((await ladeListe()).single.status, EntwurfStatus.entwurf);

      await _exportiere(tester);

      final liste = await ladeListe();
      expect(liste.single.status, EntwurfStatus.exportiert);
      expect(liste.single.exportedAt, isNotNull);
    });

    testWidgets('a write error is reported and the draft stays unexported', (
      tester,
    ) async {
      await legeDatenAn(tester);
      await oeffneSchritt6(tester);
      setzeVollstaendigeAngaben();
      await tester.pump();
      zielAntwort = (name) => '${zielOrdner.path}/gibt-es-nicht/$name';

      await _exportiere(tester);

      expect(find.textContaining('konnte nicht exportiert werden'), findsOne);
      final gespeichert = await gespeicherterEntwurf(tester);
      expect(gespeichert.status, EntwurfStatus.entwurf);
    });

    testWidgets(
      'a failure to save the status is reported separately from the file',
      (tester) async {
        entwurfRepository = (db) => _MarkExportedFehlschlag(jldb: db);
        await legeDatenAn(tester);
        await oeffneSchritt6(tester);
        setzeVollstaendigeAngaben();
        await tester.pump();

        await _exportiere(tester);

        expect(tester.takeException(), isNull);
        expect(
          File('${zielOrdner.path}/jahresbericht_2025.xml').existsSync(),
          isTrue,
        );
        expect(
          find.textContaining('konnte nicht gespeichert werden'),
          findsOne,
        );
        expect(
          find.textContaining('konnte nicht exportiert werden'),
          findsNothing,
        );
        final gespeichert = await gespeicherterEntwurf(tester);
        expect(gespeichert.status, EntwurfStatus.entwurf);
        expect(tester.widget<FilledButton>(_exportKnopf).onPressed, isNotNull);
      },
    );
  });
}
