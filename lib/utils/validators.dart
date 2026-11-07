String? validateRequired(String? value, String label) {
  if (value == null || value.trim().isEmpty) return 'Nhập $label.';
  return null;
}

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Nhập email.';
  final matches = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  if (!matches) return 'Email không hợp lệ.';
  return null;
}

String? validatePhone(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Nhập số điện thoại.';
  if (!RegExp(r'\d').hasMatch(text)) return 'Số điện thoại không hợp lệ.';
  return null;
}
