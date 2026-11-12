import 'package:freezed_annotation/freezed_annotation.dart';

import '../report_topic.dart';
import '../uuid.dart';

part 'kategorie_api_model.freezed.dart';

@freezed
abstract class KategorieApiModel with _$KategorieApiModel {
  const factory KategorieApiModel({
    required UUID id,
    required String name,
    ReportTopic? reportTopic,
  }) = _KategorieApiModel;
}
