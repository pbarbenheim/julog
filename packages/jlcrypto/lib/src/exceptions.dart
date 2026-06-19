class CorruptedKeyContainerException implements Exception {}

class PasswortWrongException implements Exception {
  @override
  String toString() => 'Passwort falsch';
}
