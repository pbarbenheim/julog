import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:jldb/jldb.dart';

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/model.dart';
import '../repository_base.dart';

part 'eintrag_repo.g.dart';

typedef EintragCreateData = ({
  DateTime start,
  DateTime end,
  String kategorieId,
  String thema,
  String? ort,
  String? raum,
  String? dienstverlauf,
  String? besonderheiten,
  List<String> betreuerIds,
  List<String> anwesendeJugendlicherIds,
  List<String> entschuldigteJugendlicherIds,
});

class EintragRepository
    extends JulogRepository<Eintrag, EintragApiModel, EintragCreateData> {
  final Jldb _jldb;

  EintragRepository({required Jldb jldb}) : _jldb = jldb;

  AsyncResult<Optional<String>> getEintragSigningData(
    String eintragId,
    int version,
    DateTime timestamp,
  ) {
    return _jldb.getEintragForSigning(
      UUID.fromString(eintragId),
      version,
      timestamp,
    );
  }

  @protected
  @override
  AsyncResult<Eintrag> createInJldb(EintragCreateData data) {
    return _jldb
        .createEintrag(
          EintragApiModel(
            id: UUID.generate(),
            start: data.start,
            end: data.end,
            kategorieId: UUID.fromString(data.kategorieId),
            thema: data.thema,
            ort: data.ort,
            raum: data.raum,
            dienstverlauf: data.dienstverlauf,
            besonderheiten: data.besonderheiten,
            betreuerIds: data.betreuerIds.map(UUID.fromString).toSet(),
            anwesendeJugendlicherIds: data.anwesendeJugendlicherIds
                .map(UUID.fromString)
                .toSet(),
            entschuldigteJugendlicherIds: data.entschuldigteJugendlicherIds
                .map(UUID.fromString)
                .toSet(),
          ),
        )
        .map((savedRecord) {
          return Eintrag.fromApiModel(savedRecord);
        });
  }

  @protected
  @override
  AsyncResult<List<EintragApiModel>> fetchAllFromJldb() =>
      _jldb.getAllEintraege();

  @protected
  @override
  FutureOr<Eintrag> fromJldbRecord(EintragApiModel record) =>
      Eintrag.fromApiModel(record);

  @protected
  @override
  String getId(Eintrag item) => item.id;
}

@riverpod
EintragRepository eintragRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw Exception('Julog file is not loaded');
  }
  return EintragRepository(jldb: jldb.jldb);
}
