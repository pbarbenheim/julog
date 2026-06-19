import 'package:jlcrypto/jlcrypto.dart';
import 'package:test/test.dart';

void main() {
  group('library', () {
    KeyOwner? identity;
    KeyOwner? stringKeyOwner;
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
      identity = KeyOwner('John Doe', 'JFW', 'john.doe@example.com');

      stringKeyOwner = KeyOwner.fromString(
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

    test('KeyOwner test', () {
      expect(identity?.name == "John Doe", isTrue);
      expect(identity?.function == "JFW", isTrue);
      expect(identity?.mail == "john.doe@example.com", isTrue);
      expect(
        identity.toString() == "John Doe <john.doe@example.com> (JFW)",
        isTrue,
      );
      expect(stringKeyOwner?.name, "Jane Smith");
      expect(stringKeyOwner?.function, "Manager");
      expect(stringKeyOwner?.mail, "jane.smith@example.org");
    });

    test("keys test", () {
      expect(verified, isTrue);
      expect(loadedPrivate, isNotNull);
    });
  });

  group('PrivateKey.fromString exception behaviour', () {
    late String validEncoded;

    setUpAll(() {
      final kp = KeyPair.generate(
        identity: KeyOwner('Test', 'Tester', 'test@example.com'),
        password: 'correct-password',
      );
      validEncoded = kp.privateKey.toString();
    });

    test('correct key and password — no exception', () {
      expect(
        () => PrivateKey.fromString(validEncoded, 'correct-password'),
        returnsNormally,
      );
    });

    test('wrong password — throws PasswortWrongException', () {
      expect(
        () => PrivateKey.fromString(validEncoded, 'wrong-password'),
        throwsA(isA<PasswortWrongException>()),
      );
    });

    test(
      'corrupted outer container (invalid base64) — throws CorruptedKeyContainerException',
      () {
        expect(
          () => PrivateKey.fromString('not-valid-base64!!!', 'any-password'),
          throwsA(isA<CorruptedKeyContainerException>()),
        );
      },
    );

    test(
      'corrupted outer container (valid base64, invalid JSON) — throws CorruptedKeyContainerException',
      () {
        // base64-encode a string that is not valid JSON
        const encoded = 'dGhpcyBpcyBub3QganNvbg=='; // "this is not json"
        expect(
          () => PrivateKey.fromString(encoded, 'any-password'),
          throwsA(isA<CorruptedKeyContainerException>()),
        );
      },
    );
  });
}
