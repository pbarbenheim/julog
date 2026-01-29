import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

part 'julog_file.freezed.dart';

@freezed
sealed class JulogFile with _$JulogFile {
  const factory JulogFile.none() = JulogFileNone;
  const factory JulogFile.loaded({required Jldb jldb}) = JulogFileLoaded;
  const factory JulogFile.loading() = JulogFileLoading;
  const factory JulogFile.closed() = JulogFileClosed;
}
