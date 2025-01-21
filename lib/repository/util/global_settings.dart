import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  final SharedPreferencesWithCache _prefs;
  static final String _lofKey = 'last_open';

  GlobalSettings(SharedPreferencesWithCache prefs) : _prefs = prefs;

  String? get lastOpenFile {
    return _prefs.getString(_lofKey);
  }

  SharedPreferencesWithCache get sharedPreferences => _prefs;

  set lastOpenFile(String? file) {
    if (file == null) {
      _prefs.remove(_lofKey);
    } else {
      _prefs.setString(_lofKey, file);
    }
  }
}
