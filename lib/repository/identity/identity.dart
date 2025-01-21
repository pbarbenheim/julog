import 'package:dart_pg/dart_pg.dart';

class Identity {
  final String userId;
  final PublicKey? key;

  bool get hasKey => key != null;

  Identity({required this.userId, this.key});
}

class SigningIdentity extends Identity {
  final PrivateKey privateKey;

  SigningIdentity({
    required super.userId,
    required this.privateKey,
  }) : super(key: PublicKey(privateKey.publicKey.packetList));
}
