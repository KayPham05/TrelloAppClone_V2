import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_account.dart';

const _kSessionsKey = 'saved_sessions';
const _secureStorage = FlutterSecureStorage();

class SessionManager {
  // ── Persist current session after login ────────────────────────────────────
  Future<void> saveCurrentSession({
    required String userUId,
    required String userName,
    required String email,
    required String avatarUrl,
    required String accessToken,
    required String refreshToken,
  }) async {
    // Store tokens keyed by userUId so they don't overwrite each other.
    await _secureStorage.write(
      key: 'access_token_$userUId',
      value: accessToken,
    );
    await _secureStorage.write(
      key: 'refresh_token_$userUId',
      value: refreshToken,
    );

    final account = SavedAccount(
      userUId: userUId,
      userName: userName,
      email: email,
      avatarUrl: avatarUrl,
    );

    final list = await getSavedAccounts();
    // Replace if already saved (update name/avatar), otherwise add.
    final idx = list.indexWhere((a) => a.userUId == userUId);
    if (idx >= 0) {
      list[idx] = account;
    } else {
      list.add(account);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSessionsKey,
      jsonEncode(list.map((a) => a.toJson()).toList()),
    );
  }

  // ── Retrieve saved accounts ─────────────────────────────────────────────────
  Future<List<SavedAccount>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Switch to another account ───────────────────────────────────────────────
  /// Restores the tokens + SharedPreferences keys for [account].
  /// Returns false if the stored token is missing (user must re-login).
  Future<bool> switchTo(SavedAccount account) async {
    final accessToken = await _secureStorage.read(
      key: 'access_token_${account.userUId}',
    );
    final refreshToken = await _secureStorage.read(
      key: 'refresh_token_${account.userUId}',
    );

    if (accessToken == null || accessToken.isEmpty) return false;

    // Restore active session keys
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(
      key: 'refresh_token',
      value: refreshToken ?? '',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', true);
    await prefs.setString('user_uid', account.userUId);
    await prefs.setString('user_name', account.userName);
    await prefs.setString('user_email', account.email);
    await prefs.setString('user_avatar', account.avatarUrl);

    return true;
  }

  // ── Remove a saved account ─────────────────────────────────────────────────
  Future<void> removeAccount(String userUId) async {
    await _secureStorage.delete(key: 'access_token_$userUId');
    await _secureStorage.delete(key: 'refresh_token_$userUId');

    final list = await getSavedAccounts();
    list.removeWhere((a) => a.userUId == userUId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSessionsKey,
      jsonEncode(list.map((a) => a.toJson()).toList()),
    );
  }

  // ── Get currently active userUId ───────────────────────────────────────────
  Future<String?> getActiveUserUId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }
}
