import 'package:flutter/material.dart';

import 'package:app/models/student.dart';
import 'package:app/utils/student_format.dart';

class StudentListItem extends StatelessWidget {
  const StudentListItem({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
    required this.onMap,
  });

  final StudentWithMajor student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('ID: ${student.id}'),
              Text('Ngày sinh: ${formatStudentDate(student.date)}'),
              Text('Giới tính: ${student.gender}'),
              Text('Email: ${student.email}'),
              Text('Số điện thoại: ${student.phone}'),
              Text('Địa chỉ: ${student.address}'),
              Text('Ngành: ${student.nameMajor}'),
              Text('idMajor: ${student.idMajor}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton(onPressed: onEdit, child: const Text('Sửa')),
                  TextButton(onPressed: onDelete, child: const Text('Xóa')),
                  TextButton(onPressed: onMap, child: const Text('Bản đồ')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
