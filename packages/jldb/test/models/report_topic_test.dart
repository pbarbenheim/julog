import 'package:jldb/src/models/report_topic.dart';
import 'package:test/test.dart';

void main() {
  group('ReportTopic', () {
    test('enum has exactly 7 variants', () {
      expect(ReportTopic.values.length, equals(7));
    });

    test('toInt() follows the Arbeit_Wert_01..07 order starting at 0', () {
      expect(ReportTopic.feuerwehrtechnik.toInt(), equals(0));
      expect(ReportTopic.wettbewerbstraining.toInt(), equals(1));
      expect(ReportTopic.spieleUndKreatives.toInt(), equals(2));
      expect(ReportTopic.mitAnderemVereinOderGruppe.toInt(), equals(3));
      expect(ReportTopic.sport.toInt(), equals(4));
      expect(ReportTopic.ersteHilfeUndPraevention.toInt(), equals(5));
      expect(ReportTopic.sonstiges.toInt(), equals(6));
    });

    test('fromInt() is the inverse of toInt() for every value', () {
      for (final t in ReportTopic.values) {
        expect(ReportTopic.fromInt(t.toInt()), equals(t));
      }
    });

    test('fromInt() throws ArgumentError for -1 and 7', () {
      expect(() => ReportTopic.fromInt(-1), throwsArgumentError);
      expect(() => ReportTopic.fromInt(7), throwsArgumentError);
    });
  });
}
