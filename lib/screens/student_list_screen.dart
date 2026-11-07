import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:app/data/app_database.dart';
import 'package:app/models/student.dart';
import 'package:app/screens/major_list_screen.dart';
import 'package:app/screens/student_form_screen.dart';
import 'package:app/screens/student_map_screen.dart';
import 'package:app/services/auth_controller.dart';
import 'package:app/widgets/app_feedback.dart';
import 'package:app/widgets/student_list_item.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key, required this.auth});

  final AuthController auth;

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<StudentWithMajor>? _students;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final students = await AppDatabase.instance.studentsWithMajor();
      if (!mounted) return;
      setState(() {
        _students = students;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _openForm({StudentWithMajor? student}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => StudentFormScreen(student: student),
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _openMajors() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const MajorListScreen()),
    );
    if (mounted) await _load();
  }

  void _openMap({int? focusStudentId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StudentMapScreen(focusStudentId: focusStudentId),
      ),
    );
  }

  Future<void> _delete(StudentWithMajor student) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa sinh viên',
      message: 'Xóa ${student.name}?',
    );
    if (!confirmed || !mounted) return;
    try {
      await AppDatabase.instance.deleteStudent(student.id);
      await _load();
    } catch (error) {
      if (!mounted) return;
      showMessage(context, 'Không xóa được sinh viên.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.auth.account;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh viên'),
        actions: [
          TextButton(
            onPressed: () => _openForm(),
            child: const Text('Thêm'),
          ),
          TextButton(
            onPressed: () => _openMap(),
            child: const Text('Bản đồ'),
          ),
          TextButton(onPressed: _openMajors, child: const Text('Ngành')),
          TextButton(
            onPressed: widget.auth.signOut,
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (account != null)
            _AccountBanner(account: account)
          else
            const _GuestBanner(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    final students = _students;
    if (_error != null && students == null) {
      return Center(
        child: Text('Không tải được danh sách sinh viên.\n$_error'),
      );
    }
    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (students.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Chưa có sinh viên.\nThêm ngành, rồi nhấn Thêm và nhập thông tin thật.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return StudentListItem(
            key: ValueKey(student.id),
            student: student,
            onEdit: () => _openForm(student: student),
            onDelete: () => _delete(student),
            onMap: () => _openMap(focusStudentId: student.id),
          );
        },
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  const _GuestBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text('Đang xem không dùng Google'),
      ),
    );
  }
}

class _AccountBanner extends StatelessWidget {
  const _AccountBanner({required this.account});

  final GoogleSignInAccount account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = account.displayName?.trim();
    final title = (name == null || name.isEmpty) ? account.email : name;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text('$title\n${account.email}'),
      ),
    );
  }
}
