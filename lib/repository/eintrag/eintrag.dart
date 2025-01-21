import 'package:julog/repository/betreuer/betreuer.dart';
import 'package:julog/repository/signatures/signatur.dart';
import 'package:julog/repository/jugendliche/jugendlicher.dart';
import 'package:julog/repository/kategorien/kategorie.dart';

class EintragHeader {
  final int id;
  final DateTime beginn;
  final Kategorie kategorie;
  final String thema;

  EintragHeader({
    required this.id,
    required this.beginn,
    required this.kategorie,
    required this.thema,
  });
}

class Eintrag extends EintragHeader {
  final DateTime ende;
  final String? ort;
  final String? raum;
  final String? dienstverlauf;
  final String? besonderheiten;
  final List<Betreuer> betreuer;
  final List<JugendlicherInEintrag> jugendliche;
  final List<Signatur> signaturen;

  Eintrag({
    required super.id,
    required super.beginn,
    required this.ende,
    required super.kategorie,
    required super.thema,
    this.ort,
    this.raum,
    this.dienstverlauf,
    this.besonderheiten,
    required this.betreuer,
    required this.jugendliche,
    required this.signaturen,
  });
}
