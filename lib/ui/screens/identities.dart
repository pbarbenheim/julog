import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import '../widgets/identities.dart';

class SignIdentitiesScreen extends ConsumerWidget {
  final String? userId;
  const SignIdentitiesScreen({super.key, this.userId});

  SignIdentityItem _userIdToItem(String userId) {
    final (name, comment, email) = Repository.userIdToComponents(userId);
    return SignIdentityItem(
      name: name,
      email: email,
      comment: comment.isNotEmpty ? comment : null,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final items =
        repo!.getSigningUserIds().map((e) => _userIdToItem(e)).toList();
    SignIdentityItem? selectedItem;
    try {
      selectedItem = items.firstWhere((element) => element.userId == userId);
    } catch (e) {
      //Nothing to catch
    }

    return ListDetail<SignIdentityItem>(
      items: items,
      onChanged: (value) {
        IdentitiesRoute(value.userId).go(context);
      },
      listHeader: "Verfügbare Signaturen",
      destination: Destination.identities,
      selectedItem: selectedItem,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const AddIdentityRoute().go(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddIdentityScreen extends StatelessWidget {
  const AddIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JulogScaffold(
      body: const Center(
        child: AddIdentityForm(),
      ),
      destination: Destination.identities,
      appBar: AppBar(
        title: const Text("Identität hinzufügen"),
      ),
    );
  }
}
