import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/logging/logging.dart';
import 'provider/shared_pref/shared_pref.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await createSharedPreferences();
  final logPath = await initLoggingService();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        loggingServiceProvider.overrideWithValue(logPath),
      ],
      child: const JulogApp(),
    ),
  );
}
