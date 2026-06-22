import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pubspec.g.dart';
import 'update_info.dart';
import 'update_service.dart';
import 'update_state.dart';

class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateServiceProvider);
    return switch (state) {
      AsyncData(:final value) => switch (value) {
        UpdateStateUpdateAvailable(:final info) => _AvailableBanner(info: info),
        UpdateStateDownloading(:final progress) => _DownloadingBanner(
          progress: progress,
        ),
        _ => const SizedBox.shrink(),
      },
      _ => const SizedBox.shrink(),
    };
  }
}

class _AvailableBanner extends ConsumerWidget {
  final UpdateInfo info;
  const _AvailableBanner({required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWindows = Platform.isWindows;
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: Text('Version ${info.version} verfügbar'),
      actions: [
        TextButton(
          onPressed: () => ref
              .read(updateServiceProvider.notifier)
              .resetToUpdateAvailable(info),
          child: const Text('Später'),
        ),
        FilledButton(
          onPressed: () {
            if (isWindows) {
              ref.read(updateServiceProvider.notifier).startDownload(info);
            } else {
              ref.read(updateServiceProvider.notifier).openReleasesPage();
            }
          },
          child: Text(isWindows ? 'Herunterladen' : 'Zur Download-Seite'),
        ),
      ],
    );
  }
}

class _DownloadingBanner extends StatelessWidget {
  final double progress;
  const _DownloadingBanner({required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update wird heruntergeladen… $percent %',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

void showInstallConfirmDialog(
  BuildContext context,
  WidgetRef ref,
  String installerPath,
  UpdateInfo info,
) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: _InstallConfirmDialog(
        installerPath: installerPath,
        info: info,
        ref: ref,
      ),
    ),
  );
}

class _InstallConfirmDialog extends StatelessWidget {
  final String installerPath;
  final UpdateInfo info;
  final WidgetRef ref;

  const _InstallConfirmDialog({
    required this.installerPath,
    required this.info,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update bereit: ${info.version}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Julog ${Pubspec.version} → ${info.version}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Julog wird beendet, aktualisiert und automatisch neu gestartet.',
            ),
            if (info.releaseNotes case final notes? when notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text(
                'Änderungen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    notes,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(updateServiceProvider.notifier)
                .resetToUpdateAvailable(info);
          },
          child: const Text('Später'),
        ),
        FilledButton(
          onPressed: () =>
              ref.read(updateServiceProvider.notifier).install(installerPath),
          child: const Text('Jetzt installieren'),
        ),
      ],
    );
  }
}
