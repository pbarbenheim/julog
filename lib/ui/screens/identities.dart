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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const AddIdentityRoute().go(context);
        },
        child: const Icon(Icons.add),
      ),
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

class AddIdentityForm extends ConsumerStatefulWidget {
  const AddIdentityForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddIdentityFormState();
}

class _AddIdentityFormState extends ConsumerState<AddIdentityForm> {
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _commentController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
              hintText: "Dein eigener Name",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Das Feld darf nicht leer sein";
              }

              if (value.contains(RegExp(
                  r'[\(\)\.\[\]\/\{\}\\\$\!&%<>@"`' '^°=,:;|#+*~]',
                  caseSensitive: false))) {
                return "Der Name enthält verbotene Zeichen.";
              }

              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: "Kommentar",
              hintText: "ein Kommentar, bspw. stv Jfw",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null) {
                return null;
              }
              if (value.contains(RegExp(
                  r'[\(\)\.\[\]\/\{\}\\\$\!&%<>@"`' '^°=,:;|#+*~]',
                  caseSensitive: false))) {
                return "Der Name enthält verbotene Zeichen.";
              }

              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(
              labelText: "Passwort",
              hintText: "Dein PAsswort",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Das Passwort darf nicht leer sein.";
              }
              if (value.runes.length < 12) {
                return "Das Passwort muss mindestens 12 Zeichen enthalten";
              }
              if (!value.contains(RegExp(
                  r'[\!\"\§\$\%\&\/\(\)\=\{\}\[\]\\\+\-\*\#\_\.\,\;\:]'))) {
                return "Das Passwort muss mindestens eins der folgenden Sonderzeichen enthalten: \n!, \", §, \$, %, &, /, (, ), [, ], {, }, \\, ,, ., ;, :, +, -, _, *, #";
              }
              if (!value.contains(RegExp(r'[A-ZÖÄÜ]'))) {
                return "Das Passwort muss mindestens einen Großbuchstaben enthalten";
              }
              if (!value.contains(RegExp(r'[a-zöüä]'))) {
                return "Das Passwort muss mindestens einen Kleinbuchstaben enthalten";
              }
              if (!value.contains(RegExp(r'[0123456789]'))) {
                return "Das Passwort muss mindestens eine Ziffer enthalten";
              }

              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(repositoryProvider);
              if (_formKey.currentState!.validate()) {
                String? comment;
                if (_commentController.text.isNotEmpty) {
                  comment = _commentController.text;
                }
                final result = await repo!.addSigningIdentity(
                  _passwordController.text,
                  _nameController.text,
                  comment,
                );

                if (mounted) {
                  IdentitiesRoute(result.userId).go(context);
                }
              }
            },
            child: const Text("Erstellen"),
          ),
        ],
      ),
    );
  }
}

class AddIdentityScreen extends StatelessWidget {
  const AddIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DienstbuchScaffold(
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
