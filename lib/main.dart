import 'dart:ui';

import 'package:dienstbuch/repository/repository.dart';
import 'package:dienstbuch/ui/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  Future<AppExitResponse> _handleShutdown() async {
    ref.read(repositoryProvider.notifier).dispose();
    return AppExitResponse.exit;
  }
}
