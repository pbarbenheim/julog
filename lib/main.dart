import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'provider/shared_pref/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await createSharedPreferences();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const JulogApp(),
    ),
  );
}
