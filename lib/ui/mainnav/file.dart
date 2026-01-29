import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';

import '../../provider/darkmode/darkmode.dart';
import '../../provider/jldb/jldb.dart';
import '../../router/router.dart';
import '../widgets/about.dart';
import '../widgets/logo.dart';
import '../widgets/theme_button.dart';

class SelectFileScreen extends ConsumerWidget {
  final bool loading;
  const SelectFileScreen({super.key, required this.loading});

  static const XTypeGroup _typeGroup = XTypeGroup(
    label: 'julog files',
    extensions: ['jldb'],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Container(
                constraints: const BoxConstraints.expand(width: 84),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ThemeButton(
                      mode: mode,
                      onPressed: (newMode) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(newMode);
                      },
                    ),
                    const SizedBox(width: 8),
                    const AboutButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const Expanded(child: SizedBox.expand()),
            ],
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      JulogLogo(),
                      Padding(padding: EdgeInsets.only(left: 12.0)),
                      Text(
                        'julog',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (loading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Lade Datei...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Öffne oder erstelle eine julog-Datei, um zu starten.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final file = await openFile(
                              acceptedTypeGroups: [_typeGroup],
                              confirmButtonText: 'Öffnen',
                            );
                            if (file != null) {
                              final result = await ref
                                  .read(julogServiceProvider.notifier)
                                  .open(file.path);
                              if (!result && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Die Datei konnte nicht geöffnet werden.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              // Successfully opened the file, navigate to main UI
                              if (context.mounted) {
                                const DashboardRoute().go(context);
                              }
                            }
                          },
                          label: const Text('Öffnen'),
                          icon: const Icon(Icons.file_open_outlined),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final location = await getSaveLocation(
                              acceptedTypeGroups: [_typeGroup],
                              suggestedName: 'neu.jldb',
                              confirmButtonText: 'Erstellen',
                              canCreateDirectories: true,
                            );
                            if (location == null || !context.mounted) return;
                            // Show dialog to enter domain
                            final domainController = TextEditingController();
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Domain eingeben'),
                                content: TextField(
                                  controller: domainController,
                                  decoration: const InputDecoration(
                                    labelText: 'Domain',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Abbrechen'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop(domainController.text);
                                    },
                                    child: const Text('Erstellen'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null) {
                              final createResult = await ref
                                  .read(julogServiceProvider.notifier)
                                  .create(location.path, result);
                              if (!createResult && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Die Datei konnte nicht erstellt werden.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              // Successfully created the file, navigate to main UI
                              if (context.mounted) {
                                const DashboardRoute().go(context);
                              }
                            }
                          },
                          label: const Text('Erstellen'),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
