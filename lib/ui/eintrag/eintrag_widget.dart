import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/model/model.dart';
import '../../view_model/eintrag/selected_eintrag_viewmodel.dart';

class EintragDisplay extends ConsumerWidget {
  final String eintragId;
  const EintragDisplay({super.key, required this.eintragId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eintragValue = ref.watch(selectedEintragViewModelProvider(eintragId));
    return eintragValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (eintrag) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thema: ${eintrag.thema}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kategorie: ${eintrag.kategorie.name}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Startzeit: ${MaterialLocalizations.of(context).formatFullDate(eintrag.start)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ende: ${MaterialLocalizations.of(context).formatFullDate(eintrag.end)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ort: ${eintrag.ort ?? 'Nicht angegeben'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Raum: ${eintrag.raum ?? 'Nicht angegeben'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dienstverlauf: ${eintrag.dienstverlauf ?? 'Nicht angegeben'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Besonderheiten: ${eintrag.besonderheiten ?? 'Nicht angegeben'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                const Text('Betreuer'),
                ...eintrag.betreuer.map(
                  (b) => Text(
                    '- ${b.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Anwesende Jugendliche'),
                ...eintrag.anwesendeJugendliche.map(
                  (j) => Text(
                    '- ${j.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Entschuldigte Jugendliche'),
                ...eintrag.entschuldigteJugendliche.map(
                  (j) => Text(
                    '- ${j.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  eintrag.signatures.isNotEmpty
                      ? 'Signaturen'
                      : 'Keine Signaturen vorhanden',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (eintrag.signatures.isNotEmpty) ...[
                  ...eintrag.signatures.map((s) {
                    final validityText = s.isValid ? 'gültig' : 'ungültig';
                    return Text(
                      '- ($validityText) Signatur ID: ${s.id}, Datum: ${MaterialLocalizations.of(context).formatFullDate(s.timestamp)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }),
                  const SizedBox(height: 8),
                ],
                TextButton(
                  onPressed: () async {
                    final result = await _sign(
                      context,
                      eintrag.possibleSigners,
                    );
                    if (result == null) return;
                    final (identityId, password) = result;

                    final signResult = await ref
                        .read(
                          selectedEintragViewModelProvider(eintragId).notifier,
                        )
                        .sign(identityId, password);
                    if (signResult.isSuccess()) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Eintrag erfolgreich signiert.'),
                        ),
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fehler beim Signieren: ${signResult.getFailureOptional().unwrap().toString()}',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Signieren'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<(String, String)?> _sign(
    BuildContext context,
    List<Identity> identities,
  ) async {
    final identity = await showDialog<Identity>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Identity to Sign'),
          children: identities.map((identity) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, identity);
              },
              child: Text(identity.name),
            );
          }).toList(),
        );
      },
    );
    if (!context.mounted) return null;
    if (identity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No identity selected for signing.')),
      );
      return null;
    }

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return null;
    if (password == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required for signing.')),
      );
      return null;
    }

    return (identity.id, password);
  }
}
