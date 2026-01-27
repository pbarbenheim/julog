import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/model.dart';
import '../repository_base.dart';

part 'repository.g.dart';

typedef KategorieCreate = ({String name});

class _KategorieRepository
    extends JulogRepository<Kategorie, KategorieApiModel, KategorieCreate> {
  final Jldb _jldb;

  _KategorieRepository({required Jldb jldb}) : _jldb = jldb;

  @override
  AsyncResult<Kategorie> createInJldb(KategorieCreate data) {
    return _jldb
        .createKategorie(
          KategorieApiModel(id: UUID.generate(), name: data.name),
        )
        .map((savedRecord) {
          return Kategorie.fromJldbRecord(savedRecord);
        });
  }

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
JulogRepository<Kategorie, KategorieApiModel, KategorieCreate>
kategorieRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return _KategorieRepository(jldb: jldb.jldb);
}
