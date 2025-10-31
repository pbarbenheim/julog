import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:julog/l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';

import 'repository/repository.dart';
import 'ui/routes.dart';

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
    final filename = ref.watch(repositoryProvider.select(
      (data) => data?.filename,
    ));
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
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  Future<AppExitResponse> _handleShutdown() async {
    ref.read(repositoryProvider)?.dispose();
    return AppExitResponse.exit;
  }
}
