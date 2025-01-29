import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:julog/ui/widgets/select_file.dart';

import '../../repository/repository.dart';
import '../widgets/util.dart';

class SelectFileScreen extends ConsumerWidget {
  const SelectFileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datei auswählen"),
        actions: [
          IconButton(
            onPressed: () => showJulogAbout(context: context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
                "Bitte wähle eine Datei aus oder erstelle ein neues Dienstbuch."),
            const Padding(padding: EdgeInsets.only(top: 15)),
            ElevatedButton(
              onPressed: JulogFileUIUtil.getOpenFileFn(context, repository),
              child: const Text("Datei öffnen"),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            ElevatedButton(
              onPressed: JulogFileUIUtil.getCreateFileFn(context, repository),
              child: const Text("Datei erstellen"),
            ),
          ],
        ),
      ),
    );
  }
}
