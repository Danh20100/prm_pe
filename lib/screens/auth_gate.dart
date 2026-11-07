import 'package:flutter/material.dart';

import 'package:app/screens/login_screen.dart';
import 'package:app/screens/student_list_screen.dart';
import 'package:app/services/auth_controller.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthController();
    _auth.addListener(_onAuth);
    _auth.start();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuth);
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_auth.signedIn) return LoginScreen(auth: _auth);
    return StudentListScreen(auth: _auth);
  }
}
