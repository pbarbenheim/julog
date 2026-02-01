import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/model/model.dart';

part 'eintrag_viewmodel.g.dart';
part 'eintrag_viewmodel.freezed.dart';

@riverpod
class EintragViewModel extends _$EintragViewModel {
  @override
  Future<List<SmallEintrag>> build() async {
    final repo = ref.watch(eintragRepositoryProvider);
    final result = await repo.getAll().unwrap();
    return result
        .map(
          (e) => SmallEintrag(
            id: e.id,
            start: e.start,
            end: e.end,
            thema: e.thema,
          ),
        )
        .toList();
  }

  Future<String> addEintrag({
    required DateTime start,
    required DateTime end,
    required String kategorieId,
    required String thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    required List<String> betreuerIds,
    required List<String> anwesendeJugendlicherIds,
    required List<String> entschuldigteJugendlicherIds,
  }) async {
    final repo = ref.read(eintragRepositoryProvider);
    final result = await repo.save((
      start: start,
      end: end,
      kategorieId: kategorieId,
      thema: thema,
      ort: ort,
      raum: raum,
      dienstverlauf: dienstverlauf,
      besonderheiten: besonderheiten,
      betreuerIds: betreuerIds,
      anwesendeJugendlicherIds: anwesendeJugendlicherIds,
      entschuldigteJugendlicherIds: entschuldigteJugendlicherIds,
    ));
    if (result is Failure<Eintrag>) {
      throw Exception('Failed to save Eintrag: ${result.error}');
    } else {
      // Refresh the list after adding a new Eintrag
      ref.invalidateSelf();

      final eintrag = result.unwrap();
      return eintrag.id;
    }
  }
}

@freezed
abstract class SmallEintrag with _$SmallEintrag {
  const factory SmallEintrag({
    required String id,
    required DateTime start,
    required DateTime end,
    required String thema,
  }) = _SmallEintrag;
}
