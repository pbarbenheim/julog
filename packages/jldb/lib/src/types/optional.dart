import 'package:meta/meta.dart';

sealed class Optional<T extends Object> {
  bool isSome();
  bool isNone();
  T unwrap();
  T? unsafe();

  Optional<W> map<W extends Object>(W Function(T value) transform);

  W fold<W>({
    required W Function(T value) onSome,
    required W Function() onNone,
  });

  factory Optional.some(T value) => Some<T>(value);
  factory Optional.none() => None<T>();
}

@immutable
final class Some<T extends Object> implements Optional<T> {
  const Some(this._value);

  final T _value;

  @override
  bool isSome() => true;

  @override
  bool isNone() => false;

  @override
  T unwrap() => _value;

  @override
  T? unsafe() => _value;

  @override
  Optional<W> map<W extends Object>(W Function(T value) transform) {
    return transform(_value).toOptional();
  }

  @override
  W fold<W>({
    required W Function(T value) onSome,
    required W Function() onNone,
  }) {
    return onSome(_value);
  }
}

@immutable
final class None<T extends Object> implements Optional<T> {
  const None();

  @override
  bool isSome() => false;

  @override
  bool isNone() => true;

  @override
  T unwrap() {
    throw StateError('Called unwrap on None');
  }

  @override
  T? unsafe() => null;

  @override
  Optional<W> map<W extends Object>(W Function(T value) transform) {
    return None<W>();
  }

  @override
  W fold<W>({
    required W Function(T value) onSome,
    required W Function() onNone,
  }) {
    return onNone();
  }
}

extension OptionalExtension<T extends Object> on T? {
  Optional<T> toOptional() {
    final value = this;
    if (value == null) {
      return None<T>();
    } else {
      return Some<T>(value);
    }
  }
}
