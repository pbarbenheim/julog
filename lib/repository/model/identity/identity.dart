import 'package:jlcrypto/jlcrypto.dart';
import 'package:jldb/jldb.dart';

sealed class Identity {
  String get id;
  String get name;
  String get function;
  String get mail;
  PublicKey get publicKey;
  bool get isLocal;

  const factory Identity.closed({
    required String id,
    required PublicKey publicKey,
    required bool isLocal,
  }) = ClosedIdentity;

  const factory Identity.open({
    required String id,
    required PrivateKey privateKey,
  }) = OpenIdentity;

  factory Identity.fromApiModel(IdentityApiModel model, bool isLocal) {
    return ClosedIdentity(
      id: model.id.toString(),
      publicKey: PublicKey.fromString(model.publicKey),
      isLocal: isLocal,
    );
  }

  IdentityApiModel toApiModel();
}

class ClosedIdentity implements Identity {
  @override
  final String id;
  @override
  final PublicKey publicKey;
  @override
  final bool isLocal;

  @override
  String get name => publicKey.identity.name;

  @override
  String get function => publicKey.identity.function;

  @override
  String get mail => publicKey.identity.mail;

  const ClosedIdentity({
    required this.id,
    required this.publicKey,
    required this.isLocal,
  });

  @override
  IdentityApiModel toApiModel() {
    return IdentityApiModel(
      id: UUID.fromString(id),
      publicKey: publicKey.toString(),
    );
  }
}

class OpenIdentity implements Identity {
  @override
  final String id;
  final PrivateKey privateKey;

  @override
  bool get isLocal => true;

  @override
  PublicKey get publicKey => privateKey.publicKey;

  @override
  String get name => publicKey.identity.name;

  @override
  String get function => publicKey.identity.function;

  @override
  String get mail => publicKey.identity.mail;

  const OpenIdentity({required this.id, required this.privateKey});

  @override
  IdentityApiModel toApiModel() {
    return IdentityApiModel(
      id: UUID.fromString(id),
      publicKey: publicKey.toString(),
    );
  }
}
