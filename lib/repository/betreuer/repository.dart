import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/model.dart';
import '../repository_base.dart';

part 'repository.g.dart';

class _BetreuerRepository
    extends
        JulogRepository<
          Betreuer,
          BetreuerApiModel,
          ({String name, Gender gender})
        > {
  final Jldb _jldb;

  _BetreuerRepository({required Jldb jldb}) : _jldb = jldb;

  @override
  AsyncResult<Betreuer> createInJldb(({Gender gender, String name}) data) {
    return _jldb
        .createBetreuer(
          BetreuerApiModel(
            id: UUID.generate(),
            name: data.name,
            sex: switch (data.gender) {
              Gender.male => Sex.male,
              Gender.female => Sex.female,
              Gender.diverse => Sex.diverse,
            },
          ),
        )
        .map((savedRecord) {
          return Betreuer.fromJldbRecord(savedRecord);
        });
  }

  @override
  AsyncResult<List<BetreuerApiModel>> fetchAllFromJldb() {
    return _jldb.getAllBetreuer();
  }

  @override
  Betreuer fromJldbRecord(BetreuerApiModel record) =>
      Betreuer.fromJldbRecord(record);

  @override
  String getId(Betreuer item) => item.id;
}

@Riverpod(keepAlive: true)
JulogRepository<Betreuer, BetreuerApiModel, ({String name, Gender gender})>
betreuerRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return _BetreuerRepository(jldb: jldb.jldb);
}
