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

  /// Helper text in the Kategorie form when the name is locked (ADR-0012)
  ///
  /// In de, this message translates to:
  /// **'Der Name kann nicht geändert werden, weil die Kategorie in einem signierten Eintrag verwendet wird.'**
  String get kategorieNameGesperrt;

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

  /// Wizard step 2 intro
  ///
  /// In de, this message translates to:
  /// **'Diese Kategorien wurden im Berichtsjahr benutzt und haben noch kein Berichtsthema. Ordne jeder eines der sieben Berichtsthemen zu, auch ausdrücklich \"Sonstiges\". Die Zuordnung wird an der Kategorie gespeichert und gilt auch in den nächsten Jahren.'**
  String get jahresberichtSchritt2Einleitung;

  /// Wizard step 2: nothing left to assign
  ///
  /// In de, this message translates to:
  /// **'Alle im Berichtsjahr benutzten Kategorien haben schon ein Berichtsthema. Du kannst direkt weitergehen.'**
  String get jahresberichtSchritt2KeineOffen;

  /// Wizard step 2: hint of the Berichtsthema dropdown
  ///
  /// In de, this message translates to:
  /// **'Berichtsthema wählen'**
  String get jahresberichtSchritt2Auswahl;

  /// Wizard step 2: saving the assignment failed
  ///
  /// In de, this message translates to:
  /// **'Das Berichtsthema konnte nicht gespeichert werden: {fehler}'**
  String jahresberichtSchritt2Fehler(String fehler);

  /// Wizard step 3 title
  ///
  /// In de, this message translates to:
  /// **'Arbeitswerte'**
  String get jahresberichtSchritt3Titel;

  /// Wizard step 3: introduction
  ///
  /// In de, this message translates to:
  /// **'Julog hat diese Werte aus den Einträgen des Berichtsjahres berechnet. Du kannst jeden Wert überschreiben, um Sonderfälle zu korrigieren, und die Überschreibung wieder zurücknehmen. Darunter gibst du die Werte ein, die Julog nicht kennt.'**
  String get jahresberichtSchritt3Einleitung;

  /// Wizard step 3: section title of the computed values
  ///
  /// In de, this message translates to:
  /// **'Berechnete Werte'**
  String get jahresberichtSchritt3BerechnetTitel;

  /// Wizard step 3: section title of the manual values
  ///
  /// In de, this message translates to:
  /// **'Eigene Angaben'**
  String get jahresberichtSchritt3ManuellTitel;

  /// Wizard step 3: label of Arbeit_Wert_01 to 07
  ///
  /// In de, this message translates to:
  /// **'Gruppenabende: {thema}'**
  String jahresberichtSchritt3Gruppenabende(String thema);

  /// Wizard step 3: label of Arbeit_Wert_10
  ///
  /// In de, this message translates to:
  /// **'Durchschnittliche Dauer je Gruppenabend (Minuten)'**
  String get jahresberichtSchritt3Dauer;

  /// Wizard step 3: label of Arbeit_Wert_12
  ///
  /// In de, this message translates to:
  /// **'Durchschnittliche Betreuerzahl je Gruppenabend'**
  String get jahresberichtSchritt3Betreuerzahl;

  /// Wizard step 3: label of Arbeit_Wert_13
  ///
  /// In de, this message translates to:
  /// **'Tagesveranstaltungen'**
  String get jahresberichtSchritt3Tagesveranstaltungen;

  /// Wizard step 3: helper text of Arbeit_Wert_13
  ///
  /// In de, this message translates to:
  /// **'Einträge ab 5 Stunden Dauer; sie zählen auch als Gruppenabende.'**
  String get jahresberichtSchritt3TagesveranstaltungenHinweis;

  /// Wizard step 3: label of Arbeit_Wert_11
  ///
  /// In de, this message translates to:
  /// **'Durchschnittliche Vor- und Nachbereitungszeit je Gruppenabend (Minuten)'**
  String get jahresberichtSchritt3Vorbereitung;

  /// Wizard step 3: label of Arbeit_Wert_20
  ///
  /// In de, this message translates to:
  /// **'Stunden für sonstige Arbeit'**
  String get jahresberichtSchritt3SonstigeArbeit;

  /// Wizard step 3: the computed value shown next to an overridden one
  ///
  /// In de, this message translates to:
  /// **'Berechnet: {wert}'**
  String jahresberichtSchritt3Berechnet(int wert);

  /// Wizard step 3: mark of an overridden value
  ///
  /// In de, this message translates to:
  /// **'Überschrieben'**
  String get jahresberichtSchritt3Ueberschrieben;

  /// Wizard step 3: tooltip of the revert button
  ///
  /// In de, this message translates to:
  /// **'Überschreibung zurücknehmen'**
  String get jahresberichtSchritt3Zuruecknehmen;

  /// Wizard step 3: invalid number input
  ///
  /// In de, this message translates to:
  /// **'Bitte eine ganze Zahl ab 0 eingeben.'**
  String get jahresberichtSchritt3FehlerZahl;

  /// Wizard step 4 title
  ///
  /// In de, this message translates to:
  /// **'Fragen'**
  String get jahresberichtSchritt4Titel;

  /// Wizard step 4: intro
  ///
  /// In de, this message translates to:
  /// **'Beantworte die 16 Ja/Nein-Fragen des Jahresberichts. Die Antworten des Vorjahres sind, wenn es sie gibt, als Vorschlag eingetragen; ändere nur, was sich geändert hat. Eine Antwort nimmst du zurück, indem du sie erneut anklickst.'**
  String get jahresberichtSchritt4Einleitung;

  /// Wizard step 4: group 01-03
  ///
  /// In de, this message translates to:
  /// **'Teilnahme'**
  String get jahresberichtSchritt4GruppeTeilnahme;

  /// Wizard step 4: group 04-07
  ///
  /// In de, this message translates to:
  /// **'Aktivitäten'**
  String get jahresberichtSchritt4GruppeAktivitaeten;

  /// Wizard step 4: group 08-12
  ///
  /// In de, this message translates to:
  /// **'Wettbewerbe'**
  String get jahresberichtSchritt4GruppeWettbewerbe;

  /// Wizard step 4: group 13-16
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get jahresberichtSchritt4GruppeSonstiges;

  /// Wizard step 4: question 01
  ///
  /// In de, this message translates to:
  /// **'Teilnahme am Gemeinschaftsleben'**
  String get jahresberichtSchritt4Frage01;

  /// Wizard step 4: question 02
  ///
  /// In de, this message translates to:
  /// **'Teilnahme an externen Bildungsveranstaltungen'**
  String get jahresberichtSchritt4Frage02;

  /// Wizard step 4: question 03
  ///
  /// In de, this message translates to:
  /// **'Teilnahme an internen Bildungsveranstaltungen der JF/KF'**
  String get jahresberichtSchritt4Frage03;

  /// Wizard step 4: question 04
  ///
  /// In de, this message translates to:
  /// **'Internationale Jugendarbeit'**
  String get jahresberichtSchritt4Frage04;

  /// Wizard step 4: question 05
  ///
  /// In de, this message translates to:
  /// **'Natur / Umweltschutz'**
  String get jahresberichtSchritt4Frage05;

  /// Wizard step 4: question 06
  ///
  /// In de, this message translates to:
  /// **'Aktive Mitgliederwerbung'**
  String get jahresberichtSchritt4Frage06;

  /// Wizard step 4: question 07
  ///
  /// In de, this message translates to:
  /// **'An der Schule / in Kindergärten'**
  String get jahresberichtSchritt4Frage07;

  /// Wizard step 4: question 08
  ///
  /// In de, this message translates to:
  /// **'Jugendflamme'**
  String get jahresberichtSchritt4Frage08;

  /// Wizard step 4: question 09
  ///
  /// In de, this message translates to:
  /// **'Bundeswettbewerb'**
  String get jahresberichtSchritt4Frage09;

  /// Wizard step 4: question 10
  ///
  /// In de, this message translates to:
  /// **'Leistungsspange'**
  String get jahresberichtSchritt4Frage10;

  /// Wizard step 4: question 11
  ///
  /// In de, this message translates to:
  /// **'CTIF'**
  String get jahresberichtSchritt4Frage11;

  /// Wizard step 4: question 12
  ///
  /// In de, this message translates to:
  /// **'Landesspezifischer Wettbewerb'**
  String get jahresberichtSchritt4Frage12;

  /// Wizard step 4: question 13
  ///
  /// In de, this message translates to:
  /// **'Die JF/KF hat mehr Interessierte, als sie aufnehmen kann'**
  String get jahresberichtSchritt4Frage13;

  /// Wizard step 4: question 14
  ///
  /// In de, this message translates to:
  /// **'Die JF/KF hat Nachwuchssorgen'**
  String get jahresberichtSchritt4Frage14;

  /// Wizard step 4: question 15
  ///
  /// In de, this message translates to:
  /// **'Die JF/KF hat zu wenig Betreuer'**
  String get jahresberichtSchritt4Frage15;

  /// Wizard step 4: question 16
  ///
  /// In de, this message translates to:
  /// **'Die JF/KF hat einen eigenen Sprecher'**
  String get jahresberichtSchritt4Frage16;

  /// Wizard step 4: answer yes
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get jahresberichtSchritt4Ja;

  /// Wizard step 4: answer no
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get jahresberichtSchritt4Nein;

  /// Wizard step 4: mark of an unanswered question
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get jahresberichtSchritt4Offen;

  /// Wizard step 4: number of unanswered questions
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{1 Frage noch offen} other{{anzahl} Fragen noch offen}}'**
  String jahresberichtSchritt4OffenAnzahl(int anzahl);

  /// Wizard step 4: all questions answered
  ///
  /// In de, this message translates to:
  /// **'Alle Fragen beantwortet'**
  String get jahresberichtSchritt4AlleBeantwortet;

  /// Wizard step 5 title
  ///
  /// In de, this message translates to:
  /// **'Einsatzabteilung'**
  String get jahresberichtSchritt5Titel;

  /// Wizard step 5: intro
  ///
  /// In de, this message translates to:
  /// **'Gib an, wie viele unter 27-Jährige zur Einsatzabteilung gehören, getrennt nach männlich, weiblich und divers. Der Wert des Vorjahres ist, wenn es ihn gibt, als Vorschlag eingetragen; prüfe ihn und passe ihn an. Die Eingabe bleibt im Entwurf.'**
  String get jahresberichtSchritt5Einleitung;

  /// Wizard step 5: field M
  ///
  /// In de, this message translates to:
  /// **'Männlich'**
  String get jahresberichtSchritt5Maennlich;

  /// Wizard step 5: field W
  ///
  /// In de, this message translates to:
  /// **'Weiblich'**
  String get jahresberichtSchritt5Weiblich;

  /// Wizard step 5: field D
  ///
  /// In de, this message translates to:
  /// **'Divers'**
  String get jahresberichtSchritt5Divers;

  /// Wizard step 5: helper text of an empty field
  ///
  /// In de, this message translates to:
  /// **'Noch nicht angegeben'**
  String get jahresberichtSchritt5Offen;

  /// Wizard step 5: invalid number input
  ///
  /// In de, this message translates to:
  /// **'Bitte eine ganze Zahl ab 0 eingeben.'**
  String get jahresberichtSchritt5FehlerZahl;

  /// Wizard step 6 title
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung und Export'**
  String get jahresberichtSchritt6Titel;

  /// Wizard step 6: introduction
  ///
  /// In de, this message translates to:
  /// **'Prüfe hier alle Werte des Berichts. Werte, die du überschrieben hast, sind markiert. Sind alle Angaben vollständig, kannst du die XML-Datei exportieren und im Jahresberichtstool hochladen.'**
  String get jahresberichtSchritt6Einleitung;

  /// Wizard step 6: heading of the list of missing parts
  ///
  /// In de, this message translates to:
  /// **'Der Bericht ist noch nicht vollständig, der Export ist gesperrt. Das fehlt:'**
  String get jahresberichtSchritt6Unvollstaendig;

  /// Wizard step 6: one missing part and the step where it is entered
  ///
  /// In de, this message translates to:
  /// **'Schritt {nummer} ({titel}): {was}'**
  String jahresberichtSchritt6Fehlt(int nummer, String titel, String was);

  /// Wizard step 6: categories used in the year without Berichtsthema
  ///
  /// In de, this message translates to:
  /// **'Kein Berichtsthema für: {kategorien}'**
  String jahresberichtSchritt6FehltKategorien(String kategorien);

  /// Wizard step 6: Arbeit_Wert_11 is missing
  ///
  /// In de, this message translates to:
  /// **'Durchschnittliche Vor- und Nachbereitungszeit fehlt'**
  String get jahresberichtSchritt6FehltVorbereitung;

  /// Wizard step 6: Arbeit_Wert_20 is missing
  ///
  /// In de, this message translates to:
  /// **'Stunden für sonstige Arbeit fehlen'**
  String get jahresberichtSchritt6FehltSonstigeArbeit;

  /// Wizard step 6: unanswered questions
  ///
  /// In de, this message translates to:
  /// **'Fragen ohne Antwort: {nummern}'**
  String jahresberichtSchritt6FehltFragen(String nummern);

  /// Wizard step 6: missing Einsatzabteilung numbers
  ///
  /// In de, this message translates to:
  /// **'Unter 27-Jährige in der Einsatzabteilung fehlen für: {geschlechter}'**
  String jahresberichtSchritt6FehltEinsatzabteilung(String geschlechter);

  /// Wizard step 6: nothing is missing
  ///
  /// In de, this message translates to:
  /// **'Alle Angaben sind vollständig. Der Bericht kann exportiert werden.'**
  String get jahresberichtSchritt6Vollstaendig;

  /// Wizard step 6: section title of the computed counts
  ///
  /// In de, this message translates to:
  /// **'Zählwerte'**
  String get jahresberichtSchritt6ZaehlwerteTitel;

  /// Wizard step 6: section title of the work values
  ///
  /// In de, this message translates to:
  /// **'Arbeitswerte'**
  String get jahresberichtSchritt6ArbeitswerteTitel;

  /// Wizard step 6: section title of the manual answers
  ///
  /// In de, this message translates to:
  /// **'Eigene Angaben'**
  String get jahresberichtSchritt6AngabenTitel;

  /// Wizard step 6: label of Alter_Anz_EA_bis_27
  ///
  /// In de, this message translates to:
  /// **'Unter 27-Jährige in der Einsatzabteilung'**
  String get jahresberichtSchritt6Einsatzabteilung;

  /// Wizard step 6: label of a yes/no question
  ///
  /// In de, this message translates to:
  /// **'Frage {nummer}'**
  String jahresberichtSchritt6Frage(int nummer);

  /// Wizard step 6: answer yes
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get jahresberichtSchritt6Ja;

  /// Wizard step 6: answer no
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get jahresberichtSchritt6Nein;

  /// Wizard step 6: question not answered yet
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get jahresberichtSchritt6Offen;

  /// Wizard step 6: export button
  ///
  /// In de, this message translates to:
  /// **'Als XML exportieren'**
  String get jahresberichtSchritt6Exportieren;

  /// Wizard step 6: export button after an earlier export
  ///
  /// In de, this message translates to:
  /// **'Erneut exportieren'**
  String get jahresberichtSchritt6ErneutExportieren;

  /// Wizard step 6: date of the last export
  ///
  /// In de, this message translates to:
  /// **'Zuletzt exportiert am {datum}'**
  String jahresberichtSchritt6ZuletztExportiert(DateTime datum);

  /// Wizard step 6: export succeeded
  ///
  /// In de, this message translates to:
  /// **'Exportiert nach {pfad}'**
  String jahresberichtSchritt6ExportErfolg(String pfad);

  /// Wizard step 6: the file was written, but saving the exported status failed
  ///
  /// In de, this message translates to:
  /// **'Der Bericht wurde nach {pfad} exportiert, aber der Status \"exportiert\" konnte nicht gespeichert werden: {fehler}'**
  String jahresberichtSchritt6ExportStatusFehler(String pfad, String fehler);

  /// Wizard step 6: confirm button of the save dialog
  ///
  /// In de, this message translates to:
  /// **'Exportieren'**
  String get jahresberichtSchritt6ExportBestaetigen;

  /// Jahresbericht screens: loading the data failed
  ///
  /// In de, this message translates to:
  /// **'Fehler: {fehler}'**
  String jahresberichtFehler(String fehler);

  /// Wizard step 6: export failed
  ///
  /// In de, this message translates to:
  /// **'Der Bericht konnte nicht exportiert werden: {fehler}'**
  String jahresberichtSchritt6ExportFehler(String fehler);
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
