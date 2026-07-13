import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';

const _kTokenKey = 'tripmind_token';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  /// Dev login: upsert a user by email and return (token, user).
  Future<(String, AppUser)> login(String email, String name) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'name': name},
    );
    final data = res.data!;
    return (data['token'] as String, AppUser.fromJson(data['user'] as Map<String, dynamic>));
  }

  Future<AppUser> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/auth/me');
    return AppUser.fromJson(res.data!);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// Auth state: the current user, or null when signed out. `loading` while the
/// stored token is being restored at startup.
class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  final Ref _ref;
  AuthController(this._ref) : super(const AsyncValue.loading()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    _ref.read(apiTokenProvider.notifier).state = token;
    try {
      final user = await _ref.read(authRepositoryProvider).me();
      state = AsyncValue.data(user);
    } catch (_) {
      // Token no longer valid (e.g. DB reset) — clear it.
      await prefs.remove(_kTokenKey);
      _ref.read(apiTokenProvider.notifier).state = null;
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String name) async {
    state = const AsyncValue.loading();
    try {
      final (token, user) = await _ref.read(authRepositoryProvider).login(email, name);
      _ref.read(apiTokenProvider.notifier).state = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, token);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    _ref.read(apiTokenProvider.notifier).state = null;
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(ref);
});
