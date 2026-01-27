import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/model.dart';
import '../repository_base.dart';

part 'repository.g.dart';

typedef JugendlicheCreateData = ({
  String name,
  Gender gender,
  DateTime birthDate,
  DateTime memberSince,
  String? pass,
});

class _JugendlicheRepository
    extends
        JulogRepository<
          Jugendlicher,
          JugendlicherApiModel,
          JugendlicheCreateData
        > {
  final Jldb _jldb;
  _JugendlicheRepository({required Jldb jldb}) : _jldb = jldb;

  @override
  AsyncResult<Jugendlicher> createInJldb(JugendlicheCreateData data) {
    return _jldb
        .upsertJugendlicher(
          JugendlicherApiModel(
            id: UUID.generate(),
            name: data.name,
            sex: switch (data.gender) {
              Gender.diverse => Sex.diverse,
              Gender.female => Sex.female,
              Gender.male => Sex.male,
            },
            birthDate: data.birthDate,
            memberSince: data.memberSince,
            pass: data.pass,
          ),
        )
        .map((savedRecord) {
          return Jugendlicher.fromJldbRecord(savedRecord);
        });
  }

  @override
  AsyncResult<List<JugendlicherApiModel>> fetchAllFromJldb() async {
    final result = await _jldb.getAllJugendliche();
    if (result.isFailure()) {
      return result;
    }
    final records = result.getOrThrow();
    records.sort((a, b) {
      final aReplacedBy = a.replacedById != null ? 1 : 0;
      final bReplacedBy = b.replacedById != null ? 1 : 0;
      if (aReplacedBy + bReplacedBy != 2) {
        return aReplacedBy.compareTo(bReplacedBy);
      }
      if (a.replacedById == b.id) {
        return 1;
      } else if (b.replacedById == a.id) {
        return -1;
      } else {
        return 0;
      }
    });
    return records.toSuccess();
  }

  @override
  Jugendlicher fromJldbRecord(JugendlicherApiModel record) {
    Jugendlicher? replacedBy;
    if (record.replacedById != null) {
      final replacedByOptional = cache[record.replacedById!.toString()];
      if (replacedByOptional is Some<Jugendlicher>) {
        replacedBy = replacedByOptional.unwrap();
      } else {
        throw StateError(
          'ReplacedBy Jugendlicher with id ${record.replacedById} not found in cache',
        );
      }
    }

    return Jugendlicher.fromJldbRecord(record, replacedBy: replacedBy);
  }

  @override
  String getId(Jugendlicher item) => item.id;
}

@Riverpod(keepAlive: true)
JulogRepository<Jugendlicher, JugendlicherApiModel, JugendlicheCreateData>
jugendlicheRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return _JugendlicheRepository(jldb: jldb.jldb);
}
