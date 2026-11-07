import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:app/config/app_config.dart';
import 'package:app/screens/auth_gate.dart';
import 'package:app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  Object? startupError;
  try {
    final clientId = AppConfig.serverClientIdOrNull;
    await GoogleSignIn.instance.initialize(
      // Web requires the OAuth client id. Android uses it as serverClientId
      // and rejects a web clientId in that slot the other way around.
      clientId: kIsWeb ? clientId : null,
      serverClientId: kIsWeb ? null : clientId,
    );
  } catch (error) {
    startupError = error;
  }
  runApp(StudentMajorApp(startupError: startupError));
}

class StudentMajorApp extends StatelessWidget {
  const StudentMajorApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinh viên',
      theme: buildAppTheme(),
      home: startupError == null
          ? const AuthGate()
          : _StartupErrorScreen(error: startupError!),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập Google')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Không khởi tạo được Google Sign-In.\n$error\n\nĐiền Web client ID vào lib/config/app_config.dart.',
        ),
      ),
    );
  }
}
