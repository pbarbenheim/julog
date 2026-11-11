import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/model.dart';
import '../repository_base.dart';

part 'repository.g.dart';

typedef KategorieCreate = ({String name, Berichtsthema? berichtsthema});

typedef KategorieEditData = ({
  String id,
  String name,
  Berichtsthema? berichtsthema,
});

class KategorieRepository
    extends JulogRepository<Kategorie, KategorieApiModel, KategorieCreate> {
  final Jldb _jldb;

  KategorieRepository({required Jldb jldb}) : _jldb = jldb;

  @override
  AsyncResult<Kategorie> createInJldb(KategorieCreate data) {
    return _jldb
        .createKategorie(
          KategorieApiModel(
            id: UUID.generate(),
            name: data.name,
            reportTopic: data.berichtsthema?.toReportTopic(),
          ),
        )
        .map((savedRecord) {
          return Kategorie.fromJldbRecord(savedRecord);
        });
  }

  /// Changes name and Berichtsthema of an existing Kategorie.
  ///
  /// Fails with a [KategorieNameGesperrtException] if the name changes while
  /// a signed Eintrag uses the Kategorie (ADR-0012); the Berichtsthema stays
  /// editable.
  AsyncVoidResult edit(KategorieEditData data) async {
    final result = await _jldb.updateKategorie(
      UUID.fromString(data.id),
      name: data.name,
      reportTopic: data.berichtsthema?.toReportTopic(),
    );
    if (result is Failure<Unit>) {
      return Failure(result.error);
    }
    invalidateCache();
    return Result.voidSuccess();
  }

  /// Whether the name of the Kategorie [id] cannot be changed because a signed
  /// Eintrag uses it (ADR-0012).
  AsyncResult<bool> isNameGesperrt(String id) =>
      _jldb.isKategorieNameGesperrt(UUID.fromString(id));

  @override
  Kategorie fromJldbRecord(KategorieApiModel record) =>
      Kategorie.fromJldbRecord(record);

  @override
  AsyncResult<List<KategorieApiModel>> fetchAllFromJldb() {
    return _jldb.getAllKategorien();
  }

  @override
  String getId(Kategorie item) => item.id;
}

@Riverpod(keepAlive: true)
KategorieRepository kategorieRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return KategorieRepository(jldb: jldb.jldb);
}
