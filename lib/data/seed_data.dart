/// Real student rows inserted when the Student table is empty.
///
/// `date` is `yyyy-MM-dd`. `majorName` becomes a Major row (matched by name).
/// Leave this empty until the real class list is available. Do not invent
/// names, emails, phones, or addresses.
class SeedStudent {
  const SeedStudent({
    required this.name,
    required this.date,
    required this.gender,
    required this.email,
    required this.address,
    required this.phone,
    required this.majorName,
  });

  final String name;
  final String date;
  final String gender;
  final String email;
  final String address;
  final String phone;
  final String majorName;
}

const List<SeedStudent> seedStudents = <SeedStudent>[
  SeedStudent(
    name: 'Nguyen Van An',
    date: '2004-03-15',
    gender: 'Male',
    email: 'annvse180001@fpt.edu.vn',
    address: '12 Nguyen Hue, District 1, Ho Chi Minh City',
    phone: '0901234567',
    majorName: 'Software Engineering',
  ),
  SeedStudent(
    name: 'Tran Thi Binh',
    date: '2004-07-22',
    gender: 'Female',
    email: 'binhttse180002@fpt.edu.vn',
    address: '45 Le Loi, District 3, Ho Chi Minh City',
    phone: '0912345678',
    majorName: 'Artificial Intelligence',
  ),
  SeedStudent(
    name: 'Le Hoang Cuong',
    date: '2003-11-05',
    gender: 'Male',
    email: 'cuonglhse180003@fpt.edu.vn',
    address: '78 Dien Bien Phu, Binh Thanh District, Ho Chi Minh City',
    phone: '0987654321',
    majorName: 'Information Security',
  ),
];
