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
    if (result.isFailure()) {
      throw Exception(
        'Failed to load Betreuer: ${result.getFailureOptional().unsafe()}',
      );
    } else {
      final list = result.getOrThrow();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
  }

  Future<String> addBetreuer(String name, Gender gender) async {
    final repo = ref.read(betreuerRepositoryProvider);
    final result = await repo.save((name: name, gender: gender));
    if (result.isFailure()) {
      throw Exception(
        'Failed to save Betreuer: ${result.getFailureOptional().unsafe()}',
      );
    } else {
      // Refresh the list after adding a new Betreuer
      ref.invalidateSelf();

      final betreuer = result.getOrThrow();
      return betreuer.id;
    }
  }
}
