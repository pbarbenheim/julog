import 'dart:async';
import 'dart:isolate';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mutex/mutex.dart';
import 'package:sqlite3/sqlite3.dart';

@internal
class SqliteWorker {
  final ReadWriteMutex _mutex = ReadWriteMutex();
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _pendingRequests = {};
  int _idCounter = 0;
  bool _closed = false;
  final Isolate _isolate;

  SqliteWorker._(this._commands, this._responses, this._isolate) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  static Future<SqliteWorker> spawn(
    String filename, {
    bool createDatabase = true,
  }) async {
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    final Isolate isolate;
    // Spawn the isolate
    try {
      isolate = await Isolate.spawn(_startRemoteIsolate, (
        initPort.sendPort,
        (filename, createDatabase),
      ), errorsAreFatal: true);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (responses, commands) = await connection.future;

    return SqliteWorker._(commands, responses, isolate);
  }

  Future<void> close() async {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_pendingRequests.isEmpty) {
        _responses.close();
      }
      Future.delayed(const Duration(seconds: 1));
      _isolate.kill(priority: Isolate.beforeNextEvent);
    }
  }

  void _notClosedGuard() {
    if (_closed) {
      throw StateError(
        'Database worker is closed. The resource is no longer available.',
      );
    }
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, Object? result) = message as (int, Object?);
    final completer = _pendingRequests.remove(id);

    if (completer == null) {
      throw StateError('Received response for unknown request id $id');
    }

    if (result is RemoteError) {
      completer.completeError(result, result.stackTrace);
    } else {
      completer.complete(result);
    }

    if (_closed && _pendingRequests.isEmpty) {
      _responses.close();
    }
  }

  static void _handleCommandsToIsolate(
    ReceivePort rp,
    SendPort sp,
    (String, bool) args,
  ) {
    final mode = args.$2 ? OpenMode.readWriteCreate : OpenMode.readWrite;
    final Database db = sqlite3.open(args.$1, mode: mode, mutex: true);

    final Map<int, PreparedStatement> preparedStatements = {};
    int statementCounter = 0;
    rp.listen((message) {
      if (message == 'shutdown') {
        db.close();
        rp.close();
        return;
      }

      final (int id, String command, dynamic args) = message;

      try {
        if (command == 'execute') {
          final (String sql, List<Object?> parameters) = args;
          db.execute(sql, parameters);

          sp.send((id, null));
          return;
        }

        if (command == 'select') {
          final (String sql, List<Object?> parameters) = args;
          final res = db.select(sql, parameters);
          final result = res.rows;
          sp.send((id, result));
          return;
        }

        if (command == 'prepare') {
          final (String sql, bool peristent, bool vtab, bool checkNoTail) =
              args;
          final stmt = db.prepare(sql);
          final int stmtId = statementCounter++;
          preparedStatements[stmtId] = stmt;
          sp.send((id, stmtId));
          return;
        }

        if (command == 'close_statement') {
          final int stmtId = args as int;
          final stmt = preparedStatements.remove(stmtId);
          stmt?.close();
          sp.send((id, null));
          return;
        }

        if (command == 'execute_statement') {
          final (int stmtId, List<Object?> parameters) = args;
          final stmt = preparedStatements[stmtId];
          stmt?.execute(parameters);
          sp.send((id, null));
          return;
        }

        if (command == 'select_statement') {
          final (int stmtId, List<Object?> parameters) = args;
          final stmt = preparedStatements[stmtId];
          final result = stmt?.select(parameters).rows;
          sp.send((id, result));
          return;
        }

        throw UnsupportedError('Unknown command: $command');
      } catch (e) {
        sp.send((id, RemoteError(e.toString(), '')));
      }
    });
  }

  static void _startRemoteIsolate(dynamic message) {
    final (SendPort sp, args) = message as (SendPort, (String, bool));
    final receivePort = ReceivePort();
    _handleCommandsToIsolate(receivePort, sp, args);
    sp.send(receivePort.sendPort);
  }

  Future<void> execute(
    String sql, [
    List<Object?>? parameters = const [],
  ]) async {
    _notClosedGuard();
    return await _mutex.protectRead(() async {
      final completer = Completer<void>.sync();
      final id = _idCounter++;
      _pendingRequests[id] = completer;

      _commands.send((id, 'execute', (sql, parameters)));

      await completer.future;
    });
  }

  Future<List<List<Object?>>> select(
    String sql, [
    List<Object?>? parameters = const [],
  ]) async {
    _notClosedGuard();
    return await _mutex.protectRead(() async {
      final completer = Completer<Object>.sync();
      final id = _idCounter++;
      _pendingRequests[id] = completer;

      _commands.send((id, 'select', (sql, parameters)));

      return await completer.future as List<List<Object?>>;
    });
  }

  Future<dynamic> _rawCommand((String, dynamic) command) async {
    _notClosedGuard();
    final completer = Completer<dynamic>.sync();
    final id = _idCounter++;
    _pendingRequests[id] = completer;

    _commands.send((id, command.$1, command.$2));

    return await completer.future;
  }

  Future<WorkerStatement> prepare(
    String sql, {
    bool peristent = false,
    bool vtab = true,
    bool checkNoTail = false,
  }) async {
    _notClosedGuard();
    return await _mutex.protectRead(() async {
      final completer = Completer<Object>.sync();
      final id = _idCounter++;
      _pendingRequests[id] = completer;

      _commands.send((id, 'prepare', (sql, peristent, vtab, checkNoTail)));

      final int stmntId = await completer.future as int;
      return WorkerStatement._(stmntId, (message) async {
        return await _mutex.protectRead(() async {
          return await _rawCommand(message);
        });
      });
    });
  }

  Future<T> transaction<T>(
    Future<T> Function(TransactionConnection connection) action,
  ) async {
    _notClosedGuard();
    return await _mutex.protectWrite<T>(() async {
      await _rawCommand(('execute', ('BEGIN TRANSACTION;', [])));
      try {
        final connection = TransactionConnection((message) async {
          return await _rawCommand(message);
        });
        final result = await action(connection);
        await _rawCommand(('execute', ('COMMIT;', [])));
        return result;
      } catch (e) {
        await _rawCommand(('execute', ('ROLLBACK;', [])));
        rethrow;
      }
    });
  }
}

final class WorkerStatement {
  final int id;
  Future<Object?> Function((String, dynamic) message) sendMessage;

  WorkerStatement._(this.id, this.sendMessage);

  Future<void> execute([List<Object?>? parameters = const []]) async {
    await sendMessage(('execute_statement', (id, parameters)));
  }

  Future<List<List<Object?>>> select([
    List<Object?>? parameters = const [],
  ]) async {
    final result = await sendMessage(('select_statement', (id, parameters)));
    return result as List<List<Object?>>;
  }

  Future<void> close() async {
    await sendMessage(('close_statement', id));
  }
}

final class TransactionConnection {
  final Future<Object?> Function((String, dynamic) message) sendMessage;

  TransactionConnection(this.sendMessage);

  Future<void> execute(
    String sql, [
    List<Object?>? parameters = const [],
  ]) async {
    await sendMessage(('execute', (sql, parameters)));
  }

  Future<List<List<Object?>>> select(
    String sql, [
    List<Object?>? parameters = const [],
  ]) async {
    final result = await sendMessage(('select', (sql, parameters)));
    return result as List<List<Object?>>;
  }
}
