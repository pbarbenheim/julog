import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlcore/jlcore.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;

import '../../provider/logging/logging.dart';
import '../../repository/identity/exception.dart';
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
                    return Row(
                      children: [
                        Icon(
                          s.isValid ? Icons.check : Icons.error,
                          color: s.isValid
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                        Text(
                          '${s.identity.name}, ${s.identity.function}, am ${MaterialLocalizations.of(context).formatFullDate(s.timestamp)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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
                    switch (signResult) {
                      case Success<Unit>():
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Eintrag erfolgreich signiert.'),
                          ),
                        );
                      case Failure<Unit>():
                        if (!context.mounted) return;
                        final logPath = ref.read(loggingServiceProvider);
                        final error = signResult.error;
                        final message = switch (error) {
                          crypto.PasswortWrongException() =>
                            'Das eingegebene Passwort ist falsch oder der private Schlüssel ist beschädigt.',
                          PrivateKeyNotFoundException() =>
                            'Der private Schlüssel wurde nicht auf diesem Gerät gefunden. Die Identität wurde möglicherweise auf einem anderen Gerät erstellt.',
                          crypto.CorruptedKeyContainerException() =>
                            'Der gespeicherte Schlüssel ist beschädigt und kann nicht gelesen werden.',
                          _ => 'Ein unbekannter Fehler ist aufgetreten.',
                        };
                        await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Fehler beim Signieren'),
                            content: Text(message),
                            actions: [
                              TextButton(
                                onPressed: () => Clipboard.setData(
                                  ClipboardData(text: logPath),
                                ),
                                child: const Text('Pfad der Logdatei kopieren'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
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
          title: const Text('Identität zum Signieren wählen'),
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
        const SnackBar(content: Text('Keine Identität ausgewählt')),
      );
      return null;
    }

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Passwort eingeben'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Passwort'),
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
        const SnackBar(
          content: Text('Das Passwort wird zum Unterschreiben benötigt'),
        ),
      );
      return null;
    }

    return (identity.id, password);
  }
}
