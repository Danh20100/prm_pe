import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    _subscription = GoogleSignIn.instance.authenticationEvents.listen(
      _onEvent,
      onError: _onError,
    );
  }

  GoogleSignInAccount? account;
  bool guest = false;
  bool ready = false;
  bool busy = false;
  String? errorMessage;

  bool get signedIn => account != null || guest;

  late final StreamSubscription<GoogleSignInAuthenticationEvent> _subscription;

  Future<void> start() async {
    try {
      final pending = GoogleSignIn.instance.attemptLightweightAuthentication();
      if (pending != null) {
        account = await pending;
      }
    } on GoogleSignInException catch (error) {
      errorMessage = _messageFor(error);
    } catch (error) {
      errorMessage = 'Không khôi phục được phiên đăng nhập.';
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        errorMessage =
            'Trên trình duyệt, hãy dùng nút Google trên màn hình đăng nhập.';
        return;
      }
      account = await GoogleSignIn.instance.authenticate();
      guest = false;
      errorMessage = null;
    } on GoogleSignInException catch (error) {
      account = null;
      errorMessage = _messageFor(error);
    } catch (error) {
      account = null;
      errorMessage = 'Đăng nhập Google thất bại.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void continueAsGuest() {
    guest = true;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    guest = false;
    account = null;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      errorMessage = 'Không đăng xuất được.';
    }
    notifyListeners();
  }

  void _onEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        account = user;
        guest = false;
        errorMessage = null;
      case GoogleSignInAuthenticationEventSignOut():
        account = null;
        guest = false;
    }
    ready = true;
    notifyListeners();
  }

  void _onError(Object error) {
    if (error is GoogleSignInException) {
      final message = _messageFor(error);
      if (message == null) return;
      errorMessage = message;
    } else {
      errorMessage = 'Đăng nhập Google thất bại.';
    }
    ready = true;
    notifyListeners();
  }

  String? _messageFor(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.uiUnavailable:
        return null;
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return error.description ??
            'Cấu hình Google chưa đúng. Kiểm tra Web client ID, package com.example.app và SHA-1.';
      case GoogleSignInExceptionCode.unknownError:
      case GoogleSignInExceptionCode.userMismatch:
        return error.description ?? 'Đăng nhập Google thất bại.';
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
