import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared_pref/shared_pref.dart';

part 'darkmode.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  late final SharedPreferencesWithCache _prefs;

  @override
  ThemeMode build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final modeString = _prefs.getString('theme_mode');
    return switch (modeString) {
      'ThemeMode.light' => ThemeMode.light,
      'ThemeMode.dark' => ThemeMode.dark,
      'ThemeMode.system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = switch (mode) {
      ThemeMode.light => 'ThemeMode.light',
      ThemeMode.dark => 'ThemeMode.dark',
      ThemeMode.system => 'ThemeMode.system',
    };
    await _prefs.setString('theme_mode', modeString);
    state = mode;
  }
}
