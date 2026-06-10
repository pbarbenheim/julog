import 'models/eintrag/eintrag_api_model.dart';
import 'models/jugendlicher/jugendlicher_api_model.dart';

class AttendancePoint {
  const AttendancePoint({required this.date, required this.attendanceRate});

  final DateTime date;
  final double attendanceRate;
}

class AttendanceRateCalculator {
  static List<AttendancePoint> calculate(
    List<EintragApiModel> eintraege,
    List<JugendlicherApiModel> jugendliche,
  ) {
    final sorted = [...eintraege]..sort((a, b) => b.start.compareTo(a.start));
    final trimmed = sorted.take(20).toList();

    return trimmed.map((eintrag) {
      final eintragDate = eintrag.start;

      final aktivCount = jugendliche.where((j) {
        if (j.replacedById != null) return false;
        if (j.exitDate != null && j.exitDate!.isBefore(eintragDate)) {
          return false;
        }
        return true;
      }).length;

      if (aktivCount == 0)
        return AttendancePoint(date: eintragDate, attendanceRate: 0.0);

      final anwesendeCount = eintrag.anwesendeJugendlicherIds.length;
      return AttendancePoint(
        date: eintragDate,
        attendanceRate: anwesendeCount / aktivCount,
      );
    }).toList();
  }
}
