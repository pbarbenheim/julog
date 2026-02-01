import 'dart:async';

import 'package:jldb/jldb.dart';
import 'package:meta/meta.dart';

abstract class JulogRepository<
  ModelType extends Object,
  ApiType extends Object,
  SaveType extends Object
> {
  @protected
  final Map<String, Optional<ModelType>> cache = {};
  bool _cacheSynced = false;

  JulogRepository();

  AsyncResult<List<ModelType>> getAll() {
    return Result.safeAsync(() async {
      if (_cacheSynced) {
        return cache.values
            .whereType<Some<ModelType>>()
            .map((e) => e.unwrap())
            .toList();
      }
      final result = await fetchAllFromJldb();
      if (result is Failure<List<ApiType>>) {
        throw result.error;
      }
      final records = result.unwrap();
      final List<ModelType> itemList = [];
      for (var record in records) {
        final item = await fromJldbRecord(record);
        cache[getId(item)] = Some(item);
        itemList.add(item);
      }
      _cacheSynced = true;
      return itemList;
    });
  }

  AsyncResult<Optional<ModelType>> getById(String id) async {
    if (!_cacheSynced) {
      final allResult = await getAll();
      if (allResult is Failure<List<ModelType>>) {
        return Failure(allResult.error);
      }
    }
    if (cache.containsKey(id)) {
      return Success(cache[id]!);
    } else {
      return Success(None<ModelType>());
    }
  }

  AsyncResult<ModelType> save(SaveType data) async {
    final result = await createInJldb(data);
    if (result is Success<ModelType>) {
      final item = result.unwrap();
      cache[getId(item)] = Some(item);
    }
    return result;
  }

  @visibleForOverriding
  AsyncResult<ModelType> createInJldb(SaveType data);

  @visibleForOverriding
  AsyncResult<List<ApiType>> fetchAllFromJldb();

  @visibleForOverriding
  FutureOr<ModelType> fromJldbRecord(ApiType record);

  @visibleForOverriding
  String getId(ModelType item);
}
