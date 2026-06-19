import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/jugendliche/repository.dart';
import '../../repository/kategorie/repository.dart';
import '../../repository/model/model.dart';
import '../../repository/repository_base.dart';

part 'dashboard_viewmodel.g.dart';
part 'dashboard_viewmodel.freezed.dart';

@freezed
abstract class LastEintragSummary with _$LastEintragSummary {
  const factory LastEintragSummary({
    required String kategorieName,
    required String formattedDate,
    required String thema,
    required String anwesenheitDisplay,
  }) = _LastEintragSummary;
}

@freezed
abstract class BirthdayEntry with _$BirthdayEntry {
  const factory BirthdayEntry({
    required String name,
    required DateTime birthDate,
  }) = _BirthdayEntry;
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required int aktivCount,
    LastEintragSummary? lastEintrag,
    required List<BirthdayEntry> recentBirthdays,
    required List<AttendancePoint> attendanceChart,
  }) = _DashboardData;
}

class DashboardViewModel {
  final JulogRepository<
    Jugendlicher,
    JugendlicherApiModel,
    JugendlicheCreateData
  >
  _jugendlicheRepo;
  final JulogRepository<Eintrag, EintragApiModel, EintragCreateData>
  _eintragRepo;
  final JulogRepository<Kategorie, KategorieApiModel, KategorieCreate>
  _kategorieRepo;

  const DashboardViewModel({
    required JulogRepository<
      Jugendlicher,
      JugendlicherApiModel,
      JugendlicheCreateData
    >
    jugendlicheRepo,
    required JulogRepository<Eintrag, EintragApiModel, EintragCreateData>
    eintragRepo,
    required JulogRepository<Kategorie, KategorieApiModel, KategorieCreate>
    kategorieRepo,
  }) : _jugendlicheRepo = jugendlicheRepo,
       _eintragRepo = eintragRepo,
       _kategorieRepo = kategorieRepo;

  Future<DashboardData> build(DateTime today) async {
    final todayDate = DateTime(today.year, today.month, today.day);

    final jugendliche = await _jugendlicheRepo.getAll().unwrap();
    final eintraege = await _eintragRepo.getAll().unwrap();

    final aktiveJugendliche = jugendliche
        .where((j) => !j.isAusgetreten(todayDate) && j.replacedBy == null)
        .toList();
    final aktivCount = aktiveJugendliche.length;

    final sortedEintraege = [...eintraege]
      ..sort((a, b) => b.start.compareTo(a.start));
    final lastEintragModel = sortedEintraege.firstOrNull;

    LastEintragSummary? lastEintragSummary;
    DateTime? lastEintragDate;

    if (lastEintragModel != null) {
      lastEintragDate = lastEintragModel.start;

      final kategorieOpt = await _kategorieRepo
          .getById(lastEintragModel.kategorieId)
          .unwrap();
      final kategorieName = kategorieOpt is Some<Kategorie>
          ? kategorieOpt.unwrap().name
          : '';

      final aktivAtDate = jugendliche.where((j) {
        if (j.replacedBy != null) return false;
        if (j.exitDate != null && j.exitDate!.isBefore(lastEintragDate!)) {
          return false;
        }
        return true;
      }).length;

      final anwesendeCount = lastEintragModel.anwesendeJugendlicherIds.length;
      lastEintragSummary = LastEintragSummary(
        kategorieName: kategorieName,
        formattedDate: DateFormat('d.M.yyyy').format(lastEintragDate),
        thema: lastEintragModel.thema,
        anwesenheitDisplay: '$anwesendeCount / $aktivAtDate anwesend',
      );
    }

    List<BirthdayEntry> recentBirthdays = [];
    if (lastEintragDate != null) {
      final lastEintragDateOnly = DateTime(
        lastEintragDate.year,
        lastEintragDate.month,
        lastEintragDate.day,
      );
      final windowStart21 = todayDate.subtract(const Duration(days: 21));
      final effectiveStart = lastEintragDateOnly.isAfter(windowStart21)
          ? lastEintragDateOnly
          : windowStart21;

      recentBirthdays = aktiveJugendliche
          .where(
            (j) => _birthdayInWindow(j.birthDate, effectiveStart, todayDate),
          )
          .map((j) => BirthdayEntry(name: j.name, birthDate: j.birthDate))
          .toList();
    }

    final jugendlicherApiModels = jugendliche.map((j) {
      final sex = switch (j.gender) {
        Gender.male => Sex.male,
        Gender.female => Sex.female,
        Gender.diverse => Sex.diverse,
      };
      return JugendlicherApiModel(
        id: UUID.fromString(j.id),
        name: j.name,
        sex: sex,
        birthDate: j.birthDate,
        memberSince: j.memberSince,
        exitDate: j.exitDate,
        replacedById: j.replacedBy != null
            ? UUID.fromString(j.replacedBy!.id)
            : null,
        eintragIds: const {},
      );
    }).toList();

    final eintragApiModels = eintraege.map((e) {
      return EintragApiModel(
        id: UUID.fromString(e.id),
        start: e.start,
        end: e.end,
        kategorieId: UUID.fromString(e.kategorieId),
        thema: e.thema,
        betreuerIds: e.betreuerIds.map(UUID.fromString).toSet(),
        anwesendeJugendlicherIds: e.anwesendeJugendlicherIds
            .map(UUID.fromString)
            .toSet(),
        entschuldigteJugendlicherIds: e.entschuldigteJugendlicherIds
            .map(UUID.fromString)
            .toSet(),
        undefinierteJugendlicherIds: const {},
      );
    }).toList();

    final attendanceChart = AttendanceRateCalculator.calculate(
      eintragApiModels,
      jugendlicherApiModels,
    );

    return DashboardData(
      aktivCount: aktivCount,
      lastEintrag: lastEintragSummary,
      recentBirthdays: recentBirthdays,
      attendanceChart: attendanceChart,
    );
  }
}

bool _birthdayInWindow(
  DateTime birthDate,
  DateTime windowStart,
  DateTime windowEnd,
) {
  for (
    var d = windowStart;
    !d.isAfter(windowEnd);
    d = d.add(const Duration(days: 1))
  ) {
    if (d.month == birthDate.month && d.day == birthDate.day) return true;
  }
  return false;
}

@riverpod
Future<DashboardData> dashboardViewModel(Ref ref) {
  return DashboardViewModel(
    jugendlicheRepo: ref.watch(jugendlicheRepositoryProvider),
    eintragRepo: ref.watch(eintragRepositoryProvider),
    kategorieRepo: ref.watch(kategorieRepositoryProvider),
  ).build(DateTime.now());
}
