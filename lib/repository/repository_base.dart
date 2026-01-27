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

  AsyncResult<List<ModelType>> getAll() async {
    if (_cacheSynced) {
      return cache.values
          .whereType<Some<ModelType>>()
          .map((e) => e.unwrap())
          .toList()
          .toSuccess();
    }
    final result = await fetchAllFromJldb();
    if (result.isFailure()) {
      return result.getFailureOptional().unwrap().toFailure();
    }
    final records = result.getOrThrow();
    final List<ModelType> itemList = [];
    for (var record in records) {
      final item = await fromJldbRecord(record);
      cache[getId(item)] = item.toOptional();
      itemList.add(item);
    }
    _cacheSynced = true;
    return itemList.toSuccess();
  }

  AsyncResult<ModelType> save(SaveType data) async {
    final result = await createInJldb(data);
    if (result.isSuccess()) {
      final item = result.getOrThrow();
      cache[getId(item)] = item.toOptional();
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
