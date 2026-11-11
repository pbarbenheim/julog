import 'package:flutter_test/flutter_test.dart';
import 'package:julog/l10n/app_localizations.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/ui/kategorie/kategorie_form.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: const [Locale('de')],
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Future<void> _pickThema(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const Key('berichtsthema_field')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  group('KategorieForm (create)', () {
    testWidgets('saves a new Kategorie without Berichtsthema', (tester) async {
      String? savedName;
      Berichtsthema? savedThema = Berichtsthema.sport;
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            onSave: (name, thema) {
              savedName = name;
              savedThema = thema;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Übung');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(savedName, 'Übung');
      expect(savedThema, isNull);
    });

    testWidgets('saves a new Kategorie with Berichtsthema', (tester) async {
      Berichtsthema? savedThema;
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            onSave: (name, thema) {
              savedThema = thema;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Übung');
      await _pickThema(tester, 'Sport');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(savedThema, Berichtsthema.sport);
    });

    testWidgets('Sonstiges can be chosen explicitly', (tester) async {
      Berichtsthema? savedThema;
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            onSave: (name, thema) {
              savedThema = thema;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Übung');
      await _pickThema(tester, 'Sonstiges');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(savedThema, Berichtsthema.sonstiges);
    });

    testWidgets('does not save without a name', (tester) async {
      var saved = false;
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            onSave: (name, thema) {
              saved = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
    });
  });

  group('KategorieForm (edit)', () {
    testWidgets('is prefilled with name and Berichtsthema', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            initialKategorie: const Kategorie(
              id: 'k1',
              name: 'Training',
              berichtsthema: Berichtsthema.wettbewerbstraining,
            ),
            onSave: (name, thema) {},
          ),
        ),
      );

      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Wettbewerbstraining'), findsOneWidget);
    });

    testWidgets('saves changed name and Berichtsthema', (tester) async {
      String? savedName;
      Berichtsthema? savedThema;
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            initialKategorie: const Kategorie(id: 'k1', name: 'Alt'),
            onSave: (name, thema) {
              savedName = name;
              savedThema = thema;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Neu');
      await _pickThema(tester, 'Erste Hilfe und Prävention');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(savedName, 'Neu');
      expect(savedThema, Berichtsthema.ersteHilfeUndPraevention);
    });

    testWidgets('can reset the Berichtsthema to not assigned', (tester) async {
      var called = false;
      Berichtsthema? savedThema = Berichtsthema.sport;
      await tester.pumpWidget(
        _wrap(
          KategorieForm(
            initialKategorie: const Kategorie(
              id: 'k1',
              name: 'K',
              berichtsthema: Berichtsthema.sport,
            ),
            onSave: (name, thema) {
              called = true;
              savedThema = thema;
            },
          ),
        ),
      );

      await _pickThema(tester, 'Nicht zugeordnet');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(savedThema, isNull);
    });
  });
}
