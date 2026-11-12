import 'package:material_ui/material_ui.dart';

/// Ein Abschnitt der Zusammenfassung oder der Arbeitswerte: Überschrift mit
/// Abstand nach oben, darunter der Inhalt.
class Abschnitt extends StatelessWidget {
  final String titel;
  final Widget inhalt;

  const Abschnitt({super.key, required this.titel, required this.inhalt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          inhalt,
        ],
      ),
    );
  }
}
