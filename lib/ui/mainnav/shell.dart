import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/darkmode/darkmode.dart';
import '../widgets/about.dart';
import '../widgets/theme_button.dart';
import 'destination.dart';

class Shell extends ConsumerWidget {
  final Widget child;
  final Destination destination;
  const Shell({super.key, required this.child, required this.destination});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            destinations: Destination.values
                .map((e) => e.railDestination)
                .toList(),
            onDestinationSelected: (value) {
              final destination = Destination.values[value];
              destination.route().go(context);
            },
            selectedIndex: destination.index,
            labelType: NavigationRailLabelType.all,
            leadingAtTop: true,
            trailingAtBottom: true,
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeButton(
                  mode: mode,
                  onPressed: (newMode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                  },
                ),
                const SizedBox(width: 8),
                const AboutButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
