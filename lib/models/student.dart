class StudentInput {
  const StudentInput({
    required this.name,
    required this.date,
    required this.gender,
    required this.email,
    required this.address,
    required this.phone,
    required this.idMajor,
  });

  final String name;
  final String date;
  final String gender;
  final String email;
  final String address;
  final String phone;
  final int idMajor;

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'date': date,
      'gender': gender,
      'email': email,
      'Address': address,
      'Phone': phone,
      'idMajor': idMajor,
    };
  }
}

class StudentWithMajor {
  const StudentWithMajor({
    required this.id,
    required this.name,
    required this.date,
    required this.gender,
    required this.email,
    required this.address,
    required this.phone,
    required this.idMajor,
    required this.nameMajor,
  });

  final int id;
  final String name;
  final String date;
  final String gender;
  final String email;
  final String address;
  final String phone;
  final int idMajor;
  final String nameMajor;

  factory StudentWithMajor.fromMap(Map<String, Object?> map) {
    return StudentWithMajor(
      id: map['ID']! as int,
      name: map['name']! as String,
      date: map['date']! as String,
      gender: map['gender']! as String,
      email: map['email']! as String,
      address: map['Address']! as String,
      phone: map['Phone']! as String,
      idMajor: map['idMajor']! as int,
      nameMajor: map['nameMajor']! as String,
    );
  }
}
