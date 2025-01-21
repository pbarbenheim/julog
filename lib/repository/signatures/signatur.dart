import 'package:julog/repository/eintrag/eintrag.dart';
import 'package:julog/repository/identity/identity.dart';

class Signatur {
  final Identity identity;
  final String signature;
  final DateTime signedAt;
  final int signVersion;
  final EintragHeader eintrag;

  Signatur({
    required this.identity,
    required this.signature,
    required this.signedAt,
    required this.signVersion,
    required this.eintrag,
  });
}
