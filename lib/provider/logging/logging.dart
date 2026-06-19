import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../service/log_file_handler.dart';

part 'logging.g.dart';

@Riverpod(keepAlive: true)
String loggingService(Ref ref) => throw UnimplementedError();

Future<String> initLoggingService() async {
  final dir = await getApplicationSupportDirectory();
  final filePath = '${dir.path}/julog.log';
  final handler = LogFileHandler(filePath: filePath);
  handler.listen();
  return filePath;
}
