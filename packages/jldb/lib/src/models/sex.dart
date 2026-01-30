enum Sex {
  male,
  female,
  diverse;

  int toInt() {
    return switch (this) {
      male => 0,
      female => 1,
      diverse => 2,
    };
  }

  static Sex fromInt(int value) {
    return switch (value) {
      0 => male,
      1 => female,
      2 => diverse,
      _ => throw ArgumentError('Invalid value for Sex enum: $value'),
    };
  }
}
