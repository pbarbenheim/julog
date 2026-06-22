import 'package:freezed_annotation/freezed_annotation.dart';

import 'update_info.dart';

part 'update_state.freezed.dart';

@freezed
sealed class UpdateState with _$UpdateState {
  const factory UpdateState.idle() = UpdateStateIdle;
  const factory UpdateState.updateAvailable(UpdateInfo info) =
      UpdateStateUpdateAvailable;
  const factory UpdateState.downloading(double progress) =
      UpdateStateDownloading;
  const factory UpdateState.readyToInstall({
    required String installerPath,
    required UpdateInfo info,
  }) = UpdateStateReadyToInstall;
  const factory UpdateState.error(String message) = UpdateStateError;
}
