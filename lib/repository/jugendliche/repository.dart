import 'package:freezed_annotation/freezed_annotation.dart';
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

typedef JugendlicheEditData = ({
  String id,
  String name,
  Gender gender,
  DateTime birthDate,
  DateTime memberSince,
  String? pass,
});

class JugendlicheRepository
    extends
        JulogRepository<
          Jugendlicher,
          JugendlicherApiModel,
          JugendlicheCreateData
        > {
  final Jldb _jldb;
  JugendlicheRepository({required Jldb jldb}) : _jldb = jldb;

  AsyncVoidResult exitJugendlicher(
    String id,
    DateTime exitDate,
    AustrittsGrund grund,
  ) async {
    final result = await _jldb.setAustrittJugendlicher(
      UUID.fromString(id),
      exitDate,
      switch (grund) {
        AustrittsGrund.uebernahme => ExitReason.uebernahme,
        AustrittsGrund.wohnortwechsel => ExitReason.wohnortwechsel,
        AustrittsGrund.noInterest => ExitReason.noInterest,
        AustrittsGrund.schule => ExitReason.schule,
        AustrittsGrund.ausbildung => ExitReason.ausbildung,
        AustrittsGrund.ausschluss => ExitReason.ausschluss,
        AustrittsGrund.noUebernahme => ExitReason.noUebernahme,
      },
    );
    if (result is Failure<Unit>) {
      return Failure(result.error);
    }
    invalidateCache();
    return Result.voidSuccess();
  }

  AsyncResult<String> editJugendlicher(JugendlicheEditData data) async {
    final currentResult = await getById(data.id);
    if (currentResult is Failure<Optional<Jugendlicher>>) {
      return Failure(currentResult.error);
    }
    final currentOpt = currentResult.unwrap();
    if (currentOpt is None<Jugendlicher>) {
      return Failure(
        Exception('Jugendlicher mit ID ${data.id} nicht gefunden.'),
      );
    }
    final current = currentOpt.unwrap();

    final sex = switch (data.gender) {
      Gender.diverse => Sex.diverse,
      Gender.female => Sex.female,
      Gender.male => Sex.male,
    };

    if (data.name == current.name) {
      final result = await _jldb.updateJugendlicher(
        UUID.fromString(data.id),
        sex: sex,
        pass: data.pass,
        birthDate: data.birthDate,
        memberSince: data.memberSince,
      );
      if (result is Failure<Unit>) return Failure(result.error);
      invalidateCache();
      return Success(data.id);
    } else {
      final result = await _jldb.createJugendlicher(
        JugendlicherCreateDTO(
          name: data.name,
          sex: sex,
          pass: data.pass,
          birthDate: data.birthDate,
          memberSince: data.memberSince,
          replacesId: UUID.fromString(data.id),
        ),
      );
      if (result is Failure<UUID>) return Failure(result.error);
      invalidateCache();
      return Success(result.unwrap().toString());
    }
  }

  AsyncVoidResult delete(String id) async {
    final result = await _jldb.deleteJugendlicher(UUID.fromString(id));
    if (result is Failure<Unit>) {
      return Failure(result.error);
    }
    invalidateCache();
    return Result.voidSuccess();
  }

  @protected
  @override
  AsyncResult<Jugendlicher> createInJldb(JugendlicheCreateData data) {
    return _jldb
        .createJugendlicher(
          JugendlicherCreateDTO(
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
        .then((result) async {
          if (result is Failure<UUID>) {
            return Failure(result.error);
          }
          final record = result.unwrap();

          final saved = await _jldb.getJugendlicher(record);
          if (saved is Failure<Optional<JugendlicherApiModel>>) {
            return Failure(saved.error);
          }
          final savedOptional = saved.unwrap();
          if (savedOptional is None<JugendlicherApiModel>) {
            return Failure(Exception('Created Jugendlicher not found'));
          }

          final jugendlicher = fromJldbRecord(savedOptional.unwrap());
          return Success(jugendlicher);
        });
  }

  @protected
  @override
  AsyncResult<List<JugendlicherApiModel>> fetchAllFromJldb() async {
    final result = await _jldb.getAllJugendliche();
    if (result is Failure<List<JugendlicherApiModel>>) {
      return result;
    }
    final records = result.unwrap();
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
    return Success(records);
  }

  @protected
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

  @protected
  @override
  String getId(Jugendlicher item) => item.id;
}

@Riverpod(keepAlive: true)
JugendlicheRepository jugendlicheRepository(Ref ref) {
  final jldb = ref.watch(julogServiceProvider);
  if (jldb is! JulogFileLoaded) {
    throw StateError('Julog file is not loaded');
  }
  return JugendlicheRepository(jldb: jldb.jldb);
}
