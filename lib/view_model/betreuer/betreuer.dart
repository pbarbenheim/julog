import 'package:jldb/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/betreuer/repository.dart';
import '../../repository/model/model.dart';

part 'betreuer.g.dart';

@riverpod
class BetreuerViewModel extends _$BetreuerViewModel {
  @override
  Future<List<Betreuer>> build() async {
    final repo = ref.watch(betreuerRepositoryProvider);
    final result = await repo.getAll();
    if (result is Failure<List<Betreuer>>) {
      throw Exception('Failed to load Betreuer: ${result.error}');
    } else {
      final list = result.unwrap();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
  }

  Future<String> addBetreuer(String name, Gender gender) async {
    final repo = ref.read(betreuerRepositoryProvider);
    final result = await repo.save((name: name, gender: gender));
    if (result is Failure<Betreuer>) {
      throw Exception('Failed to save Betreuer: ${result.error}');
    } else {
      // Refresh the list after adding a new Betreuer
      ref.invalidateSelf();

      final betreuer = result.unwrap();
      return betreuer.id;
    }
  }
}
