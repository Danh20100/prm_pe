import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:app/data/app_database.dart';
import 'package:app/models/major.dart';
import 'package:app/models/student.dart';
import 'package:app/screens/major_list_screen.dart';
import 'package:app/utils/student_format.dart';
import 'package:app/utils/validators.dart';
import 'package:app/widgets/app_feedback.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key, this.student});

  final StudentWithMajor? student;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _phone;

  List<Major>? _majors;
  DateTime? _date;
  String? _dateError;
  String? _gender;
  int? _majorId;
  bool _saving = false;
  Object? _loadError;

  static const _genders = <String>['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _name = TextEditingController(text: student?.name ?? '');
    _email = TextEditingController(text: student?.email ?? '');
    _address = TextEditingController(text: student?.address ?? '');
    _phone = TextEditingController(text: student?.phone ?? '');
    _date = student == null ? null : parseStoredDate(student.date);
    _gender = student?.gender;
    _majorId = student?.idMajor;
    _loadMajors();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  List<String> get _genderChoices {
    final current = _gender;
    if (current != null && !_genders.contains(current)) {
      return [current, ..._genders];
    }
    return _genders;
  }

  Future<void> _loadMajors() async {
    try {
      final majors = await AppDatabase.instance.majors();
      if (!mounted) return;
      final stillThere = majors.any((major) => major.idMajor == _majorId);
      setState(() {
        _majors = majors;
        _loadError = null;
        if (!stillThere) _majorId = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1970),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateError = null;
    });
  }

  Future<void> _openMajors() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const MajorListScreen()),
    );
    if (mounted) await _loadMajors();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    final date = _date;
    if (date == null) {
      setState(() => _dateError = 'Chọn ngày sinh.');
    }
    if (!valid || date == null || _saving) return;
    final gender = _gender;
    final majorId = _majorId;
    if (gender == null || majorId == null) return;

    setState(() => _saving = true);
    final input = StudentInput(
      name: _name.text.trim(),
      date: storeStudentDate(date),
      gender: gender,
      email: _email.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      idMajor: majorId,
    );
    try {
      final existing = widget.student;
      if (existing == null) {
        await AppDatabase.instance.insertStudent(input);
      } else {
        await AppDatabase.instance.updateStudent(existing.id, input);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on DatabaseException {
      if (!mounted) return;
      showMessage(context, 'Không lưu được sinh viên. Kiểm tra ngành đã chọn.');
    } catch (error) {
      if (!mounted) return;
      showMessage(context, 'Không lưu được sinh viên.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.student != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Sửa sinh viên' : 'Thêm sinh viên')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadError != null && _majors == null) {
      return Center(
        child: Text('Không tải được danh sách ngành.\n$_loadError'),
      );
    }
    final majors = _majors;
    if (majors == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final date = _date;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Họ tên'),
            validator: (value) => validateRequired(value, 'họ tên'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _saving ? null : _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Ngày sinh',
                errorText: _dateError,
              ),
              child: Text(
                date == null
                    ? 'Chọn ngày sinh'
                    : formatStudentDate(storeStudentDate(date)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _genderChoices.contains(_gender) ? _gender : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Giới tính'),
            hint: const Text('Chọn giới tính'),
            items: [
              for (final gender in _genderChoices)
                DropdownMenuItem(value: gender, child: Text(gender)),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _gender = value),
            validator: (value) => value == null ? 'Chọn giới tính.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: validateEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Địa chỉ'),
            validator: (value) => validateRequired(value, 'địa chỉ'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Số điện thoại'),
            validator: validatePhone,
          ),
          const SizedBox(height: 12),
          if (majors.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chưa có ngành. Hãy thêm ngành trước khi lưu sinh viên.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: _openMajors,
                  child: const Text('Mở danh sách ngành'),
                ),
              ],
            )
          else
            DropdownButtonFormField<int>(
              initialValue: majors.any((major) => major.idMajor == _majorId)
                  ? _majorId
                  : null,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Ngành'),
              hint: const Text('Chọn ngành'),
              items: [
                for (final major in majors)
                  DropdownMenuItem(
                    value: major.idMajor,
                    child: Text(major.nameMajor),
                  ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _majorId = value),
              validator: (value) => value == null ? 'Chọn ngành.' : null,
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
