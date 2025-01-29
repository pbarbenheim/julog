import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';

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
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Herzlich Willkommen im Dienstbuch der Jugendfeuerwehr. Die geöffnete Datei ist ${filename ?? "FEHLER"}.",
              softWrap: true,
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text("Viel Spaß!")
          ],
        ),
      ),
    );
  }
}
