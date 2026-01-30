import 'package:meta/meta.dart';

import 'optional.dart';
import 'unit.dart' as type_unit;

typedef Result<S extends Object> = ResultDart<S, Exception>;
typedef VoidResult = Result<type_unit.Unit>;
typedef AsyncVoidResult = AsyncResult<type_unit.Unit>;
typedef AsyncResultDart<S extends Object, F extends Exception> =
    Future<ResultDart<S, F>>;
typedef AsyncResult<S extends Object> = Future<Result<S>>;

VoidResult voidResult() {
  return const Success<type_unit.Unit, Exception>(type_unit.unit);
}

AsyncVoidResult asyncVoidResult() async {
  return const Success<type_unit.Unit, Exception>(type_unit.unit);
}

type_unit.Unit get resultvoid => type_unit.unit;

AsyncResult<S> asyncResultFromFunction<S extends Object>(
  Future<S> Function() func,
) async {
  final S result;
  try {
    result = await func();
  } on Exception catch (e) {
    return Failure<S, Exception>(e);
  }

  assert(result is! ResultDart);
  assert(result is! Future);
  return Success<S, Exception>(result);
}

extension AsyncResultMethods<S extends Object> on AsyncResult<S> {
  Future<S> getOrThrow() async {
    final result = await this;
    return result.getOrThrow();
  }

  Future<Optional<S>> getOptional() async {
    final result = await this;
    return result.getOptional();
  }

  Future<S> getOrElse(S Function(Exception failure) onFailure) async {
    final result = await this;
    return result.getOrElse(onFailure);
  }

  Future<S> getOrDefault(S defaultValue) async {
    final result = await this;
    return result.getOrDefault(defaultValue);
  }

  Future<Optional<Exception>> getFailureOptional() async {
    final result = await this;
    return result.getFailureOptional();
  }

  Future<W> fold<W>({
    required W Function(S success) onSuccess,
    required W Function(Exception failure) onFailure,
  }) async {
    final result = await this;
    return result.fold(onSuccess: onSuccess, onFailure: onFailure);
  }

  AsyncResult<S> onSuccess(void Function(S success) action) {
    return then((result) {
      return result.onSuccess(action);
    });
  }

  AsyncResult<S> onFailure(void Function(Exception failure) action) {
    return then((result) {
      return result.onFailure(action);
    });
  }

  AsyncResult<W> map<W extends Object>(W Function(S success) transform) {
    return then((result) {
      return result.map(transform);
    });
  }

  AsyncResult<S> mapFailure<G extends Exception>(
    G Function(Exception failure) transform,
  ) {
    return then((result) {
      return result.mapFailure<G>(transform);
    });
  }

  Future<bool> isSuccess() async {
    final result = await this;
    return result.isSuccess();
  }

  Future<bool> isFailure() async {
    final result = await this;
    return result.isFailure();
  }
}

extension AsyncResultExtension<S extends Object, F extends Exception>
    on Future<S> {
  AsyncResult<S> toAsyncResult() async {
    return then(
      (S value) {
        return Success<S, F>(value);
      },
      onError: (Object error) {
        if (error is F) {
          return Failure<S, F>(error);
        } else {
          return Failure<S, F>(Exception('Unknown error: $error') as F);
        }
      },
    );
  }
}

sealed class ResultDart<S extends Object, F extends Exception> {
  bool isSuccess();

  bool isFailure();

  S getOrThrow();

  S getOrElse(S Function(F failure) onFailure);

  S getOrDefault(S defaultValue);

  Optional<S> getOptional();

  Optional<F> getFailureOptional();

  W fold<W>({
    required W Function(S success) onSuccess,
    required W Function(F failure) onFailure,
  });

  ResultDart<S, F> onSuccess(void Function(S success) action);

  ResultDart<S, F> onFailure(void Function(F failure) action);

  ResultDart<W, Exception> map<W extends Object>(
    W Function(S success) transform,
  );

  ResultDart<S, G> mapFailure<G extends Exception>(
    G Function(F failure) transform,
  );

  factory ResultDart.success(S value) => Success<S, F>(value);
  factory ResultDart.failure(F error) => Failure<S, F>(error);

  factory ResultDart.fromFunction(S Function() func) {
    try {
      final result = func();
      assert(result is! ResultDart);
      assert(result is! Future);
      return Success<S, F>(result);
    } on F catch (e) {
      return Failure<S, F>(e);
    }
  }
}

@immutable
final class Success<S extends Object, F extends Exception>
    implements ResultDart<S, F> {
  const Success(this._value);
  final S _value;

  static Success<type_unit.Unit, F> unit<F extends Exception>() =>
      Success<type_unit.Unit, F>(type_unit.unit);

  @override
  bool isSuccess() => true;

  @override
  bool isFailure() => false;

  @override
  S getOrThrow() => _value;

  @override
  S getOrElse(S Function(F failure) onFailure) => _value;

  @override
  S getOrDefault(S defaultValue) => _value;

  @override
  Optional<S> getOptional() => Optional.some(_value);

  @override
  Optional<F> getFailureOptional() => Optional.none();

  @override
  W fold<W>({
    required W Function(S success) onSuccess,
    required W Function(F failure) onFailure,
  }) {
    return onSuccess(_value);
  }

  @override
  ResultDart<S, F> onSuccess(void Function(S success) action) {
    action(_value);
    return this;
  }

  @override
  ResultDart<S, F> onFailure(void Function(F failure) action) {
    return this;
  }

  @override
  ResultDart<W, Exception> map<W extends Object>(
    W Function(S success) transform,
  ) {
    try {
      return Success<W, Exception>(transform(_value));
    } on Exception catch (e) {
      return Failure<W, Exception>(e);
    }
  }

  @override
  ResultDart<S, G> mapFailure<G extends Exception>(
    G Function(F failure) transform,
  ) {
    return Success<S, G>(_value);
  }
}

@immutable
final class Failure<S extends Object, F extends Exception>
    implements ResultDart<S, F> {
  const Failure(this._error);
  final F _error;

  @override
  bool isSuccess() => false;

  @override
  bool isFailure() => true;

  @override
  S getOrThrow() {
    throw _error;
  }

  @override
  S getOrElse(S Function(F failure) onFailure) {
    return onFailure(_error);
  }

  @override
  S getOrDefault(S defaultValue) {
    return defaultValue;
  }

  @override
  Optional<S> getOptional() => Optional.none();

  @override
  Optional<F> getFailureOptional() => Optional.some(_error);

  @override
  W fold<W>({
    required W Function(S success) onSuccess,
    required W Function(F failure) onFailure,
  }) {
    return onFailure(_error);
  }

  @override
  ResultDart<S, F> onSuccess(void Function(S success) action) {
    return this;
  }

  @override
  ResultDart<S, F> onFailure(void Function(F failure) action) {
    action(_error);
    return this;
  }

  @override
  ResultDart<W, Exception> map<W extends Object>(
    W Function(S success) transform,
  ) {
    return Failure<W, F>(_error);
  }

  @override
  ResultDart<S, G> mapFailure<G extends Exception>(
    G Function(F failure) transform,
  ) {
    try {
      return Failure<S, G>(transform(_error));
    } on Exception catch (e) {
      return Failure<S, G>(e as G);
    }
  }
}

extension FailureObjectExtension<W extends Exception> on W {
  Failure<S, W> toFailure<S extends Object>() {
    return Failure<S, W>(this);
  }
}

extension SuccessObjectExtension<S extends Object> on S {
  Success<S, F> toSuccess<F extends Exception>() {
    assert(this is! ResultDart);
    assert(this is! Future);
    return Success<S, F>(this);
  }
}
