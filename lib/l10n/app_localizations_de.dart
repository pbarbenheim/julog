// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'julog';

  @override
  String get addNewJugendlicher => 'Neuen Jugendlichen hinzufügen';

  @override
  String name(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Namen',
      many: 'Namen',
      one: 'Name',
    );
    return '$_temp0';
  }

  @override
  String get nameRequired => 'Bitte gibt einen Namen ein';

  @override
  String get birthdate => 'Geburtsdatum';

  @override
  String get dateFormatError => 'Ungültiges Datum';

  @override
  String get dateInvalidError => 'Datum außerhalb des gültigen Bereichs';

  @override
  String get memberSince => 'Mitglied seit';

  @override
  String get saveButton => 'Speichern';

  @override
  String get optionalPass => 'Pass (optional)';

  @override
  String stateBirthdate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Geburtsdatum: $dateString';
  }

  @override
  String stateMemberSince(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Mitglied seit: $dateString';
  }

  @override
  String stateExitDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Austrittsdatum: $dateString';
  }
}
