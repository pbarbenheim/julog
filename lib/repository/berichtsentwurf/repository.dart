import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../jahresbericht/jahresbericht.dart';
import '../../jahresbericht/manuelle_angaben.dart';
import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/berichtsentwurf/berichtsentwurf.dart';
import '../repository_base.dart';

part 'repository.g.dart';

typedef BerichtsentwurfEditData = ({
  int year,
  ManuelleAngaben angaben,
  Ueberschreibungen ueberschreibungen,
});

/// Speichert den Berichtsentwurf je Berichtsjahr (höchstens einen).
///
/// - Anlegen: [save] mit dem Berichtsjahr. Die manuellen Angaben des Vorjahres
///   werden als Vorschlag übernommen (Fragen, Wert 11, Wert 20,
///   Einsatzabteilung), Überschreibungen und Status nicht. "Vorjahr" ist der
///   Entwurf von `year - 1`, fehlt er, der jüngste frühere Entwurf; gibt es
///   keinen, startet der Entwurf leer. Schlägt fehl, wenn es für das Jahr
///   schon einen Entwurf gibt.
/// - Laden: [getByYear]; Liste aller Jahre (jüngstes zuerst) mit Status und
///   Exportdatum: [getAll].
/// - Ändern: [update] ersetzt Angaben und Überschreibungen, Status und
///   Exportdatum bleiben.
/// - Exportiert markieren: [markExported], beliebig oft wiederholbar.
class BerichtsentwurfRepository
    extends JulogRepository<Berichtsentwurf, BerichtsentwurfApiModel, int> {
  final Jldb _jldb;

  BerichtsentwurfRepository({required Jldb jldb}) : _jldb = jldb;

  @override
  AsyncResult<Berichtsentwurf> createInJldb(int year) {
    return _jldb
        .createBerichtsentwurf(year)
        .map(Berichtsentwurf.fromJldbRecord);
  }

  /// Alle Entwürfe, das jüngste Berichtsjahr zuerst.
  @override
  AsyncResult<List<Berichtsentwurf>> getAll() {
    return super.getAll().map(
      (all) => [...all]..sort((a, b) => b.year.compareTo(a.year)),
    );
  }

  /// Der Entwurf für [year], `None` wenn es keinen gibt.
  AsyncResult<Optional<Berichtsentwurf>> getByYear(int year) =>
      getById(year.toString());

  /// Ersetzt Angaben und Überschreibungen des Entwurfs. Status und
  /// Exportdatum bleiben erhalten.
  AsyncVoidResult update(BerichtsentwurfEditData data) async {
    final result = await _jldb.updateBerichtsentwurf(
      data.year,
      angaben: data.angaben.toMap(),
      ueberschreibungen: data.ueberschreibungen.toMap(),
    );
    if (result is Failure<Unit>) {
      return Failure(result.error);
    }
    invalidateCache();
    return Result.voidSuccess();
  }

  /// Setzt den Status auf exportiert und speichert [exportedAt] (Standard:
  /// jetzt). Ein erneuter Aufruf aktualisiert nur das Datum.
  AsyncVoidResult markExported(int year, [DateTime? exportedAt]) async {
    final result = await _jldb.markBerichtsentwurfExported(
      year,
      exportedAt ?? DateTime.now(),
    );
    if (result is Failure<Unit>) {
      return Failure(result.error);
    }
    invalidateCache();
    return Result.voidSuccess();
  }

  @override
  Berichtsentwurf fromJldbRecord(BerichtsentwurfApiModel record) =>
      Berichtsentwurf.fromJldbRecord(record);

  @override
  AsyncResult<List<BerichtsentwurfApiModel>> fetchAllFromJldb() {
    return _jldb.getAllBerichtsentwuerfe();
  }

  @override
  String getId(Berichtsentwurf item) => item.year.toString();
}

@Riverpod(keepAlive: true)
BerichtsentwurfRepository berichtsentwurfRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return BerichtsentwurfRepository(jldb: jldb.jldb);
}
