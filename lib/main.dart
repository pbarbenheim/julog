import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';

import 'repository/repository.dart';
import 'ui/routes.dart';

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
    child: const JulogApp(),
  ));
}

class JulogApp extends ConsumerStatefulWidget {
  const JulogApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _JulogAppState();
}

class _JulogAppState extends ConsumerState<JulogApp> {
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
      title = "julog";
    } else {
      title = "$file - julog";
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
