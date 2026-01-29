import 'package:flutter/material.dart';

class ThemeButton extends StatelessWidget {
  final ThemeMode mode;
  final void Function(ThemeMode newMode) onPressed;
  const ThemeButton({super.key, required this.mode, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final newMode = switch (mode) {
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
          ThemeMode.system => ThemeMode.light,
        };
        onPressed(newMode);
      },
      icon: Icon(switch (mode) {
        ThemeMode.light => Icons.dark_mode,
        ThemeMode.dark => Icons.light_mode,
        ThemeMode.system => Icons.brightness_auto,
      }),
      tooltip: switch (mode) {
        ThemeMode.light => 'Zum dunklen Modus wechseln',
        ThemeMode.dark => 'Zum Systemmodus wechseln',
        ThemeMode.system => 'Zum hellen Modus wechseln',
      },
    );
  }
}
