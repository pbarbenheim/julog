import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../jldb/jldb.dart';

part 'shared_pref.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesWithCache sharedPreferences(Ref ref) {
  throw UnimplementedError();
}

Future<SharedPreferencesWithCache> createSharedPreferences() {
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{'theme_mode', JulogService.lastOpenedFileKey},
    ),
  );
}
