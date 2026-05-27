enum ExitReason {
  uebernahme,
  wohnortwechsel,
  noInterest,
  schule,
  ausbildung,
  ausschluss,
  noUebernahme;

  int toInt() => switch (this) {
    ExitReason.uebernahme => 0,
    ExitReason.wohnortwechsel => 1,
    ExitReason.noInterest => 2,
    ExitReason.schule => 3,
    ExitReason.ausbildung => 4,
    ExitReason.ausschluss => 5,
    ExitReason.noUebernahme => 6,
  };

  static ExitReason fromInt(int value) => switch (value) {
    0 => ExitReason.uebernahme,
    1 => ExitReason.wohnortwechsel,
    2 => ExitReason.noInterest,
    3 => ExitReason.schule,
    4 => ExitReason.ausbildung,
    5 => ExitReason.ausschluss,
    6 => ExitReason.noUebernahme,
    _ => throw ArgumentError('Invalid value for ExitReason enum: $value'),
  };
}
