import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:julog/service/log_file_handler.dart';

void main() {
  group('LogFileHandler', () {
    late Directory tempDir;
    late String filePath;
    late LogFileHandler handler;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('log_file_handler_test_');
      filePath = '${tempDir.path}/test.log';
      handler = LogFileHandler(filePath: filePath, maxEntries: 100);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    LogRecord makeRecord(String message) =>
        LogRecord(Level.INFO, message, 'test');

    test('writes file after first log entry', () {
      handler.addRecord(makeRecord('first'));

      expect(File(filePath).existsSync(), isTrue);
      final content = File(filePath).readAsStringSync();
      expect(content, contains('first'));
    });

    test('contains all entries up to maxEntries', () {
      for (var i = 0; i < 100; i++) {
        handler.addRecord(makeRecord('msg-$i'));
      }

      final lines = File(
        filePath,
      ).readAsStringSync().split('\n').where((l) => l.isNotEmpty).toList();
      expect(lines, hasLength(100));
      expect(lines.last, contains('msg-99'));
    });

    test('rolling buffer: after 101 entries only 100 remain', () {
      for (var i = 0; i < 101; i++) {
        handler.addRecord(makeRecord('msg-$i'));
      }

      final lines = File(
        filePath,
      ).readAsStringSync().split('\n').where((l) => l.isNotEmpty).toList();
      expect(lines, hasLength(100));
      expect(lines.first, contains('msg-1'));
      expect(lines.last, contains('msg-100'));
    });

    test('oldest entry is dropped when buffer overflows', () {
      for (var i = 0; i < 105; i++) {
        handler.addRecord(makeRecord('entry-$i'));
      }

      final lines = File(
        filePath,
      ).readAsStringSync().split('\n').where((l) => l.isNotEmpty).toList();
      // Buffer holds entry-5..entry-104; entry-0..entry-4 are evicted.
      expect(lines.first, endsWith(': entry-5'));
      expect(lines.last, endsWith(': entry-104'));
      expect(lines.any((l) => l.endsWith(': entry-0')), isFalse);
      expect(lines.any((l) => l.endsWith(': entry-4')), isFalse);
    });

    test('log record includes timestamp, level, logger name, and message', () {
      handler.addRecord(makeRecord('hello world'));

      final content = File(filePath).readAsStringSync();
      expect(content, contains('INFO'));
      expect(content, contains('test'));
      expect(content, contains('hello world'));
    });

    test('log record with stack trace includes stack trace', () {
      final record = LogRecord(
        Level.SEVERE,
        'boom',
        'test',
        null,
        StackTrace.current,
      );
      handler.addRecord(record);

      final content = File(filePath).readAsStringSync();
      expect(content, contains('boom'));
      expect(content, contains('#0'));
    });
  });
}
