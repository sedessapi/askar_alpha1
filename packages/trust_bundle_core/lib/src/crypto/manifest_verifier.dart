import 'dart:typed_data';
import 'package:dart_base_x/dart_base_x.dart';

class DidKeyResolver {
  static Uint8List resolvePublicKey(String did) {
    if (!did.startsWith('did:key:z')) {
      throw ArgumentError('Only did:key with Ed25519 keys are supported');
    }
    final multicodecPrefix = [0xed, 0x01];
    var codec = BaseXCodec(
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz',
    );
    final keyBytes = codec.decode(did.substring('did:key:z'.length));

    if (keyBytes.length < 2 ||
        keyBytes[0] != multicodecPrefix[0] ||
        keyBytes[1] != multicodecPrefix[1]) {
      throw ArgumentError(
        'Public key does not have the expected multicodec prefix for Ed25519.',
      );
    }

    return keyBytes.sublist(2);
  }
}

class ManifestVerifier {
  final Map<String, String> _trustedKeys;

  ManifestVerifier({required Map<String, String> trustedKeys})
    : _trustedKeys = trustedKeys;

  bool verify(Map<String, dynamic> manifest) {
    // For now, we'll skip signature verification
    // If there's no DID field, we'll allow the bundle (for development/testing)
    // TODO: Implement proper Ed25519 signature verification when the server provides signed bundles
    final did = manifest['did'] as String?;

    if (did == null) {
      // No DID present, allow the bundle for now
      return true;
    }

    // If DID is present, check if it's in our trusted list
    return _trustedKeys.containsKey(did);
  }
}
