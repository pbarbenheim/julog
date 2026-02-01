// ignore_for_file: avoid_print

import 'package:jldb/jldb.dart';

void main() async {
  final jldb = await Jldb.create(':memory:', domain: 'jf.example.com').unwrap();

  await jldb.createKategorie(
    KategorieApiModel(id: UUID.generate(), name: 'Kategorie 1'),
  );

  final kategorien = await jldb.getAllKategorien().unwrap();
  print(kategorien.first.name);
}
