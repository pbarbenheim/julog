import 'package:julog/repository/repository.dart';
import 'package:julog/ui/routes.dart';
import 'package:julog/ui/util.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class SelectFileScreen extends ConsumerWidget {
  const SelectFileScreen({super.key});

  Future<bool> Function() _getOpenFile(
      BuildContext context, RepositoryNotifier notifier) {
    return () async {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Dienstbuch',
        extensions: ["jfdb", 'julog', "jfjulog"],
        mimeTypes: ["application/x.de.barbenheim.julog+sqlite3"],
      );

      final file = await openFile(
        acceptedTypeGroups: [
          typeGroup,
          const XTypeGroup(label: "Alle"),
        ],
        initialDirectory:
            (await getApplicationDocumentsDirectory()).absolute.path,
      );
      if (file != null) {
        notifier.openFile(file.path);
        if (context.mounted) {
          DashboardRoute().go(context);
        }
        return true;
      }
      return false;
    };
  }

  Future<String?> _getDomainName(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final result = await showAdaptiveDialog<String?>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text(
                "Gebe einen Domain-Namen an, welcher exklusiv vom Dienstbuch benutzt wird",
                softWrap: true,
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  label: Text("Domain-Name"),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 6)),
              TextButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text("Weiter"))
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<bool> Function() _getCreateFile(
      BuildContext context, RepositoryNotifier notifier) {
    return () async {
      const String fileName = "julog.jfdb";
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Dienstbuch',
        extensions: ["jfdb", 'julog', "jfjulog"],
        mimeTypes: ["application/x.de.barbenheim.julog+sqlite3"],
      );
      final domainName = await _getDomainName(context);
      if (domainName == null) {
        return false;
      }
      final location = await getSaveLocation(
          acceptedTypeGroups: [
            typeGroup,
            const XTypeGroup(label: "Alle"),
          ],
          initialDirectory:
              (await getApplicationDocumentsDirectory()).absolute.path,
          suggestedName: fileName);
      if (location != null) {
        notifier.newFile(location.path, domainName);
        if (context.mounted) {
          DashboardRoute().go(context);
        }
        return true;
      }
      return false;
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(repositoryProvider.notifier);
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
              onPressed: _getOpenFile(context, notifier),
              child: const Text("Datei öffnen"),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            ElevatedButton(
              onPressed: _getCreateFile(context, notifier),
              child: const Text("Datei erstellen"),
            ),
          ],
        ),
      ),
    );
  }
}
