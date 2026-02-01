import 'dart:async';

import 'package:meta/meta.dart';

import 'optional.dart';
import 'unit.dart' as type_unit;

sealed class ResultDart<S extends Object, F extends Exception> {
  S unwrap();
  S getOrElse(S Function(F failure) onFailure);
  S getOrDefault(S defaultValue);

  F unwrapFailure();

  ResultDart<W, Exception> when<W extends Object>(
    W Function(S value) onSuccess,
    Exception Function(F error)? onFailure,
  );

  ResultDart<W, Exception> map<W extends Object>(
    W Function(S value) transform,
  ) => when(transform, null);

  const ResultDart._();

  const factory ResultDart.success(S value) = SuccessDart<S, F>;
  const factory ResultDart.failure(F error) = FailureDart<S, F>;

  static Result<W> safe<W extends Object>(W Function() fn) {
    try {
      final value = fn();
      return Success<W>(value);
    } on Exception catch (e) {
      return Failure<W>(e);
    }
  }

  static Result<type_unit.Unit> voidSafe(void Function() fn) {
    try {
      fn();
      return const Success<type_unit.Unit>(type_unit.unit);
    } on Exception catch (e) {
      return Failure<type_unit.Unit>(e);
    }
  }

  static AsyncResult<W> safeAsync<W extends Object>(
    FutureOr<W> Function() fn,
  ) async {
    try {
      final value = await fn();
      return Success<W>(value);
    } on Exception catch (e) {
      return Failure<W>(e);
    }
  }

  static AsyncVoidResult voidSafeAsync(Future<void> Function() fn) async {
    try {
      await fn();
      return const Success<type_unit.Unit>(type_unit.unit);
    } on Exception catch (e) {
      return Failure<type_unit.Unit>(e);
    }
  }

  static ResultOptional<S> safeNullable<S extends Object>(S? Function() fn) {
    try {
      final value = fn();
      return ResultOptional<S>.success(Optional<S>.fromNullable(value));
    } on Exception catch (e) {
      return ResultOptional<S>.failure(e);
    }
  }

  static AsyncResultOptional<S> safeNullableAsync<S extends Object>(
    FutureOr<S?> Function() fn,
  ) async {
    try {
      final value = await fn();
      return ResultOptional<S>.success(Optional<S>.fromNullable(value));
    } on Exception catch (e) {
      return ResultOptional<S>.failure(e);
    }
  }
}

@immutable
final class SuccessDart<S extends Object, F extends Exception>
    extends ResultDart<S, F> {
  final S _value;

  const SuccessDart(this._value) : super._();

  @override
  S unwrap() {
    return _value;
  }

  S get value => _value;

  @override
  S getOrDefault(S defaultValue) => _value;

  @override
  S getOrElse(S Function(F failure) onFailure) => _value;

  @override
  ResultDart<W, Exception> when<W extends Object>(
    W Function(S value) onSuccess,
    Exception Function(F error)? onFailure,
  ) {
    try {
      final value = onSuccess(_value);
      return SuccessDart<W, Exception>(value);
    } on Exception catch (e) {
      return FailureDart<W, Exception>(e);
    }
  }

  @override
  F unwrapFailure() {
    throw StateError('Cannot unwrap failure from Success');
  }
}

@immutable
final class FailureDart<S extends Object, F extends Exception>
    extends ResultDart<S, F> {
  final F _error;

  const FailureDart(this._error) : super._();

  F get error => _error;

  @override
  S unwrap() {
    throw _error;
  }

  @override
  S getOrDefault(S defaultValue) => defaultValue;

  @override
  S getOrElse(S Function(F failure) onFailure) => onFailure(_error);

  @override
  ResultDart<W, Exception> when<W extends Object>(
    W Function(S value) onSuccess,
    Exception Function(F error)? onFailure,
  ) {
    if (onFailure != null) {
      try {
        final value = onFailure(_error);
        return FailureDart<W, Exception>(value);
      } on Exception catch (e) {
        return FailureDart<W, Exception>(e);
      }
    } else {
      return FailureDart<W, Exception>(_error);
    }
  }

  @override
  F unwrapFailure() => _error;
}

typedef Result<S extends Object> = ResultDart<S, Exception>;
typedef Success<S extends Object> = SuccessDart<S, Exception>;
typedef Failure<S extends Object> = FailureDart<S, Exception>;

typedef VoidResult = ResultDart<type_unit.Unit, Exception>;
typedef VoidSuccess = SuccessDart<type_unit.Unit, Exception>;
typedef VoidFailure = FailureDart<type_unit.Unit, Exception>;

typedef AsyncVoidResult = AsyncResult<type_unit.Unit>;
typedef AsyncResultDart<S extends Object, F extends Exception> =
    Future<ResultDart<S, F>>;
typedef AsyncResult<S extends Object> = Future<Result<S>>;

extension AsyncResultMethods<S extends Object, F extends Exception>
    on AsyncResultDart<S, F> {
  Future<S> unwrap() async => then((result) => result.unwrap());

  Future<S> getOrDefault(S defaultValue) async =>
      then((result) => result.getOrDefault(defaultValue));

  Future<S> getOrElse(S Function(F failure) onFailure) async =>
      then((result) => result.getOrElse(onFailure));

  AsyncResultDart<W, Exception> when<W extends Object>(
    W Function(S value) onSuccess,
    F Function(F error)? onFailure,
  ) async => then((result) => result.when(onSuccess, onFailure));

  AsyncResultDart<W, Exception> map<W extends Object>(
    W Function(S value) transform,
  ) async => then((result) => result.map(transform));
}

T identity<T>(T value) => value;

typedef ResultOptional<S extends Object> = Result<Optional<S>>;
typedef AsyncResultOptional<S extends Object> = AsyncResult<Optional<S>>;

extension ResultOptionalMethods<S extends Object, F extends Exception>
    on ResultOptional<S> {
  S unwrapAll() {
    final optional = unwrap();
    return optional.unwrap();
  }
}

extension AsyncResultOptionalMethods<S extends Object, F extends Exception>
    on AsyncResultOptional<S> {
  Future<S> unwrapAll() async {
    final result = await this;
    final optional = result.unwrap();
    return optional.unwrap();
  }
}
