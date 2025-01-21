enum Geschlecht {
  maennlich(0, "männlich"),
  weiblich(1, "weiblich"),
  divers(2, "divers");

  final int id;
  final String text;

  const Geschlecht(this.id, this.text);

  int toNumber() {
    return id;
  }

  @override
  String toString() {
    return text;
  }

  static Geschlecht fromNumber(int number) {
    switch (number) {
      case 0:
        return Geschlecht.maennlich;
      case 1:
        return Geschlecht.weiblich;
      case 2:
        return Geschlecht.divers;
      default:
        throw ArgumentError.value(number, "number");
    }
  }
}
