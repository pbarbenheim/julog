import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../router/router.dart';
import '../../view_model/jugendlicher/jugendlicher_view.dart';
import '../list_detail/list_detail.dart';
import 'austritt_dialog.dart';
import 'jugendliche_form.dart';

class JugendlicheScreen extends ConsumerStatefulWidget {
  final String? jugendlicherId;
  const JugendlicheScreen({super.key, this.jugendlicherId});

  @override
  ConsumerState<JugendlicheScreen> createState() => _JugendlicheScreenState();
}

class _JugendlicheScreenState extends ConsumerState<JugendlicheScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final jugendlicherValue = ref.watch(jugendlicherViewModelProvider);
    return jugendlicherValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (allJugendliche) {
        final today = DateTime.now();
        final jugendliche = allJugendliche
            .where((j) => j.replacedBy == null)
            .toList();
        jugendliche.sort((a, b) {
          final aExited = a.isAusgetreten(today);
          final bExited = b.isAusgetreten(today);
          if (aExited != bExited) return aExited ? 1 : -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        final items = jugendliche.map((e) {
          final exited = e.isAusgetreten(today);
          return ListItem(
            title: Text(
              e.name,
              style: exited
                  ? TextStyle(color: Theme.of(context).disabledColor)
                  : null,
            ),
          );
        }).toList();
        var index = widget.jugendlicherId != null
            ? jugendliche.indexWhere(
                (element) => element.id == widget.jugendlicherId,
              )
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
          actionsBuilder: (context, selectedIndex) {
            if (selectedIndex == null) return null;
            final selectedJugendlicher = jugendliche[selectedIndex];

            if (_isEditing) {
              return [
                IconButton(
                  tooltip: 'Bearbeitung abbrechen',
                  onPressed: () => setState(() => _isEditing = false),
                  icon: const Icon(Icons.close),
                ),
              ];
            }

            final deletable =
                selectedJugendlicher.eintragIds.isEmpty &&
                selectedJugendlicher.replacesId == null;
            final canExit =
                selectedJugendlicher.exitDate == null &&
                selectedJugendlicher.replacedBy == null;
            final canEdit = !selectedJugendlicher.isAusgetreten(today);

            return [
              if (canEdit)
                IconButton(
                  tooltip: 'Bearbeiten',
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                ),
              if (canExit)
                IconButton(
                  tooltip: 'Austritt erfassen',
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AustrittDialog(
                        onConfirm: (exitDate, grund) => ref
                            .read(jugendlicherViewModelProvider.notifier)
                            .exitJugendlicher(
                              selectedJugendlicher.id,
                              exitDate,
                              grund,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                ),
              if (deletable)
                IconButton(
                  onPressed: () {
                    ref
                        .read(jugendlicherViewModelProvider.notifier)
                        .deleteJugendlicher(selectedJugendlicher.id);
                  },
                  icon: const Icon(Icons.delete),
                ),
            ];
          },
          detailBuilder: (context, index) {
            final selectedJugendlicher = jugendliche[index];

            if (_isEditing) {
              return JugendlicherForm(
                initialJugendlicher: selectedJugendlicher,
                onSave: (name, gender, birthDate, memberSince, pass) async {
                  final newId = await ref
                      .read(jugendlicherViewModelProvider.notifier)
                      .editJugendlicher(
                        id: selectedJugendlicher.id,
                        name: name,
                        gender: gender,
                        birthDate: birthDate,
                        memberSince: memberSince,
                        pass: pass,
                      );
                  if (!context.mounted) return;
                  setState(() => _isEditing = false);
                  if (newId != selectedJugendlicher.id) {
                    JugendlicheRoute(jugendlicheId: newId).go(context);
                  }
                },
              );
            }

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
                        'Grund für Austritt: ${selectedJugendlicher.exitReason?.display ?? 'Keine Angabe'}',
                      ),
                    ],
                    if (selectedJugendlicher.eintragIds.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Einträge: ${selectedJugendlicher.eintragIds.length}',
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
