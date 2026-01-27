import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../router/router.dart';
import '../../view_model/jugendlicher/jugendlicher_view.dart';
import '../list_detail/list_detail.dart';
import 'jugendliche_form.dart';

class JugendlicheScreen extends ConsumerWidget {
  final String? jugendlicherId;
  const JugendlicheScreen({super.key, this.jugendlicherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jugendlicherValue = ref.watch(jugendlicherViewModelProvider);
    return jugendlicherValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (jugendliche) {
        jugendliche.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        final items = jugendliche
            .map((e) => ListItem(title: Text(e.name)))
            .toList();
        var index = jugendlicherId != null
            ? jugendliche.indexWhere((element) => element.id == jugendlicherId)
            : null;
        if (index == -1) {
          index = null;
        }
        return ListDetailLayout(
          items: items,
          initialSelectedIndex: index,
          emptyDetail: const Center(
            child: Text(
              'Wähle einen Jugendlichen aus der Liste aus, um Details zu sehen.',
            ),
          ),
          form: JugendlicherForm(
            onSave: (name, gender, birthDate, memberSince, pass) async {
              final id = await ref
                  .read(jugendlicherViewModelProvider.notifier)
                  .addJugendlicher(
                    name: name,
                    gender: gender,
                    birthDate: birthDate,
                    memberSince: memberSince,
                    pass: pass,
                  );
              if (!context.mounted) return;
              JugendlicheRoute(jugendlicheId: id).go(context);
            },
          ),
          detailBuilder: (context, index) {
            final selectedJugendlicher = jugendliche[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedJugendlicher.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Geschlecht: ${selectedJugendlicher.gender.display}'),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.stateBirthdate(selectedJugendlicher.birthDate),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.stateMemberSince(selectedJugendlicher.memberSince),
                    ),
                    if (selectedJugendlicher.exitDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.stateExitDate(selectedJugendlicher.exitDate!),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Grund für Austritt: ${selectedJugendlicher.exitReason ?? 'Keine Angabe'}",
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
