import 'package:flutter/material.dart';

import '../../pubspec.g.dart';
import 'logo.dart';

class AboutButton extends StatelessWidget {
  const AboutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showJulogAbout(context);
      },
      icon: const Icon(Icons.info_outline),
      tooltip: 'Über julog',
    );
  }
}

void showJulogAbout(BuildContext context) {
  final authors = Pubspec.contributors.join(', ');
  final year = DateTime.now().year;
  showAboutDialog(
    context: context,
    applicationName: Pubspec.name,
    applicationVersion: Pubspec.version,
    applicationLegalese: '© 2024 - $year by $authors',
    applicationIcon: const Padding(
      padding: EdgeInsets.all(8.0),
      child: JulogLogo(),
    ),
    children: [
      Container(
        padding: const EdgeInsets.only(top: 10.0),
        constraints: BoxConstraints.loose(const Size.fromWidth(200)),
        child: const Text(Pubspec.description, softWrap: true),
      ),
      Container(
        padding: const EdgeInsets.only(top: 10.0),
        constraints: BoxConstraints.loose(const Size.fromWidth(200)),
        child: const Text(
          'This software is licensed under the ${Pubspec.license}, to view a copy of the license see licenses below under julog.',
          softWrap: true,
        ),
      ),
    ],
  );
}
