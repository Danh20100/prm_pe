class Major {
  const Major({required this.idMajor, required this.nameMajor});

  final int idMajor;
  final String nameMajor;

  factory Major.fromMap(Map<String, Object?> map) {
    return Major(
      idMajor: map['IDMajor']! as int,
      nameMajor: map['nameMajor']! as String,
    );
  }
}
