import 'package:test/test.dart';
import 'package:jldb/jldb.dart';

void main() {
  group('Test JLDB', () {
    late Jldb jldb;
    setUp(() async {
      jldb = await Jldb.create(':memory:', domain: 'example.org').getOrThrow();
    });

    test('Basic Insertion and Retrieval', () async {
      final betreuer = BetreuerApiModel(
        id: UUID.generate(),
        name: 'John Doe',
        sex: Sex.male,
      );
      final newBetreuer = await jldb.createBetreuer(betreuer).getOrThrow();
      expect(newBetreuer.id, equals(betreuer.id));

      final fetchedBetreuer = await jldb.getBetreuer(betreuer.id).getOrThrow();
      expect(fetchedBetreuer.isSome(), isTrue);
      expect(fetchedBetreuer.unwrap(), equals(betreuer));
      await jldb.createBetreuer(
        BetreuerApiModel(id: UUID.generate(), name: 'Test', sex: Sex.diverse),
      );
      final allBetreuer = await jldb.getAllBetreuer().getOrThrow();
      expect(allBetreuer.length, equals(2));

      //TODO needs more testing
    });

    tearDown(() async {
      await jldb.close();
    });
  });
}
