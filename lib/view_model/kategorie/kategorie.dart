import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/kategorie/repository.dart';
import '../../repository/model/model.dart';

part 'kategorie.g.dart';

@riverpod
class KategorieViewModel extends _$KategorieViewModel {
  @override
  Future<List<Kategorie>> build() async {
    final repo = ref.watch(kategorieRepositoryProvider);
    final result = await repo.getAll();
    if (result.isFailure()) {
      throw Exception(
        'Failed to load Kategorie: ${result.getFailureOptional().unsafe()}',
      );
    } else {
      final list = result.getOrThrow();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
  }

  Future<String> addKategorie(String name) async {
    final repo = ref.read(kategorieRepositoryProvider);
    final result = await repo.save((name: name));
    if (result.isFailure()) {
      throw Exception(
        'Failed to save Kategorie: ${result.getFailureOptional().unsafe()}',
      );
    } else {
      // Refresh the list after adding a new Kategorie
      ref.invalidateSelf();

      final kategorie = result.getOrThrow();
      return kategorie.id;
    }
  }
}
