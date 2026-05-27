enum AustrittsGrund {
  uebernahme,
  wohnortwechsel,
  noInterest,
  schule,
  ausbildung,
  ausschluss,
  noUebernahme;

  String get display => switch (this) {
    AustrittsGrund.uebernahme => 'Übernahme',
    AustrittsGrund.wohnortwechsel => 'Wohnortwechsel',
    AustrittsGrund.noInterest => 'Interesse an JF verloren',
    AustrittsGrund.schule => 'Belastung durch Schule',
    AustrittsGrund.ausbildung => 'Berufsausbildung',
    AustrittsGrund.ausschluss => 'Verweis bzw. Ausschluss',
    AustrittsGrund.noUebernahme => 'möchte keine Übernahme in EA',
  };

  int toInt() => switch (this) {
    AustrittsGrund.uebernahme => 0,
    AustrittsGrund.wohnortwechsel => 1,
    AustrittsGrund.noInterest => 2,
    AustrittsGrund.schule => 3,
    AustrittsGrund.ausbildung => 4,
    AustrittsGrund.ausschluss => 5,
    AustrittsGrund.noUebernahme => 6,
  };

  static AustrittsGrund fromInt(int value) => switch (value) {
    0 => AustrittsGrund.uebernahme,
    1 => AustrittsGrund.wohnortwechsel,
    2 => AustrittsGrund.noInterest,
    3 => AustrittsGrund.schule,
    4 => AustrittsGrund.ausbildung,
    5 => AustrittsGrund.ausschluss,
    6 => AustrittsGrund.noUebernahme,
    _ => throw ArgumentError('Unknown AustrittsGrund value: $value'),
  };
}
