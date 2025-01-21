import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/util/global_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'repository.g.dart';

@riverpod
class Repository extends _$Repository {
  String? _filename;

  @override
  JulogDatabase? build() {
    final globalSettings = ref.watch(globalSettingsProvider);

    if (_filename != null) {
      return JulogDatabase(
        filename: _filename!,
        globalSettings: globalSettings,
      );
    }
    final file = globalSettings.lastOpenFile;
    if (file != null) {
      _filename = file;
      return JulogDatabase(
        filename: _filename!,
        globalSettings: globalSettings,
      );
    }
    return null;
  }

  void openFile(String file) {
    final globalSettings = ref.watch(globalSettingsProvider);

    final db = JulogDatabase(filename: file, globalSettings: globalSettings);
    _filename = file;
    globalSettings.lastOpenFile = file;
    state = db;
  }

  void createFile(String file, String domain) {
    final globalSettings = ref.watch(globalSettingsProvider);

    final db = JulogDatabase.create(
      filename: file,
      domain: domain,
      globalSettings: globalSettings,
    );
    _filename = file;
    globalSettings.lastOpenFile = file;
    state = db;
  }
}

final sharedPreferencesProvider =
    Provider<SharedPreferencesWithCache>((ref) => throw UnimplementedError());

@riverpod
GlobalSettings globalSettings(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GlobalSettings(prefs);
}
