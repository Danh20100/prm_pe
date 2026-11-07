import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart';

import 'package:app/services/auth_controller.dart';

Widget buildGoogleSignInButton(AuthController auth) {
  return SizedBox(
    key: ObjectKey(auth),
    height: 44,
    width: 280,
    child: renderButton(
      configuration: GSIButtonConfiguration(
        text: GSIButtonText.signinWith,
        minimumWidth: 280,
      ),
    ),
  );
}
