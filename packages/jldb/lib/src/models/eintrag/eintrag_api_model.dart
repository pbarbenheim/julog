import 'package:freezed_annotation/freezed_annotation.dart';

import '../uuid.dart';

part 'eintrag_api_model.freezed.dart';

const int eintragStatusAnwesend = 1;
const int eintragStatusEntschuldigt = 2;

@freezed
abstract class EintragApiModel with _$EintragApiModel {
  const factory EintragApiModel({
    required UUID id,
    required DateTime start,
    required DateTime end,
    required UUID kategorieId,
    required String thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    required Set<UUID> betreuerIds,
    required Set<UUID> anwesendeJugendlicherIds,
    required Set<UUID> entschuldigteJugendlicherIds,
  }) = _EintragApiModel;
}

EintragApiModel eintragApiModelFromDbArray(
  List<Object?> data,
  List<String> columns,
) {
  assert(columns.contains('id'), 'Column "id" is required');
  assert(columns.contains('start'), 'Column "start" is required');
  assert(columns.contains('end'), 'Column "end" is required');
  assert(columns.contains('kategorie_id'), 'Column "kategorie_id" is required');
  assert(columns.contains('betreuer_ids'), 'Column "betreuer_ids" is required');
  assert(
    columns.contains('status_jugendlicher_ids'),
    'Column "status_jugendlicher_ids" is required',
  );
  assert(columns.contains('thema'), 'Column "thema" is required');

  final idIndex = columns.indexOf('id');
  final startIndex = columns.indexOf('start');
  final endIndex = columns.indexOf('end');
  final kategorieIdIndex = columns.indexOf('kategorie_id');
  final themaIndex = columns.indexOf('thema');
  final ortIndex = columns.indexOf('ort');
  final raumIndex = columns.indexOf('raum');
  final dienstverlaufIndex = columns.indexOf('dienstverlauf');
  final besonderheitenIndex = columns.indexOf('besonderheiten');
  final betreuerIdsIndex = columns.indexOf('betreuer_ids');
  final statusJugendlicherIdsIndex = columns.indexOf('status_jugendlicher_ids');

  final anwesendeJugendlicherIds = <UUID>{};
  final entschuldigteJugendlicherIds = <UUID>{};

  final statusJugendlicherIds =
      (data[statusJugendlicherIdsIndex] as String?)
          ?.split(',')
          .where((e) => e.isNotEmpty) ??
      [];

  for (final sj in statusJugendlicherIds) {
    final parts = sj.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid status_jugendlicher_id format: $sj');
    }
    final jugendlicherId = parts[0].toString().toUUID();
    final status = int.tryParse(parts[1]);
    if (status == eintragStatusAnwesend) {
      anwesendeJugendlicherIds.add(jugendlicherId);
    } else if (status == eintragStatusEntschuldigt) {
      entschuldigteJugendlicherIds.add(jugendlicherId);
    }
  }

  return EintragApiModel(
    id: data[idIndex].toString().toUUID(),
    start: DateTime.fromMillisecondsSinceEpoch(data[startIndex] as int),
    end: DateTime.fromMillisecondsSinceEpoch(data[endIndex] as int),
    kategorieId: data[kategorieIdIndex].toString().toUUID(),
    thema: data[themaIndex] as String,
    ort: ortIndex != -1 ? data[ortIndex] as String? : null,
    raum: raumIndex != -1 ? data[raumIndex] as String? : null,
    dienstverlauf: dienstverlaufIndex != -1
        ? data[dienstverlaufIndex] as String?
        : null,
    besonderheiten: besonderheitenIndex != -1
        ? data[besonderheitenIndex] as String?
        : null,
    betreuerIds:
        (data[betreuerIdsIndex] as String?)
            ?.split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => e.toUUID())
            .toSet() ??
        {},
    anwesendeJugendlicherIds: anwesendeJugendlicherIds,
    entschuldigteJugendlicherIds: entschuldigteJugendlicherIds,
  );
}
