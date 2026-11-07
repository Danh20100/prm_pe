import 'package:flutter/material.dart';

import 'package:app/config/app_config.dart';
import 'package:app/screens/google_sign_in_button_stub.dart'
    if (dart.library.js_interop) 'package:app/screens/google_sign_in_button_web.dart';
import 'package:app/services/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = auth.errorMessage;
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Đăng nhập bằng tài khoản Google để xem và quản lý dữ liệu.',
                ),
                const SizedBox(height: 24),
                buildGoogleSignInButton(auth),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: auth.continueAsGuest,
                  child: const Text('Xem dữ liệu'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                if (AppConfig.serverClientIdOrNull == null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có Web client ID. Dán vào serverClientId trong lib/config/app_config.dart.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
