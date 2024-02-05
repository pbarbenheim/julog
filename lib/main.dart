import 'dart:io';
import 'dart:ui';

import 'package:dienstbuch/repository/repository.dart';
import 'package:dienstbuch/ui/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  String? file;
  if (args.isNotEmpty) {
    file = args.last;
  } else {
    file = Repository.getLastOpenFile(prefs);
  }

  runApp(ProviderScope(
    overrides: [
      if (file != null)
        repositoryProvider
            .overrideWith(() => RepositoryNotifier(filename: file)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const DienstbuchApp(),
  ));
}

class DienstbuchApp extends ConsumerStatefulWidget {
  const DienstbuchApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DienstbuchAppState();
}

class _DienstbuchAppState extends ConsumerState<DienstbuchApp> {
  // ignore: unused_field
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    _lifecycleListener = AppLifecycleListener(
      onDetach: _handleShutdown,
      onExitRequested: _handleShutdown,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final filename =
        ref.watch(repositoryProvider.select((value) => value?.filename));
    final file = filename != null ? path.basename(filename) : null;
    final String title;
    if (file == null) {
      title = "JF-Dienstbuch";
    } else {
      title = "$file - JF-Dienstbuch";
    }
    if (Platform.isLinux || Platform.isMacOS || Platform.isLinux) {
      setWindowTitle(title);
    }
    return MaterialApp.router(
      routerConfig: router,
      title: title,
      supportedLocales: const [Locale("de")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  Future<AppExitResponse> _handleShutdown() async {
    ref.read(repositoryProvider.notifier).dispose();
    return AppExitResponse.exit;
  }
}
