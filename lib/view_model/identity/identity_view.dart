import 'package:jldb/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/identity/repository.dart';
import '../../repository/model/model.dart';

part 'identity_view.g.dart';

@riverpod
class IdentityViewModel extends _$IdentityViewModel {
  @override
  Future<List<Identity>> build() async {
    final repo = ref.watch(identityRepositoryProvider);
    final result = await repo.getAll();
    if (result is Failure<List<Identity>>) {
      throw Exception('Failed to load Identities: ${result.error}');
    } else {
      final list = result.unwrap();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }
  }

  Future<String> addIdentity(
    String name,
    String function,
    String mail,
    String password,
  ) async {
    final repo = ref.read(identityRepositoryProvider);
    final result = await repo.save((
      name: name,
      function: function,
      mail: mail,
      password: password,
    ));
    if (result is Failure<Identity>) {
      throw Exception('Failed to save Identity: ${result.error}');
    } else {
      // Refresh the list after adding a new Identity
      ref.invalidateSelf();

      final identity = result.unwrap();
      return identity.id;
    }
  }
}
