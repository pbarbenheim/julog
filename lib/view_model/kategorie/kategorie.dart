import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jlcore/jlcore.dart';

import '../../repository/kategorie/repository.dart';
import '../../repository/model/model.dart';

part 'kategorie.g.dart';

@riverpod
class KategorieViewModel extends _$KategorieViewModel {
  @override
  Future<List<Kategorie>> build() async {
    final repo = ref.watch(kategorieRepositoryProvider);
    final result = await repo.getAll();
    if (result is Failure<List<Kategorie>>) {
      throw Exception('Failed to load Kategorie: ${result.error}');
    } else {
      final list = result.unwrap();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
  }

  Future<void> editKategorie({
    required String id,
    required String name,
    Berichtsthema? berichtsthema,
  }) async {
    final repo = ref.read(kategorieRepositoryProvider);
    final result = await repo.edit((
      id: id,
      name: name,
      berichtsthema: berichtsthema,
    ));
    if (result is Failure<Unit>) {
      throw Exception('Failed to edit Kategorie: ${result.error}');
    }
    ref.invalidateSelf();
  }

  Future<String> addKategorie(
    String name, {
    Berichtsthema? berichtsthema,
  }) async {
    final repo = ref.read(kategorieRepositoryProvider);
    final result = await repo.save((name: name, berichtsthema: berichtsthema));
    if (result is Failure<Kategorie>) {
      throw Exception('Failed to save Kategorie: ${result.error}');
    } else {
      // Refresh the list after adding a new Kategorie
      ref.invalidateSelf();

      final kategorie = result.unwrap();
      return kategorie.id;
    }
  }
}

/// Whether the name of the Kategorie [id] is locked because a signed Eintrag
/// uses it (ADR-0012).
@riverpod
Future<bool> kategorieNameGesperrt(Ref ref, String id) {
  final repo = ref.watch(kategorieRepositoryProvider);
  return repo.isNameGesperrt(id).unwrap();
}
