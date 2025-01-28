import 'package:julog/repository/util/geschlecht.dart';

class JugendlicherHeader {
  final int id;
  final String name;
  final int? ersetztDurch;

  JugendlicherHeader({
    required this.id,
    required this.name,
    this.ersetztDurch,
  });

  bool get isErsetzt => ersetztDurch != null;

  @override
  bool operator ==(Object other) {
    if (other is JugendlicherHeader) {
      return id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => id;
}

class Jugendlicher extends JugendlicherHeader {
  final String? passnummer;
  final DateTime geburtstag;
  final DateTime eintrittsdatum;
  final DateTime? austrittsdatum;
  final int? austrittsgrund;
  final Geschlecht geschlecht;

  Jugendlicher({
    required super.id,
    required super.name,
    this.passnummer,
    required this.geburtstag,
    required this.eintrittsdatum,
    this.austrittsdatum,
    this.austrittsgrund,
    required this.geschlecht,
    super.ersetztDurch,
  });
}

class RotatingJugendlicheInEintrag {
  Map<int, JugendlicherAnwesenheit> daten = {};

  void rotate(int id) {
    if (daten.containsKey(id)) {
      daten[id] = daten[id]!.rotate();
    } else {
      daten[id] = JugendlicherAnwesenheit.anwesend;
    }
  }

  List<JugendlicherInEintrag> toEintragList() {
    return daten.entries
        .map((e) => JugendlicherInEintrag(
              jugendlicher: JugendlicherHeader(
                id: e.key,
                name: e.key.toRadixString(16),
              ),
              anwesenheit: e.value,
            ))
        .toList();
  }

  T switchOnAnwesenheit<T>(
    int id, {
    required T anwesend,
    required T entschuldigt,
    required T abwesend,
    required T other,
  }) {
    if (!daten.containsKey(id)) {
      return other;
    }
    return daten[id]!.switchOnAnwesenheit(
      anwesend: anwesend,
      entschuldigt: entschuldigt,
      abwesend: abwesend,
      other: other,
    );
  }
}

class JugendlicherInEintrag {
  final JugendlicherHeader jugendlicher;
  JugendlicherAnwesenheit anwesenheit;

  JugendlicherInEintrag(
      {required this.jugendlicher, required this.anwesenheit});

  void rotate() {
    anwesenheit = anwesenheit.rotate();
  }
}

enum JugendlicherAnwesenheit {
  unbestimmt(0, ''),
  anwesend(1, 'anwesend'),
  entschuldigt(2, 'entschuldigt'),
  abwesend(3, 'abwesend');

  final int id;
  final String text;

  const JugendlicherAnwesenheit(this.id, this.text);

  int toNumber() {
    return id;
  }

  @override
  String toString() {
    return text;
  }

  static JugendlicherAnwesenheit fromNumber(int number) {
    switch (number) {
      case 0:
        return JugendlicherAnwesenheit.unbestimmt;
      case 1:
        return JugendlicherAnwesenheit.anwesend;
      case 2:
        return JugendlicherAnwesenheit.entschuldigt;
      case 3:
        return JugendlicherAnwesenheit.abwesend;
      default:
        throw ArgumentError.value(number, "number");
    }
  }

  JugendlicherAnwesenheit rotate() {
    final n = (id + 1) % 4;
    return fromNumber(n);
  }

  T switchOnAnwesenheit<T>({
    required T anwesend,
    required T entschuldigt,
    required T abwesend,
    required T other,
  }) {
    switch (this) {
      case JugendlicherAnwesenheit.anwesend:
        return anwesend;
      case JugendlicherAnwesenheit.abwesend:
        return abwesend;
      case JugendlicherAnwesenheit.entschuldigt:
        return entschuldigt;
      case JugendlicherAnwesenheit.unbestimmt:
        return other;
    }
  }
}
