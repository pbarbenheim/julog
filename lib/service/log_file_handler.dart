import 'dart:io';

import 'package:logging/logging.dart';

class LogFileHandler {
  final String filePath;
  final int _maxEntries;
  final _buffer = <LogRecord>[];

  LogFileHandler({required this.filePath, int maxEntries = 100})
    : _maxEntries = maxEntries;

  void listen() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(_onRecord);
  }

  void addRecord(LogRecord record) => _onRecord(record);

  void _onRecord(LogRecord record) {
    if (_buffer.length >= _maxEntries) {
      _buffer.removeAt(0);
    }
    _buffer.add(record);
    _flush();
  }

  void _flush() {
    final content = _buffer.map(_formatRecord).join('\n');
    File(filePath).writeAsStringSync('$content\n');
  }

  String _formatRecord(LogRecord r) {
    final sb = StringBuffer()
      ..write(r.time.toIso8601String())
      ..write(' ')
      ..write(r.level.name)
      ..write(' ')
      ..write(r.loggerName)
      ..write(': ')
      ..write(r.message);
    if (r.stackTrace != null) {
      sb
        ..write('\n')
        ..write(r.stackTrace);
    }
    return sb.toString();
  }
}
