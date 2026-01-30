import 'package:jlcrypto/jlcrypto.dart';
import 'package:test/test.dart';

void main() {
  group('library', () {
    Identity? identity;
    Identity? stringIdentity;
    String? password = 'securepassword123';
    KeyPair? keypair;
    bool? verified;
    String? savedPrivate;
    String? savedPublic;
    PublicKey? loadedPublic;
    PrivateKey? loadedPrivate;
    Message? message;
    String? signature;
    setUpAll(() {
      identity = Identity('John Doe', 'JFW', 'john.doe@example.com');

      stringIdentity = Identity.fromString(
        "Jane Smith <jane.smith@example.org> (Manager)",
      );

      keypair = KeyPair.generate(identity: identity!, password: password);
      savedPrivate = keypair?.privateKey.toString();
      loadedPrivate = PrivateKey.fromString(savedPrivate!, password);

      savedPublic = keypair?.publicKey.toString();
      loadedPublic = PublicKey.fromString(savedPublic!);

      message = Message.fromString("This is a secret message.");
      signature = keypair?.privateKey.signSHA512(message!).toString();

      verified = loadedPublic?.verifySHA512Signature(
        message!,
        Signature.fromString(signature!),
      );
    });

    test('Identity test', () {
      expect(identity?.name == "John Doe", isTrue);
      expect(identity?.function == "JFW", isTrue);
      expect(identity?.mail == "john.doe@example.com", isTrue);
      expect(
        identity.toString() == "John Doe <john.doe@example.com> (JFW)",
        isTrue,
      );
      expect(stringIdentity?.name, "Jane Smith");
      expect(stringIdentity?.function, "Manager");
      expect(stringIdentity?.mail, "jane.smith@example.org");
    });

    test("keys test", () {
      expect(verified, isTrue);
      expect(loadedPrivate, isNotNull);
    });
  });
}
