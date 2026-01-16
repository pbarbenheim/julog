import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/router.dart';
import 'theme.dart';
import '../provider/darkmode/darkmode.dart';

class JulogApp extends ConsumerWidget {
  const JulogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'julog',
      theme: const MaterialTheme(TextTheme()).light(),
      darkTheme: const MaterialTheme(TextTheme()).dark(),
      themeMode: themeMode,
    );
  }
}
