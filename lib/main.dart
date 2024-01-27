import 'dart:io';

import 'package:dienstbuch/repository/repository.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  String? file;
  if (args.isNotEmpty) {
    file = args.last;
  }

  runApp(ProviderScope(
    child: DienstbuchApp(file),
  ));
}

class DienstbuchApp extends StatelessWidget {
  final String? fileUri;
  const DienstbuchApp(this.fileUri, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            final result = await getSaveLocation(
              acceptedTypeGroups: [
                XTypeGroup(extensions: ["dienstbuch"], label: "Dienstbuch")
              ],
              initialDirectory:
                  (await getApplicationDocumentsDirectory()).absolute.path,
            );
            final file = result!.path;
            final repo = Repository.create(file, "jf-test.example.org");
            repo.dispose();
            exit(0);
          },
          child: const Text("Neue Datei erstellen"),
        ),
      ),
    );
  }
}
