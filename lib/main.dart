import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'repository/repository.dart';

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
