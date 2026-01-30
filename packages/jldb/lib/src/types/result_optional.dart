import 'optional.dart';
import 'result.dart';

extension ResultOptionalMethods<S extends Object> on Result<Optional<S>> {
  Result<Optional<W>> mapOptional<W extends Object>(
    W Function(S value) transform,
  ) {
    return map((optional) {
      return optional.map(transform);
    });
  }
}

extension AsyncResultOptionalMethods<S extends Object>
    on AsyncResult<Optional<S>> {
  AsyncResult<Optional<W>> mapOptional<W extends Object>(
    W Function(S value) transform,
  ) {
    return then((result) {
      return result.mapOptional(transform);
    });
  }
}
