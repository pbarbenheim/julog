import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/shared_pref/shared_pref.dart';
import '../pubspec.g.dart';
import 'update_info.dart';
import 'update_state.dart';

part 'update_service.g.dart';

@Riverpod(keepAlive: true)
class UpdateService extends _$UpdateService {
  static const String _lastCheckedKey = 'update_last_checked';
  static const int _rateLimitMs = 24 * 60 * 60 * 1000;
  static const String _apiUrl =
      'https://api.github.com/repos/pbarbenheim/julog/releases/latest';
  static const String _releasesPageUrl =
      'https://github.com/pbarbenheim/julog/releases/latest';
  static const String _windowsAssetName = 'julog-windows-x64-setup.exe';

  @override
  Future<UpdateState> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return _checkWithRateLimit(prefs);
  }

  Future<void> checkForUpdate() async {
    state = const AsyncLoading();
    final prefs = ref.read(sharedPreferencesProvider);
    state = AsyncData(await _performCheck(prefs));
  }

  Future<void> startDownload(UpdateInfo info) async {
    if (!Platform.isWindows || info.downloadUrl == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}julog_update_${info.version}.exe',
    );

    // Re-use a previously downloaded installer if still present
    if (file.existsSync()) {
      state = AsyncData(
        UpdateState.readyToInstall(installerPath: file.path, info: info),
      );
      return;
    }

    state = const AsyncData(UpdateState.downloading(0));
    final client = http.Client();
    try {
      final response = await client.send(
        http.Request('GET', Uri.parse(info.downloadUrl!)),
      );
      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      int received = 0;
      await response.stream
          .map((chunk) {
            received += chunk.length;
            if (contentLength > 0) {
              state = AsyncData(
                UpdateState.downloading(received / contentLength),
              );
            }
            return chunk;
          })
          .pipe(sink);
      await sink.flush();
      await sink.close();
      state = AsyncData(
        UpdateState.readyToInstall(installerPath: file.path, info: info),
      );
    } catch (_) {
      state = const AsyncData(UpdateState.error('Download fehlgeschlagen'));
    } finally {
      client.close();
    }
  }

  Future<void> install(String installerPath) async {
    await Process.start(installerPath, [
      '/SILENT',
      '/SUPPRESSMSGBOXES',
      '/NORESTART',
    ], mode: ProcessStartMode.detached);
    exit(0);
  }

  void openReleasesPage() {
    if (Platform.isLinux) Process.start('xdg-open', [_releasesPageUrl]);
    if (Platform.isMacOS) Process.start('open', [_releasesPageUrl]);
  }

  void resetToUpdateAvailable(UpdateInfo info) {
    state = AsyncData(UpdateState.updateAvailable(info));
  }

  Future<UpdateState> _checkWithRateLimit(
    SharedPreferencesWithCache prefs,
  ) async {
    final lastChecked = prefs.getInt(_lastCheckedKey);
    if (lastChecked != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastChecked;
      if (elapsed < _rateLimitMs) return const UpdateState.idle();
    }
    return _performCheck(prefs);
  }

  Future<UpdateState> _performCheck(SharedPreferencesWithCache prefs) async {
    try {
      final info = await _fetchLatestRelease();
      await prefs.setInt(
        _lastCheckedKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (info == null) return const UpdateState.idle();
      return UpdateState.updateAvailable(info);
    } catch (_) {
      return const UpdateState.idle();
    }
  }

  Future<UpdateInfo?> _fetchLatestRelease() async {
    final response = await http
        .get(
          Uri.parse(_apiUrl),
          headers: {'Accept': 'application/vnd.github+json'},
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String? ?? '';
    if (!_isNewer(tagName)) return null;

    final version = tagName.replaceFirst('v', '');
    final releaseNotes = json['body'] as String?;

    String? downloadUrl;
    if (Platform.isWindows) {
      final assets = json['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        if (asset is Map<String, dynamic> &&
            asset['name'] == _windowsAssetName) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }
    }

    return UpdateInfo(
      version: version,
      tagName: tagName,
      downloadUrl: downloadUrl,
      releaseNotes: releaseNotes,
    );
  }

  bool _isNewer(String tagName) {
    final parts = tagName
        .replaceFirst('v', '')
        .split('.')
        .map(int.tryParse)
        .toList();
    if (parts.length < 3 || parts.any((e) => e == null)) return false;
    final major = parts[0]!;
    final minor = parts[1]!;
    final patch = parts[2]!;
    if (major != Pubspec.versionMajor) return major > Pubspec.versionMajor;
    if (minor != Pubspec.versionMinor) return minor > Pubspec.versionMinor;
    return patch > Pubspec.versionPatch;
  }
}
