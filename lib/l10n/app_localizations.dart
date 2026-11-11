import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'julog'**
  String get appTitle;

  /// Add new jugendlicher
  ///
  /// In de, this message translates to:
  /// **'Neuen Jugendlichen hinzufügen'**
  String get addNewJugendlicher;

  /// name
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{Name} many{Namen} other{Namen}}'**
  String name(int count);

  /// Name required
  ///
  /// In de, this message translates to:
  /// **'Bitte gibt einen Namen ein'**
  String get nameRequired;

  /// birthday
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum'**
  String get birthdate;

  /// Date format error
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Datum'**
  String get dateFormatError;

  /// Date invalid error
  ///
  /// In de, this message translates to:
  /// **'Datum außerhalb des gültigen Bereichs'**
  String get dateInvalidError;

  /// Member sice
  ///
  /// In de, this message translates to:
  /// **'Mitglied seit'**
  String get memberSince;

  /// save
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get saveButton;

  /// Optional pass
  ///
  /// In de, this message translates to:
  /// **'Pass (optional)'**
  String get optionalPass;

  /// State birthdate
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum: {date}'**
  String stateBirthdate(DateTime date);

  /// State member since
  ///
  /// In de, this message translates to:
  /// **'Mitglied seit: {date}'**
  String stateMemberSince(DateTime date);

  /// Add new kategorie
  ///
  /// In de, this message translates to:
  /// **'Neue Kategorie hinzufügen'**
  String get addNewKategorie;

  /// Edit kategorie
  ///
  /// In de, this message translates to:
  /// **'Kategorie bearbeiten'**
  String get editKategorie;

  /// Kategorie name required
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein'**
  String get kategorieNameRequired;

  /// Berichtsthema field label in the Kategorie form
  ///
  /// In de, this message translates to:
  /// **'Berichtsthema (optional)'**
  String get berichtsthema;

  /// Kategorie has no Berichtsthema yet
  ///
  /// In de, this message translates to:
  /// **'Nicht zugeordnet'**
  String get berichtsthemaNotAssigned;

  /// State Berichtsthema of a Kategorie
  ///
  /// In de, this message translates to:
  /// **'Berichtsthema: {thema}'**
  String stateBerichtsthema(String thema);

  /// State exit date
  ///
  /// In de, this message translates to:
  /// **'Austrittsdatum: {date}'**
  String stateExitDate(DateTime date);

  /// Title of the Jahresbericht overview page
  ///
  /// In de, this message translates to:
  /// **'Jahresbericht'**
  String get jahresberichtListeTitel;

  /// Label of the Berichtsjahr selection on the overview page
  ///
  /// In de, this message translates to:
  /// **'Berichtsjahr'**
  String get jahresberichtListeBerichtsjahr;

  /// Starts a Jahresbericht for the selected Berichtsjahr (no draft yet)
  ///
  /// In de, this message translates to:
  /// **'Bericht starten'**
  String get jahresberichtListeStarten;

  /// Continues the existing draft of the selected Berichtsjahr
  ///
  /// In de, this message translates to:
  /// **'Entwurf fortsetzen'**
  String get jahresberichtListeFortsetzen;

  /// Heading of the list of existing Berichtsentwuerfe
  ///
  /// In de, this message translates to:
  /// **'Bisherige Berichte'**
  String get jahresberichtListeBestehende;

  /// Hint when there is no Berichtsentwurf yet
  ///
  /// In de, this message translates to:
  /// **'Noch kein Jahresbericht angelegt.'**
  String get jahresberichtListeLeer;

  /// List entry of a Berichtsentwurf
  ///
  /// In de, this message translates to:
  /// **'Berichtsjahr {jahr}'**
  String jahresberichtListeBerichtsjahrEintrag(int jahr);

  /// Status of a Berichtsentwurf that was not exported yet
  ///
  /// In de, this message translates to:
  /// **'Entwurf'**
  String get jahresberichtStatusEntwurf;

  /// Status of an exported Berichtsentwurf
  ///
  /// In de, this message translates to:
  /// **'Exportiert am {datum}'**
  String jahresberichtStatusExportiert(DateTime datum);

  /// Title of the Jahresbericht wizard
  ///
  /// In de, this message translates to:
  /// **'Jahresbericht {jahr}'**
  String jahresberichtAssistentTitel(int jahr);

  /// Position in the Jahresbericht wizard
  ///
  /// In de, this message translates to:
  /// **'Schritt {nummer} von {anzahl}'**
  String jahresberichtAssistentSchrittVon(int nummer, int anzahl);

  /// Wizard: previous step
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get jahresberichtAssistentZurueck;

  /// Wizard: next step
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get jahresberichtAssistentWeiter;

  /// Wizard: close and return to the list
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get jahresberichtAssistentSchliessen;

  /// Wizard: saving the draft failed
  ///
  /// In de, this message translates to:
  /// **'Der Entwurf konnte nicht gespeichert werden: {fehler}'**
  String jahresberichtAssistentSpeichernFehler(String fehler);

  /// Wizard: hint shown by steps that are not implemented yet
  ///
  /// In de, this message translates to:
  /// **'Dieser Schritt wird in einer späteren Version ausgefüllt.'**
  String get jahresberichtAssistentPlatzhalter;

  /// Wizard step 1 title
  ///
  /// In de, this message translates to:
  /// **'Jahr und Übersicht der Zählwerte'**
  String get jahresberichtSchritt1Titel;

  /// Wizard step 1 intro
  ///
  /// In de, this message translates to:
  /// **'Julog berechnet diese Zählwerte aus deinen Stammdaten. Stichtag ist der {stichtag}. Hier kannst du sie nur prüfen.'**
  String jahresberichtSchritt1Einleitung(DateTime stichtag);

  /// Wizard step 1: where to correct the Stammdaten
  ///
  /// In de, this message translates to:
  /// **'Stimmt etwas nicht? Korrigiere die Stammdaten unter \"Jugendliche\" (Eintritt, Austritt, Geburtsdatum, Herkunft), \"Betreuer\" und \"Dienstbuch\". Der Entwurf bleibt dabei gespeichert.'**
  String get jahresberichtSchritt1Hinweis;

  /// Wizard step 1: reload the Stammdaten
  ///
  /// In de, this message translates to:
  /// **'Zählwerte neu berechnen'**
  String get jahresberichtSchritt1Neuladen;

  /// Wizard step 1 section
  ///
  /// In de, this message translates to:
  /// **'Mitglieder am Stichtag'**
  String get jahresberichtSchritt1Mitglieder;

  /// Wizard step 1 section
  ///
  /// In de, this message translates to:
  /// **'Alter der Mitglieder am Stichtag'**
  String get jahresberichtSchritt1Alter;

  /// Wizard step 1: age row
  ///
  /// In de, this message translates to:
  /// **'Unter 5 Jahre'**
  String get jahresberichtSchritt1AlterUnter5;

  /// Wizard step 1: age row
  ///
  /// In de, this message translates to:
  /// **'{alter} Jahre'**
  String jahresberichtSchritt1AlterJahre(int alter);

  /// Wizard step 1: age row
  ///
  /// In de, this message translates to:
  /// **'Über 18 Jahre'**
  String get jahresberichtSchritt1AlterUeber18;

  /// Wizard step 1 section
  ///
  /// In de, this message translates to:
  /// **'Betreuer'**
  String get jahresberichtSchritt1Betreuer;

  /// Wizard step 1: how Betreuer are counted
  ///
  /// In de, this message translates to:
  /// **'Gezählt werden Betreuer, die in mindestens einem Eintrag des Berichtsjahres stehen.'**
  String get jahresberichtSchritt1BetreuerHinweis;

  /// Wizard step 1 section
  ///
  /// In de, this message translates to:
  /// **'Zugang im Berichtsjahr'**
  String get jahresberichtSchritt1Zugang;

  /// Wizard step 1 section
  ///
  /// In de, this message translates to:
  /// **'Abgang im Berichtsjahr'**
  String get jahresberichtSchritt1Abgang;

  /// Wizard step 1: Abgang row
  ///
  /// In de, this message translates to:
  /// **'In die Einsatzabteilung'**
  String get jahresberichtSchritt1AbgangEinsatzabteilung;

  /// Wizard step 1: Abgang row
  ///
  /// In de, this message translates to:
  /// **'Sonstige'**
  String get jahresberichtSchritt1AbgangSonstige;

  /// Wizard step 1: heading for the reasons of the sonstige Abgaenge
  ///
  /// In de, this message translates to:
  /// **'Gründe der sonstigen Abgänge'**
  String get jahresberichtSchritt1AbgangGruende;

  /// Wizard step 1: total column
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get jahresberichtSchritt1Gesamt;

  /// Wizard step 2 title
  ///
  /// In de, this message translates to:
  /// **'Berichtsthemen zuordnen'**
  String get jahresberichtSchritt2Titel;

  /// Wizard step 3 title
  ///
  /// In de, this message translates to:
  /// **'Arbeitswerte'**
  String get jahresberichtSchritt3Titel;

  /// Wizard step 4 title
  ///
  /// In de, this message translates to:
  /// **'Fragen'**
  String get jahresberichtSchritt4Titel;

  /// Wizard step 5 title
  ///
  /// In de, this message translates to:
  /// **'Einsatzabteilung'**
  String get jahresberichtSchritt5Titel;

  /// Wizard step 6 title
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung und Export'**
  String get jahresberichtSchritt6Titel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
