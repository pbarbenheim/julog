import 'package:freezed_annotation/freezed_annotation.dart';

part 'berichtsentwurf_api_model.freezed.dart';

/// Status of a Berichtsentwurf. Stored as an integer in the database.
enum BerichtsentwurfStatus {
  entwurf,
  exportiert;

  int toInt() => switch (this) {
    BerichtsentwurfStatus.entwurf => 0,
    BerichtsentwurfStatus.exportiert => 1,
  };

  static BerichtsentwurfStatus fromInt(int value) => switch (value) {
    0 => BerichtsentwurfStatus.entwurf,
    1 => BerichtsentwurfStatus.exportiert,
    _ => throw ArgumentError(
      'Invalid value for BerichtsentwurfStatus enum: $value',
    ),
  };
}

/// The saved state of one Jahresbericht (Berichtsentwurf), one per [year].
///
/// jldb does not know the structure of the report. [angaben] (the manual
/// answers) and [ueberschreibungen] (the overridden work values) are plain
/// maps from field key to value that the app maps to and from its own
/// types. Values in [angaben] are `bool` or `int`; values in
/// [ueberschreibungen] are `int`.
@freezed
abstract class BerichtsentwurfApiModel with _$BerichtsentwurfApiModel {
  const factory BerichtsentwurfApiModel({
    required int year,
    required Map<String, Object> angaben,
    required Map<String, int> ueberschreibungen,
    required BerichtsentwurfStatus status,

    /// When the draft was last marked as exported; `null` while the status
    /// is [BerichtsentwurfStatus.entwurf].
    DateTime? exportedAt,
  }) = _BerichtsentwurfApiModel;
}
