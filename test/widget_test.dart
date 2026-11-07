import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/models/student.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/utils/student_format.dart';
import 'package:app/utils/validators.dart';
import 'package:app/widgets/student_list_item.dart';

void main() {
  test('stores and shows a date of birth', () {
    final stored = storeStudentDate(DateTime(2005, 3, 21));
    expect(stored, '2005-03-21');
    expect(formatStudentDate(stored), '21/03/2005');
    expect(parseStoredDate('not-a-date'), isNull);
  });

  test('rejects blank, bad email, and phoneless values', () {
    expect(validateRequired('  ', 'họ tên'), 'Nhập họ tên.');
    expect(validateRequired('An', 'họ tên'), isNull);
    expect(validateEmail('not-an-email'), 'Email không hợp lệ.');
    expect(validateEmail('an@fpt.edu.vn'), isNull);
    expect(validatePhone('---'), 'Số điện thoại không hợp lệ.');
    expect(validatePhone('0901234567'), isNull);
  });

  testWidgets('custom student row shows every field', (tester) async {
    const student = StudentWithMajor(
      id: 12,
      name: 'Le Nguyen',
      date: '2005-03-21',
      gender: 'Nam',
      email: 'le.nguyen@example.com',
      address: '12 Nguyen Hue, Quan 1',
      phone: '0901234567',
      idMajor: 3,
      nameMajor: 'Ky thuat phan mem',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: StudentListItem(
            student: student,
            onEdit: () {},
            onDelete: () {},
            onMap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Le Nguyen'), findsOneWidget);
    expect(find.text('ID: 12'), findsOneWidget);
    expect(find.text('Ngày sinh: 21/03/2005'), findsOneWidget);
    expect(find.text('Giới tính: Nam'), findsOneWidget);
    expect(find.text('Email: le.nguyen@example.com'), findsOneWidget);
    expect(find.text('Số điện thoại: 0901234567'), findsOneWidget);
    expect(find.text('Địa chỉ: 12 Nguyen Hue, Quan 1'), findsOneWidget);
    expect(find.text('Ngành: Ky thuat phan mem'), findsOneWidget);
    expect(find.text('idMajor: 3'), findsOneWidget);
    expect(find.text('Sửa'), findsOneWidget);
    expect(find.text('Xóa'), findsOneWidget);
    expect(find.text('Bản đồ'), findsOneWidget);
  });
}
