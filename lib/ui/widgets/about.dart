import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/logging/logging.dart';
import '../../pubspec.g.dart';
import 'logo.dart';

class AboutButton extends ConsumerWidget {
  const AboutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logPath = ref.watch(loggingServiceProvider);
    return IconButton(
      onPressed: () {
        showJulogAbout(context, logPath: logPath);
      },
      icon: const Icon(Icons.info_outline),
      tooltip: 'Über julog',
    );
  }
}

void showJulogAbout(BuildContext context, {String? logPath}) {
  final authors = Pubspec.contributors.join(', ');
  final year = DateTime.now().year;
  final logFileExists = logPath != null && File(logPath).existsSync();
  showAboutDialog(
    context: context,
    applicationName: Pubspec.name,
    applicationVersion: Pubspec.version,
    applicationLegalese: '© 2024 - $year by $authors',
    applicationIcon: const Padding(
      padding: EdgeInsets.all(8.0),
      child: JulogLogo(),
    ),
    children: [
      Container(
        padding: const EdgeInsets.only(top: 10.0),
        constraints: BoxConstraints.loose(const Size.fromWidth(200)),
        child: const Text(Pubspec.description, softWrap: true),
      ),
      Container(
        padding: const EdgeInsets.only(top: 10.0),
        constraints: BoxConstraints.loose(const Size.fromWidth(200)),
        child: const Text(
          'This software is licensed under the ${Pubspec.license}, to view a copy of the license see licenses below under julog.',
          softWrap: true,
        ),
      ),
      if (logFileExists) _LogFileSection(logPath: logPath),
    ],
  );
}

class _LogFileSection extends StatelessWidget {
  final String logPath;
  const _LogFileSection({required this.logPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      constraints: BoxConstraints.loose(const Size.fromWidth(200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Logdatei', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(logPath, style: const TextStyle(fontSize: 12)),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: logPath));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pfad in Zwischenablage kopiert'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Pfad kopieren'),
          ),
        ],
      ),
    );
  }
}
