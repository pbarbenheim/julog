import 'dart:async';
import 'dart:io';

import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../jahresbericht/jahresbericht.dart';
import '../../jahresbericht/jahresbericht_xml.dart';
import '../../jahresbericht/manuelle_angaben.dart';
import '../../repository/berichtsentwurf/repository.dart';
import '../../repository/betreuer/repository.dart';
import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/jugendliche/repository.dart';
import '../../repository/kategorie/repository.dart';
import '../../repository/model/berichtsentwurf/berichtsentwurf.dart';
import '../../repository/model/model.dart';
import '../kategorie/kategorie.dart';
import 'export_ziel.dart';

part 'assistent_viewmodel.g.dart';

/// Alles, was die Schritte des Jahresbericht-Assistenten brauchen: der
/// Arbeitsstand des Entwurfs, die Stammdaten, aus denen gerechnet wird, und
/// das Rechenergebnis.
///
/// Unveränderlich. [entwurf] ist der Arbeitsstand, auch wenn er noch nicht
/// gespeichert ist ([hatUngespeicherteAenderungen]).
class AssistentDaten {
  final int berichtsjahr;

  /// Arbeitsstand des Entwurfs (manuelle Angaben, Überschreibungen, Status).
  final Berichtsentwurf entwurf;

  /// Die Stammdaten, aus denen berechnet wird (zum Zeitpunkt des Ladens).
  final List<Jugendlicher> jugendliche;
  final List<Betreuer> betreuer;
  final List<Eintrag> eintraege;
  final List<Kategorie> kategorien;

  /// Berechnete Werte ohne die Überschreibungen des Entwurfs. Schritt 3 zeigt
  /// sie als Vorschlag neben dem überschriebenen Wert.
  final Berichtswert berechnet;

  /// Berechnete Werte mit den Überschreibungen des Entwurfs: das, was in die
  /// XML geschrieben wird.
  final Berichtswert berichtswert;

  final bool hatUngespeicherteAenderungen;

  /// Rechnet [berechnet] und [berichtswert] aus, außer ein schon bekanntes
  /// Ergebnis wird übergeben (nur gültig, wenn sich die zugehörigen Eingaben
  /// nicht geändert haben).
  AssistentDaten._({
    required this.entwurf,
    required this.jugendliche,
    required this.betreuer,
    required this.eintraege,
    required this.kategorien,
    required this.hatUngespeicherteAenderungen,
    Berichtswert? berechnet,
    Berichtswert? berichtswert,
  }) : berichtsjahr = entwurf.year,
       berechnet =
           berechnet ??
           berechneBerichtswert(
             berichtsjahr: entwurf.year,
             jugendliche: jugendliche,
             betreuer: betreuer,
             eintraege: eintraege,
             kategorien: kategorien,
           ),
       berichtswert =
           berichtswert ??
           berechneBerichtswert(
             berichtsjahr: entwurf.year,
             jugendliche: jugendliche,
             betreuer: betreuer,
             eintraege: eintraege,
             kategorien: kategorien,
             ueberschreibungen: entwurf.ueberschreibungen,
           );

  /// Berechnet die Werte neu für [entwurf] und die übergebenen Stammdaten.
  factory AssistentDaten.berechne({
    required Berichtsentwurf entwurf,
    required List<Jugendlicher> jugendliche,
    required List<Betreuer> betreuer,
    required List<Eintrag> eintraege,
    required List<Kategorie> kategorien,
    bool hatUngespeicherteAenderungen = false,
  }) => AssistentDaten._(
    entwurf: entwurf,
    jugendliche: jugendliche,
    betreuer: betreuer,
    eintraege: eintraege,
    kategorien: kategorien,
    hatUngespeicherteAenderungen: hatUngespeicherteAenderungen,
  );

  /// Neuer Arbeitsstand mit geändertem Entwurf; die Stammdaten bleiben.
  AssistentDaten mitEntwurf(
    Berichtsentwurf neu, {
    required bool hatUngespeicherteAenderungen,
  }) {
    final ueberschreibungenGleich =
        neu.ueberschreibungen == entwurf.ueberschreibungen;
    return AssistentDaten._(
      entwurf: neu,
      jugendliche: jugendliche,
      betreuer: betreuer,
      eintraege: eintraege,
      kategorien: kategorien,
      hatUngespeicherteAenderungen: hatUngespeicherteAenderungen,
      berechnet: berechnet,
      berichtswert: ueberschreibungenGleich ? berichtswert : null,
    );
  }
}

/// Lädt den Entwurf für [year] oder legt ihn an, wenn es noch keinen gibt.
Future<Berichtsentwurf> ladeOderErzeugeEntwurf(
  BerichtsentwurfRepository repo,
  int year,
) async {
  final vorhanden = await repo.getByYear(year).unwrap();
  if (vorhanden is Some<Berichtsentwurf>) return vorhanden.unwrap();
  return repo.save(year).unwrap();
}

/// Die Liste der Berichtsjahre mit Entwurf (jüngstes zuerst).
@riverpod
class BerichtsentwuerfeViewModel extends _$BerichtsentwuerfeViewModel {
  @override
  Future<List<Berichtsentwurf>> build() {
    return ref.watch(berichtsentwurfRepositoryProvider).getAll().unwrap();
  }

  /// Legt für [year] einen Entwurf an, falls es noch keinen gibt (mit den
  /// Antworten des Vorjahres als Vorschlag), und aktualisiert die Liste.
  Future<void> starten(int year) async {
    await ladeOderErzeugeEntwurf(
      ref.read(berichtsentwurfRepositoryProvider),
      year,
    );
    ref.invalidateSelf();
    await future;
  }
}

/// Ausgang von [JahresberichtAssistentViewModel.exportiere]. Fehler beim
/// Vorbereiten oder Schreiben der Datei werden als Exception geworfen.
sealed class ExportErgebnis {
  const ExportErgebnis();
}

/// Der Anwender hat den Speichern-Dialog abgebrochen; nichts wurde
/// geschrieben.
final class ExportAbgebrochen extends ExportErgebnis {
  const ExportAbgebrochen();
}

/// Die Datei wurde nach [pfad] geschrieben und der Bericht als exportiert
/// gespeichert.
final class ExportErfolgreich extends ExportErgebnis {
  final String pfad;
  final DateTime zeitpunkt;

  const ExportErfolgreich(this.pfad, this.zeitpunkt);
}

/// Die Datei wurde nach [pfad] geschrieben, aber der Status "exportiert"
/// konnte nicht gespeichert werden ([fehler]).
final class ExportStatusNichtGespeichert extends ExportErgebnis {
  final String pfad;
  final Object fehler;

  const ExportStatusNichtGespeichert(this.pfad, this.fehler);
}

/// Gemeinsamer Zustand aller Schritte des Assistenten für ein Berichtsjahr.
///
/// ## So füllt ein Schritt seinen Teil
///
/// - Lesen: `ref.watch(jahresberichtAssistentViewModelProvider(jahr))`
///   liefert die [AssistentDaten] (Entwurf, Stammdaten, berechnete Werte).
/// - Ändern: [aendereAngaben] und [aendereUeberschreibungen]. Die Änderung
///   gilt sofort für alle Schritte, ist aber erst nach [speichern]
///   persistiert. Der Assistent ruft [vorVerlassen] beim Wechsel eines
///   Schritts und beim Schließen auf; der Schritt muss nicht selbst
///   speichern.
/// - Noch nicht übernommene Eingaben (z. B. ein Formular mit Validierung):
///   per [registriereVorVerlassen] einen Hook anmelden, der sie in den
///   Entwurf überträgt; [vorVerlassen] ruft ihn vor dem Speichern auf.
/// - Haben sich Stammdaten geändert, liest [neuLaden] sie neu ein und behält
///   den Arbeitsstand. Berichtsthemen ordnet [ordneBerichtsthemaZu] zu.
/// - Export: [exportiere] (Schritt 6).
@riverpod
class JahresberichtAssistentViewModel
    extends _$JahresberichtAssistentViewModel {
  final Map<Object, Future<void> Function()> _hooks = {};

  @override
  Future<AssistentDaten> build(int berichtsjahr) async {
    final entwurf = await ladeOderErzeugeEntwurf(
      ref.watch(berichtsentwurfRepositoryProvider),
      berichtsjahr,
    );
    return _lade(entwurf, hatUngespeicherteAenderungen: false);
  }

  Future<AssistentDaten> _lade(
    Berichtsentwurf entwurf, {
    required bool hatUngespeicherteAenderungen,
  }) async {
    final jugendliche = await ref
        .read(jugendlicheRepositoryProvider)
        .getAll()
        .unwrap();
    final betreuer = await ref
        .read(betreuerRepositoryProvider)
        .getAll()
        .unwrap();
    final eintraege = await ref
        .read(eintragRepositoryProvider)
        .getAll()
        .unwrap();
    final kategorien = await ref
        .read(kategorieRepositoryProvider)
        .getAll()
        .unwrap();
    return AssistentDaten.berechne(
      entwurf: entwurf,
      jugendliche: jugendliche,
      betreuer: betreuer,
      eintraege: eintraege,
      kategorien: kategorien,
      hatUngespeicherteAenderungen: hatUngespeicherteAenderungen,
    );
  }

  /// Ändert die manuellen Angaben im Arbeitsstand (noch nicht gespeichert).
  void aendereAngaben(ManuelleAngaben Function(ManuelleAngaben alt) aenderung) {
    _aendere((e) => e.copyWith(angaben: aenderung(e.angaben)));
  }

  /// Ändert die Überschreibungen der Arbeitswerte im Arbeitsstand (noch
  /// nicht gespeichert).
  void aendereUeberschreibungen(
    Ueberschreibungen Function(Ueberschreibungen alt) aenderung,
  ) {
    _aendere(
      (e) => e.copyWith(ueberschreibungen: aenderung(e.ueberschreibungen)),
    );
  }

  void _aendere(Berichtsentwurf Function(Berichtsentwurf) aenderung) {
    final aktuell = state.value;
    if (aktuell == null) return;
    state = AsyncData(
      aktuell.mitEntwurf(
        aenderung(aktuell.entwurf),
        hatUngespeicherteAenderungen: true,
      ),
    );
  }

  /// Speichert den Arbeitsstand, falls er sich geändert hat. Wirft bei einem
  /// Fehler eine [Exception]; der Arbeitsstand bleibt dann erhalten.
  ///
  /// Darf auch aufgerufen werden, wenn der Assistent schon geschlossen wird
  /// (der Provider also gerade entsorgt wird).
  Future<void> speichern() async {
    if (!ref.mounted) return;
    final aktuell = state.value;
    if (aktuell == null || !aktuell.hatUngespeicherteAenderungen) return;
    final entwurf = aktuell.entwurf;
    final result = await ref.read(berichtsentwurfRepositoryProvider).update((
      year: entwurf.year,
      angaben: entwurf.angaben,
      ueberschreibungen: entwurf.ueberschreibungen,
    ));
    if (result is Failure<Unit>) {
      throw Exception(
        'Berichtsentwurf konnte nicht gespeichert werden: '
        '${result.error}',
      );
    }
    if (!ref.mounted) return;
    // Zwischenzeitlich geänderte Angaben bleiben ungespeichert.
    final jetzt = state.value;
    if (jetzt == null) return;
    final unveraendert =
        identical(jetzt.entwurf, entwurf) ||
        (jetzt.entwurf.angaben == entwurf.angaben &&
            jetzt.entwurf.ueberschreibungen == entwurf.ueberschreibungen);
    if (unveraendert) {
      state = AsyncData(
        jetzt.mitEntwurf(jetzt.entwurf, hatUngespeicherteAenderungen: false),
      );
    }
  }

  /// Meldet einen Hook an, den [vorVerlassen] vor dem Speichern aufruft.
  /// [eigner] identifiziert den Hook (ein neuer Aufruf mit demselben Eigner
  /// ersetzt ihn).
  void registriereVorVerlassen(Object eigner, Future<void> Function() hook) {
    _hooks[eigner] = hook;
  }

  void entferneVorVerlassen(Object eigner) {
    _hooks.remove(eigner);
  }

  /// Wird beim Verlassen eines Schritts und beim Schließen des Assistenten
  /// aufgerufen: ruft die angemeldeten Hooks auf und speichert dann den
  /// Entwurf.
  Future<void> vorVerlassen() async {
    final hooks = _hooks.values.toList();
    await Future.wait(hooks.map((h) => h()));
    await speichern();
  }

  /// Liest die Stammdaten neu ein und rechnet neu. Der Arbeitsstand des
  /// Entwurfs (auch ungespeicherte Änderungen) bleibt erhalten.
  Future<void> neuLaden() async {
    final aktuell = state.value;
    if (aktuell == null) return;
    final neu = await _lade(
      aktuell.entwurf,
      hatUngespeicherteAenderungen: aktuell.hatUngespeicherteAenderungen,
    );
    if (!ref.mounted) return;
    state = AsyncData(neu);
  }

  /// Ordnet [kategorie] das [thema] zu und speichert es sofort an der
  /// Kategorie (es gilt dauerhaft, nicht nur für diesen Entwurf). Liest dann
  /// die Stammdaten neu ein, damit alle Schritte die geänderten Arbeitswerte
  /// sehen. Wirft bei einem Fehler eine [Exception].
  Future<void> ordneBerichtsthemaZu(
    Kategorie kategorie,
    Berichtsthema thema,
  ) async {
    final result = await ref.read(kategorieRepositoryProvider).edit((
      id: kategorie.id,
      name: kategorie.name,
      berichtsthema: thema,
    ));
    if (result is Failure<Unit>) throw Exception('${result.error}');
    // Die Kategorie-Liste (Kategorie-Seite) kennt die Änderung noch nicht.
    ref.invalidate(kategorieViewModelProvider);
    await neuLaden();
  }

  /// Exportiert den Jahresbericht als XML-Datei.
  ///
  /// Sichert zuerst ausstehende Änderungen, damit Datei und Entwurf
  /// übereinstimmen, fragt über [jahresberichtExportZielProvider] nach dem
  /// Ziel ([bestaetigenText] beschriftet den Bestätigen-Knopf des Dialogs),
  /// schreibt die Datei und markiert den Entwurf als exportiert. Das lässt
  /// sich beliebig oft wiederholen.
  ///
  /// Schlägt nur das Speichern des Status fehl, steht die Datei schon: das
  /// Ergebnis ist dann [ExportStatusNichtGespeichert]. Alle anderen Fehler
  /// (Sichern, Erzeugen, Schreiben) werden geworfen.
  Future<ExportErgebnis> exportiere({required String bestaetigenText}) async {
    // Der Anwender kann den Assistenten schließen, während der Dialog offen
    // ist; die Liste der Berichtsjahre soll trotzdem aktualisiert werden.
    final link = ref.keepAlive();
    try {
      await vorVerlassen();
      final daten = state.requireValue;
      final bytes = erzeugeJahresberichtXmlBytes(
        berichtsjahr: berichtsjahr,
        jugendliche: daten.jugendliche,
        betreuer: daten.betreuer,
        eintraege: daten.eintraege,
        kategorien: daten.kategorien,
        angaben: daten.entwurf.angaben,
        ueberschreibungen: daten.entwurf.ueberschreibungen,
      );
      final waehleZiel = ref.read(jahresberichtExportZielProvider);
      final pfad = await waehleZiel(
        'jahresbericht_$berichtsjahr.xml',
        bestaetigenText,
      );
      if (pfad == null) return const ExportAbgebrochen();
      await File(pfad).writeAsBytes(bytes, flush: true);

      final zeitpunkt = DateTime.now();
      final markiert = await ref
          .read(berichtsentwurfRepositoryProvider)
          .markExported(berichtsjahr, zeitpunkt);
      if (markiert is Failure<Unit>) {
        return ExportStatusNichtGespeichert(pfad, markiert.error);
      }
      ref.invalidate(berichtsentwuerfeViewModelProvider);
      _setzeExportiert(zeitpunkt);
      return ExportErfolgreich(pfad, zeitpunkt);
    } finally {
      link.close();
    }
  }

  void _setzeExportiert(DateTime zeitpunkt) {
    final aktuell = state.value;
    if (aktuell == null) return;
    state = AsyncData(
      aktuell.mitEntwurf(
        aktuell.entwurf.copyWith(
          status: EntwurfStatus.exportiert,
          exportedAt: zeitpunkt,
        ),
        hatUngespeicherteAenderungen: aktuell.hatUngespeicherteAenderungen,
      ),
    );
  }
}
