/// Where a Jugendlicher came from when joining (see ADR-0010).
enum Origin {
  neu,
  andereOrganisation,
  kinderfeuerwehr;

  int toInt() => switch (this) {
    Origin.neu => 0,
    Origin.andereOrganisation => 1,
    Origin.kinderfeuerwehr => 2,
  };

  static Origin fromInt(int value) => switch (value) {
    0 => Origin.neu,
    1 => Origin.andereOrganisation,
    2 => Origin.kinderfeuerwehr,
    _ => throw ArgumentError('Invalid value for Origin enum: $value'),
  };
}
