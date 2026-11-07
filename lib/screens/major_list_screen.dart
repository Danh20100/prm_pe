import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:app/data/app_database.dart';
import 'package:app/models/major.dart';
import 'package:app/widgets/app_feedback.dart';

class MajorListScreen extends StatefulWidget {
  const MajorListScreen({super.key});

  @override
  State<MajorListScreen> createState() => _MajorListScreenState();
}

class _MajorListScreenState extends State<MajorListScreen> {
  List<Major>? _majors;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final majors = await AppDatabase.instance.majors();
      if (!mounted) return;
      setState(() {
        _majors = majors;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _edit({Major? major}) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _MajorNameDialog(
        title: major == null ? 'Thêm ngành' : 'Sửa ngành',
        initialName: major?.nameMajor ?? '',
      ),
    );
    if (name == null || !mounted) return;
    try {
      if (major == null) {
        await AppDatabase.instance.insertMajor(name);
      } else {
        await AppDatabase.instance.updateMajor(major.idMajor, name);
      }
      await _load();
    } on DatabaseException catch (error) {
      if (!mounted) return;
      showMessage(
        context,
        error.isUniqueConstraintError()
            ? 'Tên ngành đã tồn tại.'
            : 'Không lưu được ngành.',
      );
    } catch (error) {
      if (!mounted) return;
      showMessage(context, 'Không lưu được ngành.');
    }
  }

  Future<void> _delete(Major major) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa ngành',
      message: 'Xóa ngành "${major.nameMajor}"?',
    );
    if (!confirmed || !mounted) return;
    try {
      await AppDatabase.instance.deleteMajor(major.idMajor);
      await _load();
    } on MajorInUseException catch (error) {
      if (!mounted) return;
      showMessage(context, error.message);
    } on DatabaseException {
      if (!mounted) return;
      showMessage(
        context,
        'Không xóa được ngành vì còn sinh viên thuộc ngành này.',
      );
    } catch (error) {
      if (!mounted) return;
      showMessage(context, 'Không xóa được ngành.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final majors = _majors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngành'),
        actions: [
          TextButton(onPressed: () => _edit(), child: const Text('Thêm')),
        ],
      ),
      body: _buildBody(majors),
    );
  }

  Widget _buildBody(List<Major>? majors) {
    if (_error != null && majors == null) {
      return Center(child: Text('Không tải được danh sách ngành.\n$_error'));
    }
    if (majors == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (majors.isEmpty) {
      return const Center(child: Text('Chưa có ngành. Nhấn Thêm.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: majors.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final major = majors[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    major.nameMajor,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('IDMajor ${major.idMajor}'),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _edit(major: major),
                        child: const Text('Sửa'),
                      ),
                      TextButton(
                        onPressed: () => _delete(major),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MajorNameDialog extends StatefulWidget {
  const _MajorNameDialog({required this.title, required this.initialName});

  final String title;
  final String initialName;

  @override
  State<_MajorNameDialog> createState() => _MajorNameDialogState();
}

class _MajorNameDialogState extends State<_MajorNameDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nhập tên ngành.');
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: 'Tên ngành', errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}
