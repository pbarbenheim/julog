import 'dart:async';

import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../jahresbericht/jahresbericht.dart';
import '../../jahresbericht/manuelle_angaben.dart';
import '../../repository/berichtsentwurf/repository.dart';
import '../../repository/betreuer/repository.dart';
import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/jugendliche/repository.dart';
import '../../repository/kategorie/repository.dart';
import '../../repository/model/berichtsentwurf/berichtsentwurf.dart';
import '../../repository/model/model.dart';

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

  AssistentDaten._({
    required this.berichtsjahr,
    required this.entwurf,
    required this.jugendliche,
    required this.betreuer,
    required this.eintraege,
    required this.kategorien,
    required this.berechnet,
    required this.berichtswert,
    required this.hatUngespeicherteAenderungen,
  });

  /// Berechnet die Werte neu für [entwurf] und die übergebenen Stammdaten.
  factory AssistentDaten.berechne({
    required Berichtsentwurf entwurf,
    required List<Jugendlicher> jugendliche,
    required List<Betreuer> betreuer,
    required List<Eintrag> eintraege,
    required List<Kategorie> kategorien,
    bool hatUngespeicherteAenderungen = false,
  }) {
    Berichtswert rechne(Ueberschreibungen ueberschreibungen) =>
        berechneBerichtswert(
          berichtsjahr: entwurf.year,
          jugendliche: jugendliche,
          betreuer: betreuer,
          eintraege: eintraege,
          kategorien: kategorien,
          ueberschreibungen: ueberschreibungen,
        );
    return AssistentDaten._(
      berichtsjahr: entwurf.year,
      entwurf: entwurf,
      jugendliche: jugendliche,
      betreuer: betreuer,
      eintraege: eintraege,
      kategorien: kategorien,
      berechnet: rechne(const Ueberschreibungen.keine()),
      berichtswert: rechne(entwurf.ueberschreibungen),
      hatUngespeicherteAenderungen: hatUngespeicherteAenderungen,
    );
  }

  /// Neuer Arbeitsstand mit geändertem Entwurf; die Stammdaten bleiben.
  AssistentDaten mitEntwurf(
    Berichtsentwurf neu, {
    required bool hatUngespeicherteAenderungen,
  }) {
    final ueberschreibungenGleich =
        neu.ueberschreibungen == entwurf.ueberschreibungen;
    return AssistentDaten._(
      berichtsjahr: berichtsjahr,
      entwurf: neu,
      jugendliche: jugendliche,
      betreuer: betreuer,
      eintraege: eintraege,
      kategorien: kategorien,
      berechnet: berechnet,
      berichtswert: ueberschreibungenGleich
          ? berichtswert
          : berechneBerichtswert(
              berichtsjahr: berichtsjahr,
              jugendliche: jugendliche,
              betreuer: betreuer,
              eintraege: eintraege,
              kategorien: kategorien,
              ueberschreibungen: neu.ueberschreibungen,
            ),
      hatUngespeicherteAenderungen: hatUngespeicherteAenderungen,
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
/// - Haben sich Stammdaten geändert (z. B. Berichtsthemen der Kategorien in
///   Schritt 2), liest [neuLaden] sie neu ein und behält den Arbeitsstand.
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
}
