import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../widgets/util.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filename =
        ref.watch(repositoryProvider.select((value) => value?.filename));
    return JulogScaffold(
      destination: Destination.dashboard,
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () => showJulogAbout(context: context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Herzlich Willkommen im Dienstbuch der Jugendfeuerwehr. Die geöffnete Datei ist ${filename ?? "FEHLER"}. Viel Spaß\n\nHier: ${Localizations.localeOf(context).languageCode}",
          softWrap: true,
        ),
      ),
    );
  }
}
