import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:julog/repository/db/database.dart';
import 'package:julog/repository/repository.dart';
import 'package:julog/ui/routes.dart';
import 'package:path_provider/path_provider.dart';

class DomainForm extends StatefulWidget {
  const DomainForm({super.key});

  @override
  State<DomainForm> createState() => _DomainFormState();
}

class _DomainFormState extends State<DomainForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              "Gebe einen Domain-Namen an, welcher exklusiv vom Dienstbuch benutzt wird",
              softWrap: true,
            ),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                label: Text("Domain-Name"),
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                Navigator.pop(context, value);
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Die Domain wird benötigt";
                }
                if (!JulogDatabase.validDomain(value)) {
                  return "Es muss sich um eine korrekte Domain handeln";
                }
                return null;
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 6)),
            TextButton(
              onPressed: () => Navigator.pop(context, _controller.text),
              child: const Text("Weiter"),
            )
          ],
        ),
      ),
    );
  }
}

class JulogFileUIUtil {
  static Future<bool> Function() getOpenFileFn(
      BuildContext context, Repository notifier) {
    return () async {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Dienstbuch',
        extensions: ["jfdb"],
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

  static Future<bool> Function() getCreateFileFn(
      BuildContext context, Repository notifier) {
    return () async {
      const String fileName = "dienstbuch.jfdb";
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Dienstbuch',
        extensions: ["jfdb"],
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
        notifier.createFile(location.path, domainName);
        if (context.mounted) {
          DashboardRoute().go(context);
        }
        return true;
      }
      return false;
    };
  }

  static Future<String?> _getDomainName(BuildContext context) async {
    final result = await showAdaptiveDialog<String?>(
      context: context,
      builder: (context) => DomainForm(),
    );
    return result;
  }
}
