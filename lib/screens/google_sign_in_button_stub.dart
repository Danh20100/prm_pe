import 'package:flutter/material.dart';

import 'package:app/services/auth_controller.dart';

Widget buildGoogleSignInButton(AuthController auth) {
  return FilledButton(
    onPressed: auth.busy ? null : auth.signIn,
    child: auth.busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text('Đăng nhập với Google'),
  );
}
