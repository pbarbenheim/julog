import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

part 'kategorie.freezed.dart';

@freezed
abstract class Kategorie with _$Kategorie {
  const factory Kategorie({required String id, required String name}) =
      _Kategorie;

  static Kategorie fromJldbRecord(KategorieApiModel record) {
    return Kategorie(id: record.id.toString(), name: record.name);
  }
}
