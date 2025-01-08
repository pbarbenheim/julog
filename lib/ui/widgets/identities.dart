import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';

class SignIdentityItem extends Item {
  final String name;
  final String? comment;
  final String email;
  final String userId;
  SignIdentityItem({
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
  bool _passwordObscured = true;
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
            obscureText: _passwordObscured,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: "Passwort",
              hintText: "Dein Passwort",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_passwordObscured
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _passwordObscured = !_passwordObscured;
                  });
                },
              ),
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
                return "Das Passwort muss mindestens eins der folgenden Sonderzeichen enthalten: \n! \" § \$ % & / ( ) [ ] { } \\ , . ; : + - _ * #";
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
          TextFormField(
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(
              labelText: "Passwort wiederholen",
              hintText: "Wiederhole dein Passwort",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Das Feld darf nicht leer sein";
              }
              if (value != _passwordController.text) {
                return "Die Passwörter stimmen nicht überein";
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(repositoryProvider);
              if (_formKey.currentState!.validate()) {
                showAdaptiveDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const PopScope(
                    canPop: false,
                    child: SimpleDialog(
                      backgroundColor: Colors.white,
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 16, top: 16, right: 16),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                    "Bitte warte einen Moment während wir den Schlüssel für dich erstellen"),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
                String? comment;
                if (_commentController.text.isNotEmpty) {
                  comment = _commentController.text;
                }
                final result = await repo!.addSigningIdentity(
                  _passwordController.text,
                  _nameController.text,
                  comment,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();

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
