import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/router.dart';
import '../../view_model/betreuer/betreuer.dart';
import '../list_detail/list_item.dart';
import '../list_detail/screen.dart';
import 'form.dart';

class BetreuerScreen extends ConsumerWidget {
  final String? betreuerId;
  const BetreuerScreen({super.key, this.betreuerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betreuerValue = ref.watch(betreuerViewModelProvider);
    return betreuerValue.when(
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        return Center(child: Text('Error: $error'));
      },
      data: (betreuer) {
        betreuer.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        final items = betreuer
            .map((e) => ListItem(title: Text(e.name)))
            .toList();
        var index = betreuerId != null
            ? betreuer.indexWhere((element) => element.id == betreuerId)
            : null;
        if (index == -1) {
          index = null;
        }
        return ListDetailLayout(
          items: items,
          initialSelectedIndex: index,
          emptyDetail: const Center(
            child: Text(
              'Wähle einen Betreuer aus der Liste aus, um Details zu sehen.',
            ),
          ),
          form: BetreuerForm(
            onSave: (name, gender) async {
              final id = await ref
                  .read(betreuerViewModelProvider.notifier)
                  .addBetreuer(name, gender);

              if (!context.mounted) return;
              BetreuerRoute(betreuerId: id).go(context);
            },
          ),
          detailBuilder: (context, index) {
            final selectedBetreuer = betreuer[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedBetreuer.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text('ID: ${selectedBetreuer.id}'),
                    const SizedBox(height: 8),
                    Text('Geschlecht: ${selectedBetreuer.gender.display}'),
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
