import 'package:jldb/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/jugendliche/repository.dart';
import '../../repository/model/model.dart';

part 'jugendlicher_view.g.dart';

@riverpod
class JugendlicherViewModel extends _$JugendlicherViewModel {
  @override
  Future<List<Jugendlicher>> build() async {
    final repo = ref.watch(jugendlicheRepositoryProvider);
    final result = await repo.getAll();
    if (result is Failure<List<Jugendlicher>>) {
      throw Exception('Failed to load Jugendlicher: ${result.error}');
    } else {
      return result.unwrap();
    }
  }

  Future<String> addJugendlicher({
    required String name,
    required Gender gender,
    required DateTime birthDate,
    required DateTime memberSince,
    String? pass,
  }) async {
    final repo = ref.read(jugendlicheRepositoryProvider);
    final result = await repo.save((
      name: name,
      gender: gender,
      birthDate: birthDate,
      memberSince: memberSince,
      pass: pass,
    ));
    if (result is Failure<Jugendlicher>) {
      throw Exception('Failed to save Jugendlicher: ${result.error}');
    } else {
      // Refresh the list after adding a new Jugendlicher
      ref.invalidateSelf();

      final jugendlicher = result.unwrap();
      return jugendlicher.id;
    }
  }
}
