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
  String get kategorieNameGesperrt =>
      'Der Name kann nicht geändert werden, weil die Kategorie in einem signierten Eintrag verwendet wird.';

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
  String get jahresberichtSchritt4Einleitung =>
      'Beantworte die 16 Ja/Nein-Fragen des Jahresberichts. Die Antworten des Vorjahres sind, wenn es sie gibt, als Vorschlag eingetragen; ändere nur, was sich geändert hat. Eine Antwort nimmst du zurück, indem du sie erneut anklickst.';

  @override
  String get jahresberichtSchritt4GruppeTeilnahme => 'Teilnahme';

  @override
  String get jahresberichtSchritt4GruppeAktivitaeten => 'Aktivitäten';

  @override
  String get jahresberichtSchritt4GruppeWettbewerbe => 'Wettbewerbe';

  @override
  String get jahresberichtSchritt4GruppeSonstiges => 'Sonstiges';

  @override
  String get jahresberichtSchritt4Frage01 => 'Teilnahme am Gemeinschaftsleben';

  @override
  String get jahresberichtSchritt4Frage02 =>
      'Teilnahme an externen Bildungsveranstaltungen';

  @override
  String get jahresberichtSchritt4Frage03 =>
      'Teilnahme an internen Bildungsveranstaltungen der JF/KF';

  @override
  String get jahresberichtSchritt4Frage04 => 'Internationale Jugendarbeit';

  @override
  String get jahresberichtSchritt4Frage05 => 'Natur / Umweltschutz';

  @override
  String get jahresberichtSchritt4Frage06 => 'Aktive Mitgliederwerbung';

  @override
  String get jahresberichtSchritt4Frage07 => 'An der Schule / in Kindergärten';

  @override
  String get jahresberichtSchritt4Frage08 => 'Jugendflamme';

  @override
  String get jahresberichtSchritt4Frage09 => 'Bundeswettbewerb';

  @override
  String get jahresberichtSchritt4Frage10 => 'Leistungsspange';

  @override
  String get jahresberichtSchritt4Frage11 => 'CTIF';

  @override
  String get jahresberichtSchritt4Frage12 => 'Landesspezifischer Wettbewerb';

  @override
  String get jahresberichtSchritt4Frage13 =>
      'Die JF/KF hat mehr Interessierte, als sie aufnehmen kann';

  @override
  String get jahresberichtSchritt4Frage14 => 'Die JF/KF hat Nachwuchssorgen';

  @override
  String get jahresberichtSchritt4Frage15 => 'Die JF/KF hat zu wenig Betreuer';

  @override
  String get jahresberichtSchritt4Frage16 =>
      'Die JF/KF hat einen eigenen Sprecher';

  @override
  String get jahresberichtSchritt4Ja => 'Ja';

  @override
  String get jahresberichtSchritt4Nein => 'Nein';

  @override
  String get jahresberichtSchritt4Offen => 'Offen';

  @override
  String jahresberichtSchritt4OffenAnzahl(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Fragen noch offen',
      one: '1 Frage noch offen',
    );
    return '$_temp0';
  }

  @override
  String get jahresberichtSchritt4AlleBeantwortet => 'Alle Fragen beantwortet';

  @override
  String get jahresberichtSchritt5Titel => 'Einsatzabteilung';

  @override
  String get jahresberichtSchritt5Einleitung =>
      'Gib an, wie viele unter 27-Jährige zur Einsatzabteilung gehören, getrennt nach männlich, weiblich und divers. Der Wert des Vorjahres ist, wenn es ihn gibt, als Vorschlag eingetragen; prüfe ihn und passe ihn an. Die Eingabe bleibt im Entwurf.';

  @override
  String get jahresberichtSchritt5Maennlich => 'Männlich';

  @override
  String get jahresberichtSchritt5Weiblich => 'Weiblich';

  @override
  String get jahresberichtSchritt5Divers => 'Divers';

  @override
  String get jahresberichtSchritt5Offen => 'Noch nicht angegeben';

  @override
  String get jahresberichtSchritt5FehlerZahl =>
      'Bitte eine ganze Zahl ab 0 eingeben.';

  @override
  String get jahresberichtSchritt6Titel => 'Zusammenfassung und Export';

  @override
  String get jahresberichtSchritt6Einleitung =>
      'Prüfe hier alle Werte des Berichts. Werte, die du überschrieben hast, sind markiert. Sind alle Angaben vollständig, kannst du die XML-Datei exportieren und im Jahresberichtstool hochladen.';

  @override
  String get jahresberichtSchritt6Unvollstaendig =>
      'Der Bericht ist noch nicht vollständig, der Export ist gesperrt. Das fehlt:';

  @override
  String jahresberichtSchritt6Fehlt(int nummer, String titel, String was) {
    return 'Schritt $nummer ($titel): $was';
  }

  @override
  String jahresberichtSchritt6FehltKategorien(String kategorien) {
    return 'Kein Berichtsthema für: $kategorien';
  }

  @override
  String get jahresberichtSchritt6FehltVorbereitung =>
      'Durchschnittliche Vor- und Nachbereitungszeit fehlt';

  @override
  String get jahresberichtSchritt6FehltSonstigeArbeit =>
      'Stunden für sonstige Arbeit fehlen';

  @override
  String jahresberichtSchritt6FehltFragen(String nummern) {
    return 'Fragen ohne Antwort: $nummern';
  }

  @override
  String jahresberichtSchritt6FehltEinsatzabteilung(String geschlechter) {
    return 'Unter 27-Jährige in der Einsatzabteilung fehlen für: $geschlechter';
  }

  @override
  String get jahresberichtSchritt6Vollstaendig =>
      'Alle Angaben sind vollständig. Der Bericht kann exportiert werden.';

  @override
  String get jahresberichtSchritt6ZaehlwerteTitel => 'Zählwerte';

  @override
  String get jahresberichtSchritt6ArbeitswerteTitel => 'Arbeitswerte';

  @override
  String get jahresberichtSchritt6AngabenTitel => 'Eigene Angaben';

  @override
  String get jahresberichtSchritt6Einsatzabteilung =>
      'Unter 27-Jährige in der Einsatzabteilung';

  @override
  String jahresberichtSchritt6Frage(int nummer) {
    return 'Frage $nummer';
  }

  @override
  String get jahresberichtSchritt6Ja => 'Ja';

  @override
  String get jahresberichtSchritt6Nein => 'Nein';

  @override
  String get jahresberichtSchritt6Offen => 'Offen';

  @override
  String get jahresberichtSchritt6Exportieren => 'Als XML exportieren';

  @override
  String get jahresberichtSchritt6ErneutExportieren => 'Erneut exportieren';

  @override
  String jahresberichtSchritt6ZuletztExportiert(DateTime datum) {
    final intl.DateFormat datumDateFormat = intl.DateFormat.yMd(localeName);
    final String datumString = datumDateFormat.format(datum);

    return 'Zuletzt exportiert am $datumString';
  }

  @override
  String jahresberichtSchritt6ExportErfolg(String pfad) {
    return 'Exportiert nach $pfad';
  }

  @override
  String jahresberichtSchritt6ExportFehler(String fehler) {
    return 'Der Bericht konnte nicht exportiert werden: $fehler';
  }
}
