import 'package:test/test.dart';
import 'package:jldb/jldb.dart';

void main() {
  group('Test JLDB', () {
    late Jldb jldb;
    setUp(() async {
      jldb = await Jldb.create(':memory:', domain: 'example.org').unwrap();
    });

    test('Basic Insertion and Retrieval', () async {
      final betreuer = BetreuerApiModel(
        id: UUID.generate(),
        name: 'John Doe',
        sex: Sex.male,
      );
      final newBetreuer = await jldb.createBetreuer(betreuer).unwrap();
      expect(newBetreuer.id, equals(betreuer.id));

      final fetchedBetreuer = await jldb.getBetreuer(betreuer.id).unwrap();
      expect(fetchedBetreuer is Some, isTrue);
      expect(fetchedBetreuer.unwrap(), equals(betreuer));
      await jldb.createBetreuer(
        BetreuerApiModel(id: UUID.generate(), name: 'Test', sex: Sex.diverse),
      );
      final allBetreuer = await jldb.getAllBetreuer().unwrap();
      expect(allBetreuer.length, equals(2));

      //TODO needs more testing
    });

    tearDown(() async {
      await jldb.close();
    });
  });
}
