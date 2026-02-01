import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/betreuer/repository.dart';
import '../../repository/jugendliche/repository.dart';
import '../../repository/kategorie/repository.dart';

part 'eintrag_form_viewmodel.freezed.dart';
part 'eintrag_form_viewmodel.g.dart';

@riverpod
Future<EintragFormOptions> eintragFormViewmodel(Ref ref) async {
  final kategorieRepo = ref.watch(kategorieRepositoryProvider);
  final betreuerRepo = ref.watch(betreuerRepositoryProvider);
  final jugendlicheRepo = ref.watch(jugendlicheRepositoryProvider);

  final kategorien = await kategorieRepo.getAll().unwrap();
  final betreuer = await betreuerRepo.getAll().unwrap();
  final jugendliche = await jugendlicheRepo.getAll().unwrap();

  return EintragFormOptions(
    kategorieOptions: {
      for (var kategorie in kategorien) kategorie.id: kategorie.name,
    },
    betreuerOptions: {for (var b in betreuer) b.id: b.name},
    jugendlicheOptions: {for (var j in jugendliche) j.id: j.name},
  );
}

@freezed
abstract class EintragFormOptions with _$EintragFormOptions {
  const factory EintragFormOptions({
    required Map<String, String> kategorieOptions,
    required Map<String, String> betreuerOptions,
    required Map<String, String> jugendlicheOptions,
  }) = _EintragFormOptions;
}
