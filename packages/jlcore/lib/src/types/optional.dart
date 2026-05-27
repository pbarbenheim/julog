import 'dart:async';

import 'package:meta/meta.dart';

sealed class Optional<T extends Object> {
  const Optional._();

  T unwrap();
  T? unsafe();

  Optional<W> map<W extends Object>(W Function(T value) transform);

  factory Optional.some(T value) => Some<T>(value);
  factory Optional.none() => None<T>();
  factory Optional.fromNullable(T? value) =>
      value != null ? Some<T>(value) : None<T>();

  static AsyncOptional<W> fromFuture<W extends Object>(Future<W?> value) =>
      value.then((v) => Optional.fromNullable(v));
  static AsyncOptional<W> fromAsync<W extends Object>(
    FutureOr<W?> Function() fn,
  ) async => Optional.fromNullable(await fn());
}

@immutable
final class Some<T extends Object> extends Optional<T> {
  final T _value;
  Some(this._value) : super._();

  @override
  Optional<W> map<W extends Object>(W Function(T value) transform) {
    return Some<W>(transform(_value));
  }

  @override
  T? unsafe() {
    return _value;
  }

  @override
  T unwrap() {
    return _value;
  }

  T get value {
    return _value;
  }
}

@immutable
final class None<T extends Object> extends Optional<T> {
  const None() : super._();

  @override
  Optional<W> map<W extends Object>(W Function(T value) transform) => None<W>();

  @override
  T? unsafe() => null;

  @override
  T unwrap() => throw StateError('No value present');
}

class OptionalHasNoValueException implements Exception {
  @override
  String toString() => 'Optional has no value';
}

typedef AsyncOptional<T extends Object> = Future<Optional<T>>;

extension AsyncOptionalMethods<T extends Object> on AsyncOptional<T> {
  Future<T> unwrap() async => then((optional) => optional.unwrap());
  Future<T?> unsafe() async => then((optional) => optional.unsafe());
  AsyncOptional<W> map<W extends Object>(W Function(T value) transform) async =>
      then((optional) => optional.map(transform));
}
