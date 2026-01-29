import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/router.dart';
import '../../view_model/identity/identity_view.dart';
import '../list_detail/list_detail.dart';
import 'identity_form.dart';

class IdentityScreen extends ConsumerWidget {
  final String? identityId;
  const IdentityScreen({super.key, this.identityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identityValue = ref.watch(identityViewModelProvider);
    return identityValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (identities) {
        identities.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        final items = identities
            .map(
              (e) => ListItem(title: Text(e.name), subtitle: Text(e.function)),
            )
            .toList();
        var index = identityId != null
            ? identities.indexWhere((element) => element.id == identityId)
            : null;
        if (index == -1) {
          index = null;
        }
        return ListDetailLayout(
          items: items,
          initialSelectedIndex: index,
          emptyDetail: const Center(
            child: Text(
              'Wähle eine Identität aus der Liste aus, um Details zu sehen.',
            ),
          ),
          form: IdentityForm(
            onSave: (name, function, mail, password) async {
              final id = await ref
                  .read(identityViewModelProvider.notifier)
                  .addIdentity(name, function, mail, password);
              if (!context.mounted) return;
              IdentityRoute(identityId: id).go(context);
            },
          ),
          detailBuilder: (context, index) {
            final selectedIdentity = identities[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedIdentity.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Funktion: ${selectedIdentity.function}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'E-Mail: ${selectedIdentity.mail}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'lokal vorhanden: ${selectedIdentity.isLocal ? "ja" : "nein"}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
