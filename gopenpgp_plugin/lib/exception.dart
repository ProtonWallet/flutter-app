class CryptoException implements Exception {
  final String message;
  CryptoException(this.message);

  @override
  String toString() => 'Go Error: $message';

  factory CryptoException.from(String message) {
    if (message.contains("Unlock:")) {
      return PassphraseException(message);
    } else if (message.contains("Armored:")) {
      return ArmorException(message);
    } else if (message.contains("Encrypt:")) {
      return EncryptionException(message);
    } else if (message.contains("KeyRing:")) {
      return KeyRingException(message);
    } else if (message.contains("Decrypt:")) {
      return DecryptionException(message);
    } else if (message.contains("Sign:")) {
      return SignException(message);
    }
    return CryptoException(message);
  }
}

class PassphraseException extends CryptoException {
  PassphraseException(super.message);

  @override
  String toString() => message;
}

class ArmorException extends CryptoException {
  ArmorException(super.message);

  @override
  String toString() => message;
}

class EncryptionException extends CryptoException {
  EncryptionException(super.message);

  @override
  String toString() => message;
}

class DecryptionException extends CryptoException {
  DecryptionException(super.message);

  @override
  String toString() => message;
}

class SignException extends CryptoException {
  SignException(super.message);

  @override
  String toString() => message;
}

class KeyRingException extends CryptoException {
  KeyRingException(super.message);

  @override
  String toString() => message;
}
