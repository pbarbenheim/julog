import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jldb/jldb.dart';

import '../shared_pref/shared_pref.dart';
import 'julog_file.dart';

part 'jldb.g.dart';

@Riverpod(keepAlive: true)
class JulogService extends _$JulogService {
  static const String lastOpenedFileKey = 'last_opened_jldb_file';

  @override
  JulogFile build() {
    final file = ref
        .watch(sharedPreferencesProvider)
        .getString(lastOpenedFileKey);
    if (file != null) {
      Jldb.open(file).then((result) {
        if (result is Failure<Jldb>) {
          _saveToPrefs('');
          return;
        }
        state = JulogFile.loaded(jldb: result.unwrap());
      });
      return const JulogFile.loading();
    }
    return const JulogFile.none();
  }

  void _saveToPrefs(String path) {
    // Save the last opened file path to shared preferences
    ref.read(sharedPreferencesProvider).setString(lastOpenedFileKey, path);
  }

  Future<bool> open(String path) async {
    final jldb = await Jldb.open(path);
    if (jldb is Failure<Jldb>) {
      return false;
    }
    state = JulogFile.loaded(jldb: jldb.unwrap());
    _saveToPrefs(path);
    return true;
  }

  Future<bool> create(String path, String domain) async {
    final jldb = await Jldb.create(path, domain: domain);
    if (jldb is Failure<Jldb>) {
      return false;
    }
    state = JulogFile.loaded(jldb: jldb.unwrap());
    _saveToPrefs(path);
    return true;
  }

  Future<void> close() async {
    if (state is JulogFileLoaded) {
      await (state as JulogFileLoaded).jldb.close();
    }
    state = const JulogFile.closed();
  }

  Future<void> reset() async {
    if (state is JulogFileLoaded) {
      await (state as JulogFileLoaded).jldb.close();
    }
    state = const JulogFile.none();
    _saveToPrefs('');
  }
}
