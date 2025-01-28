import 'package:flutter/material.dart';

class PasswortDialog extends StatefulWidget {
  const PasswortDialog({super.key});

  @override
  State<PasswortDialog> createState() => _PasswortDialogState();
}

class _PasswortDialogState extends State<PasswortDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              "Gebe dein Passwort zum Signieren an.",
              softWrap: true,
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                label: Text("Passwort"),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              onSubmitted: (value) {
                Navigator.pop(context, value);
              },
            ),
            const Padding(padding: EdgeInsets.only(top: 6)),
            TextButton(
                onPressed: () {
                  final String text = controller.text;
                  Navigator.pop(context, text);
                },
                child: const Text("Weiter"))
          ],
        ),
      ),
    );
  }
}
