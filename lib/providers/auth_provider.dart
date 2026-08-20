import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/parent.dart';
import 'api_provider.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final ParentModel? parent;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.parent,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    ParentModel? parent,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      parent: parent ?? this.parent,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(AuthState()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    state = state.copyWith(isLoading: true);
    final token = await _apiClient.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      try {
        final resp = await _apiClient.dio.get('/parent/profile');
        if (!mounted) return;
        final parent = ParentModel.fromJson(resp.data);
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          parent: parent,
          isLoading: false,
        );
        return;
      } catch (e) {
        await _apiClient.clearSession();
      }
    }
    if (!mounted) return;
    state = state.copyWith(isAuthenticated: false, isLoading: false);
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      });

      final accessToken = resp.data['access_token'];
      final refreshToken = resp.data['refresh_token'];
      await _apiClient.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

      final parentResp = await _apiClient.dio.get('/parent/profile');
      if (!mounted) return false;
      final parent = ParentModel.fromJson(parentResp.data);

      state = state.copyWith(
        isAuthenticated: true,
        token: accessToken,
        parent: parent,
        isLoading: false,
      );
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      final msg = (e.error != null && e.error.toString().isNotEmpty)
          ? e.error.toString()
          : (e.message ?? "Unable to connect to backend server. Please verify backend is running.");
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = resp.data['access_token'];
      final refreshToken = resp.data['refresh_token'];
      await _apiClient.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

      final parentResp = await _apiClient.dio.get('/parent/profile');
      if (!mounted) return false;
      final parent = ParentModel.fromJson(parentResp.data);

      state = state.copyWith(
        isAuthenticated: true,
        token: accessToken,
        parent: parent,
        isLoading: false,
      );
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      final msg = (e.error != null && e.error.toString().isNotEmpty)
          ? e.error.toString()
          : (e.message ?? "Unable to connect to backend server. Please verify backend is running.");
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> reloadProfile() async {
    try {
      final parentResp = await _apiClient.dio.get('/parent/profile');
      if (!mounted) return;
      final parent = ParentModel.fromJson(parentResp.data);
      state = state.copyWith(parent: parent);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {}
    await _apiClient.clearSession();
    if (!mounted) return;
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthNotifier(client);
});
