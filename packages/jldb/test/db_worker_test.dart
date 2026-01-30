import 'dart:async';

import 'package:test/test.dart';
import 'package:jldb/src/database/sqlite_worker.dart';

void main() {
  group('Test the database worker', () {
    late SqliteWorker database;
    setUp(() async {
      database = await SqliteWorker.spawn(':memory:');
    });

    test('Basic Statements', () async {
      await database.execute(
        'CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT);',
      );
      await database.execute(
        "INSERT INTO test (id, name) VALUES (1, 'Alice'), (2, 'Bob');",
      );
      final results = await database.select('SELECT * FROM test;');
      expect(results.length, equals(2));
      final alice = results.first[1];
      expect(alice, equals('Alice'));
      expect(results.first.first, equals(1));
      database.close();
    });

    test('Prepared Statements', () async {
      final statement = await database.prepare(
        'CREATE TABLE test2 (id INTEGER PRIMARY KEY, value TEXT);',
      );
      await statement.execute();
      final insertStatement = await database.prepare(
        'INSERT INTO test2 (id, value) VALUES (?, ?);',
      );
      await insertStatement.execute([1, 'First']);
      await insertStatement.execute([2, 'Second']);
      final selectStatement = await database.prepare(
        'SELECT * FROM test2 WHERE id = ?;',
      );
      final result1 = await selectStatement.select([1]);
      expect(result1.length, equals(1));
      expect(result1.first[1], equals('First'));
      final result2 = await selectStatement.select([2]);
      expect(result2.length, equals(1));
      expect(result2.first[1], equals('Second'));
      database.close();
    });

    test('Mutex transaction test', () async {
      await database.execute(
        'CREATE TABLE test3 (id INTEGER PRIMARY KEY, name TEXT);',
      );
      await database.execute(
        "INSERT INTO test3 (id, name) VALUES (1, 'Alice'), (2, 'Bob');",
      );
      final raceCompleter = Completer<void>();
      final selectPrep = await database.prepare('select * from test3;');
      final transactionFuture = database.transaction((conn) async {
        await conn.execute(
          "INSERT INTO test3 (id, name) VALUES (3, 'Charlie');",
        );
        await raceCompleter.future;
        await Future.delayed(const Duration(seconds: 5));
        return await conn.select('select * from test3;');
      });
      final selectFuture = selectPrep.select();
      raceCompleter.complete();
      final transactionResult = await transactionFuture;
      final selectResult = await selectFuture;
      expect(selectResult.length, equals(3));
      expect(transactionResult.length, equals(3));
    });

    tearDown(() {
      database.close();
    });
  });
}
