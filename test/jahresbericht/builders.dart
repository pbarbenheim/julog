import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/repository/model/model.dart';

var _counter = 0;

Jugendlicher jug({
  Gender gender = Gender.male,
  DateTime? birthDate,
  DateTime? memberSince,
  Herkunft herkunft = Herkunft.neu,
  DateTime? exitDate,
  AustrittsGrund? exitReason,
  Jugendlicher? replacedBy,
  String? replacesId,
}) {
  final id = 'jug-${_counter++}';
  return Jugendlicher(
    id: id,
    name: 'Name $id',
    gender: gender,
    birthDate: birthDate ?? DateTime(2012, 6, 15),
    memberSince: memberSince ?? DateTime(2020, 1, 1),
    herkunft: herkunft,
    exitDate: exitDate,
    exitReason: exitReason,
    replacedBy: replacedBy,
    replacesId: replacesId,
    eintragIds: const {},
  );
}

Betreuer betreuer(Gender gender) {
  final id = 'bet-${_counter++}';
  return Betreuer(id: id, name: 'Betreuer $id', gender: gender);
}

Kategorie kategorie({String? id, Berichtsthema? thema}) {
  final kid = id ?? 'kat-${_counter++}';
  return Kategorie(id: kid, name: 'Kategorie $kid', berichtsthema: thema);
}

Eintrag eintrag({
  Kategorie? kategorie,
  DateTime? start,
  DateTime? end,
  Set<String> betreuerIds = const {},
  bool isSigned = false,
}) {
  final s = start ?? DateTime(2025, 5, 5, 18);
  return Eintrag(
    id: 'ein-${_counter++}',
    start: s,
    end: end ?? s.add(const Duration(hours: 2)),
    kategorieId: kategorie?.id ?? 'kat-1',
    thema: 'Thema',
    betreuerIds: betreuerIds,
    anwesendeJugendlicherIds: const {},
    entschuldigteJugendlicherIds: const {},
    undefinierteJugendlicherIds: const {},
    isSigned: isSigned,
  );
}

Berichtswert bericht(
  int jahr, {
  List<Jugendlicher> jugendliche = const [],
  List<Betreuer> betreuer = const [],
  List<Eintrag> eintraege = const [],
  List<Kategorie> kategorien = const [],
  Map<String, int> ueberschreibungen = const {},
}) => berechneBerichtswert(
  berichtsjahr: jahr,
  jugendliche: jugendliche,
  betreuer: betreuer,
  eintraege: eintraege,
  kategorien: kategorien,
  ueberschreibungen: Ueberschreibungen(ueberschreibungen),
);
