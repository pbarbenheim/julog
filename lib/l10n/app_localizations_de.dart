// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'julog';

  @override
  String get addNewJugendlicher => 'Neuen Jugendlichen hinzufügen';

  @override
  String name(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Namen',
      many: 'Namen',
      one: 'Name',
    );
    return '$_temp0';
  }

  @override
  String get nameRequired => 'Bitte gibt einen Namen ein';

  @override
  String get birthdate => 'Geburtsdatum';

  @override
  String get dateFormatError => 'Ungültiges Datum';

  @override
  String get dateInvalidError => 'Datum außerhalb des gültigen Bereichs';

  @override
  String get memberSince => 'Mitglied seit';

  @override
  String get saveButton => 'Speichern';

  @override
  String get optionalPass => 'Pass (optional)';

  @override
  String stateBirthdate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Geburtsdatum: $dateString';
  }

  @override
  String stateMemberSince(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Mitglied seit: $dateString';
  }

  @override
  String get addNewKategorie => 'Neue Kategorie hinzufügen';

  @override
  String get editKategorie => 'Kategorie bearbeiten';

  @override
  String get kategorieNameRequired => 'Bitte gib einen Namen ein';

  @override
  String get berichtsthema => 'Berichtsthema (optional)';

  @override
  String get berichtsthemaNotAssigned => 'Nicht zugeordnet';

  @override
  String stateBerichtsthema(String thema) {
    return 'Berichtsthema: $thema';
  }

  @override
  String stateExitDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Austrittsdatum: $dateString';
  }

  @override
  String get jahresberichtListeTitel => 'Jahresbericht';

  @override
  String get jahresberichtListeBerichtsjahr => 'Berichtsjahr';

  @override
  String get jahresberichtListeStarten => 'Bericht starten';

  @override
  String get jahresberichtListeFortsetzen => 'Entwurf fortsetzen';

  @override
  String get jahresberichtListeBestehende => 'Bisherige Berichte';

  @override
  String get jahresberichtListeLeer => 'Noch kein Jahresbericht angelegt.';

  @override
  String jahresberichtListeBerichtsjahrEintrag(int jahr) {
    return 'Berichtsjahr $jahr';
  }

  @override
  String get jahresberichtStatusEntwurf => 'Entwurf';

  @override
  String jahresberichtStatusExportiert(DateTime datum) {
    final intl.DateFormat datumDateFormat = intl.DateFormat.yMd(localeName);
    final String datumString = datumDateFormat.format(datum);

    return 'Exportiert am $datumString';
  }

  @override
  String jahresberichtAssistentTitel(int jahr) {
    return 'Jahresbericht $jahr';
  }

  @override
  String jahresberichtAssistentSchrittVon(int nummer, int anzahl) {
    return 'Schritt $nummer von $anzahl';
  }

  @override
  String get jahresberichtAssistentZurueck => 'Zurück';

  @override
  String get jahresberichtAssistentWeiter => 'Weiter';

  @override
  String get jahresberichtAssistentSchliessen => 'Schließen';

  @override
  String jahresberichtAssistentSpeichernFehler(String fehler) {
    return 'Der Entwurf konnte nicht gespeichert werden: $fehler';
  }

  @override
  String get jahresberichtAssistentPlatzhalter =>
      'Dieser Schritt wird in einer späteren Version ausgefüllt.';

  @override
  String get jahresberichtSchritt1Titel => 'Jahr und Übersicht der Zählwerte';

  @override
  String jahresberichtSchritt1Einleitung(DateTime stichtag) {
    final intl.DateFormat stichtagDateFormat = intl.DateFormat.yMd(localeName);
    final String stichtagString = stichtagDateFormat.format(stichtag);

    return 'Julog berechnet diese Zählwerte aus deinen Stammdaten. Stichtag ist der $stichtagString. Hier kannst du sie nur prüfen.';
  }

  @override
  String get jahresberichtSchritt1Hinweis =>
      'Stimmt etwas nicht? Korrigiere die Stammdaten unter \"Jugendliche\" (Eintritt, Austritt, Geburtsdatum, Herkunft), \"Betreuer\" und \"Dienstbuch\". Der Entwurf bleibt dabei gespeichert.';

  @override
  String get jahresberichtSchritt1Neuladen => 'Zählwerte neu berechnen';

  @override
  String get jahresberichtSchritt1Mitglieder => 'Mitglieder am Stichtag';

  @override
  String get jahresberichtSchritt1Alter => 'Alter der Mitglieder am Stichtag';

  @override
  String get jahresberichtSchritt1AlterUnter5 => 'Unter 5 Jahre';

  @override
  String jahresberichtSchritt1AlterJahre(int alter) {
    return '$alter Jahre';
  }

  @override
  String get jahresberichtSchritt1AlterUeber18 => 'Über 18 Jahre';

  @override
  String get jahresberichtSchritt1Betreuer => 'Betreuer';

  @override
  String get jahresberichtSchritt1BetreuerHinweis =>
      'Gezählt werden Betreuer, die in mindestens einem Eintrag des Berichtsjahres stehen.';

  @override
  String get jahresberichtSchritt1Zugang => 'Zugang im Berichtsjahr';

  @override
  String get jahresberichtSchritt1Abgang => 'Abgang im Berichtsjahr';

  @override
  String get jahresberichtSchritt1AbgangEinsatzabteilung =>
      'In die Einsatzabteilung';

  @override
  String get jahresberichtSchritt1AbgangSonstige => 'Sonstige';

  @override
  String get jahresberichtSchritt1AbgangGruende =>
      'Gründe der sonstigen Abgänge';

  @override
  String get jahresberichtSchritt1Gesamt => 'Gesamt';

  @override
  String get jahresberichtSchritt2Titel => 'Berichtsthemen zuordnen';

  @override
  String get jahresberichtSchritt2Einleitung =>
      'Diese Kategorien wurden im Berichtsjahr benutzt und haben noch kein Berichtsthema. Ordne jeder eines der sieben Berichtsthemen zu, auch ausdrücklich \"Sonstiges\". Die Zuordnung wird an der Kategorie gespeichert und gilt auch in den nächsten Jahren.';

  @override
  String get jahresberichtSchritt2KeineOffen =>
      'Alle im Berichtsjahr benutzten Kategorien haben schon ein Berichtsthema. Du kannst direkt weitergehen.';

  @override
  String get jahresberichtSchritt2Auswahl => 'Berichtsthema wählen';

  @override
  String jahresberichtSchritt2Fehler(String fehler) {
    return 'Das Berichtsthema konnte nicht gespeichert werden: $fehler';
  }

  @override
  String get jahresberichtSchritt3Titel => 'Arbeitswerte';

  @override
  String get jahresberichtSchritt3Einleitung =>
      'Julog hat diese Werte aus den Einträgen des Berichtsjahres berechnet. Du kannst jeden Wert überschreiben, um Sonderfälle zu korrigieren, und die Überschreibung wieder zurücknehmen. Darunter gibst du die Werte ein, die Julog nicht kennt.';

  @override
  String get jahresberichtSchritt3BerechnetTitel => 'Berechnete Werte';

  @override
  String get jahresberichtSchritt3ManuellTitel => 'Eigene Angaben';

  @override
  String jahresberichtSchritt3Gruppenabende(String thema) {
    return 'Gruppenabende: $thema';
  }

  @override
  String get jahresberichtSchritt3Dauer =>
      'Durchschnittliche Dauer je Gruppenabend (Minuten)';

  @override
  String get jahresberichtSchritt3Betreuerzahl =>
      'Durchschnittliche Betreuerzahl je Gruppenabend';

  @override
  String get jahresberichtSchritt3Tagesveranstaltungen =>
      'Tagesveranstaltungen';

  @override
  String get jahresberichtSchritt3TagesveranstaltungenHinweis =>
      'Einträge ab 5 Stunden Dauer; sie zählen auch als Gruppenabende.';

  @override
  String get jahresberichtSchritt3Vorbereitung =>
      'Durchschnittliche Vor- und Nachbereitungszeit je Gruppenabend (Minuten)';

  @override
  String get jahresberichtSchritt3SonstigeArbeit =>
      'Stunden für sonstige Arbeit';

  @override
  String jahresberichtSchritt3Berechnet(int wert) {
    return 'Berechnet: $wert';
  }

  @override
  String get jahresberichtSchritt3Ueberschrieben => 'Überschrieben';

  @override
  String get jahresberichtSchritt3Zuruecknehmen =>
      'Überschreibung zurücknehmen';

  @override
  String get jahresberichtSchritt3FehlerZahl =>
      'Bitte eine ganze Zahl ab 0 eingeben.';

  @override
  String get jahresberichtSchritt4Titel => 'Fragen';

  @override
  String get jahresberichtSchritt5Titel => 'Einsatzabteilung';

  @override
  String get jahresberichtSchritt6Titel => 'Zusammenfassung und Export';
}
