import 'package:dienstbuch/repository/repository.dart';
import 'package:dienstbuch/ui/frame.dart';
import 'package:dienstbuch/ui/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }
}

class SignIdentityItem extends Item {
  final String name;
  final String? comment;
  final String email;
  final String userId;
  const SignIdentityItem({
    super.key,
    required this.name,
    this.comment,
    required this.email,
    required this.userId,
  }) : super(
          title: name,
          subtitle: comment,
        );

  @override
  Widget build(BuildContext context) {
    return Text("Dies ist die Identität von $userId");
  }
}
