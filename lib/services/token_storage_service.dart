import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, persistent storage for JWT tokens.
///
/// On web (where flutter_secure_storage uses localStorage), this is
/// transparent to the caller but less secure — acceptable for a demo.
class TokenStorageService {
  static const _accessKey = 'fitforge_access_token';
  static const _refreshKey = 'fitforge_refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions.defaultOptions,
        );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessKey, value: accessToken),
        _storage.write(key: _refreshKey, value: refreshToken),
      ]);
    } catch (e) {
      debugPrint('⚠️ TokenStorage: failed to save tokens — $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessKey);
    } catch (e) {
      debugPrint('⚠️ TokenStorage: failed to read accessToken — $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshKey);
    } catch (e) {
      debugPrint('⚠️ TokenStorage: failed to read refreshToken — $e');
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
      ]);
    } catch (e) {
      debugPrint('⚠️ TokenStorage: failed to clear tokens — $e');
    }
  }
}

final tokenStorageService = TokenStorageService();
