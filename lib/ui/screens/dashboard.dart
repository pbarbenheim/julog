import 'package:dienstbuch/repository/repository.dart';
import 'package:dienstbuch/ui/frame.dart';
import 'package:dienstbuch/ui/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filename =
        ref.watch(repositoryProvider.select((value) => value?.filename));
    return DienstbuchScaffold(
      destination: Destination.dashboard,
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () => showDienstbuchAbout(context: context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Herzlich Willkommen im Dienstbuch der Jugendfeuerwehr. Die geöffnete Datei ist ${filename ?? "FEHLER"}. Viel Spaß",
          softWrap: true,
        ),
      ),
    );
  }
}
