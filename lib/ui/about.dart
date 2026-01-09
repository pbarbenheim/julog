import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../pubspec.g.dart';

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
      child: VectorGraphic(
        loader: AssetBytesLoader('assets/logo.svg'),
        width: 64,
        height: 64,
      ),
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
