import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:app/app/app_navigator.dart';
import 'package:app/app/feature_controller_registry.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/data/network/api_client.dart';
import 'package:app/data/services/device_id_service.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/domain/models/auth_models.dart';

part 'auth_controller_error_messages.dart';
part 'auth_controller_session_actions.dart';
part 'auth_storage_keys.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._deviceIdService, this._navigator);

  final AuthRepository _repository;
  final DeviceIdService _deviceIdService;
  final AppNavigator _navigator;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    hostedDomain: AppConfig.companyDomain,
    serverClientId: AppConfig.googleServerClientId,
    scopes: const <String>['email', 'profile', 'openid'],
  );

  final Rxn<UserProfile> user = Rxn<UserProfile>();
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxnString errorText = RxnString();
  final RxBool isDeviceMismatch = false.obs;

  String? _accessToken;
  String? _refreshToken;
  String? _deviceId;
  String? _lastGoogleIdToken;
  Future<String?>? _refreshInFlight;
  ApiPortal _sessionPortal = ApiPortal.employee;

  bool get isAuthenticated => _accessToken != null && user.value != null;

  bool get isAdminSession =>
      isAuthenticated && _sessionPortal == ApiPortal.admin;

  String? get deviceId => _deviceId;

  @override
  void onInit() {
    super.onInit();
    _repository.onTokenRefreshRequired = _handleAccessTokenExpired;
    _bootstrap();
  }

  Future<void> signInWithGoogle(ApiPortal portal) async {
    isLoading.value = true;
    errorText.value = null;
    isDeviceMismatch.value = false;
    _lastGoogleIdToken = null;

    try {
      final id = _deviceId;
      if (portal == ApiPortal.employee && id == null) {
        throw Exception('Unable to resolve Android device ID');
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to retrieve Google ID token');
      }

      _lastGoogleIdToken = idToken;

      final authPayload = await _repository.loginWithGoogle(
        googleToken: idToken,
        portal: portal,
        deviceId: id,
      );
      final tokens = AuthTokens.fromJson(authPayload);

      _sessionPortal = portal;
      _accessToken = tokens.accessToken;
      _refreshToken = tokens.refreshToken;
      _repository.setAccessToken(_accessToken);

      await _storage.write(
        key: AuthStorageKeys.accessToken,
        value: _accessToken,
      );
      await _storage.write(
        key: AuthStorageKeys.refreshToken,
        value: _refreshToken,
      );
      await _storage.write(
        key: AuthStorageKeys.sessionPortal,
        value: _portalToStorage(portal),
      );

      final profileJson = await _repository.fetchProfile();
      await _applyUserProfile(UserProfile.fromJson(profileJson));

      _navigator.goToAuthenticatedHome(portal);
    } catch (error) {
      if (_accessToken != null && user.value == null) {
        await _clearSession();
      }

      final message = _toLoginErrorMessage(error);
      if (message == null) {
        errorText.value = null;
        isDeviceMismatch.value = false;
        return;
      }

      errorText.value = message;
      isDeviceMismatch.value = message.toLowerCase().contains(
        'device mismatch',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;

    try {
      final refresh = _refreshToken;
      if (refresh != null) {
        await _repository.logout(refresh);
      }
    } catch (_) {
      // Silent by design.
    }

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Silent by design.
    }

    _navigator.goToLogin();

    await _clearSession();
    isLoading.value = false;
  }

  Future<bool> requestDeviceChange(String reason) async {
    final token = _lastGoogleIdToken;
    final id = _deviceId;
    if (token == null || id == null) return false;

    isLoading.value = true;

    try {
      await _repository.requestDeviceChangeOnLogin(
        googleToken: token,
        deviceId: id,
        reason: reason,
      );
      errorText.value = null;
      isDeviceMismatch.value = false;
      _lastGoogleIdToken = null;
      return true;
    } catch (error) {
      errorText.value = _repository.toReadableError(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorText.value = null;
    isDeviceMismatch.value = false;
    _lastGoogleIdToken = null;
  }
}
