import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:app/data/seed_data.dart';
import 'package:app/models/major.dart';
import 'package:app/models/student.dart';

class MajorInUseException implements Exception {
  MajorInUseException(this.studentCount);

  final int studentCount;

  String get message =>
      'Không xóa được ngành vì còn $studentCount sinh viên thuộc ngành này.';
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  Future<Database>? _opening;

  Future<Database> get database {
    final existing = _db;
    if (existing != null) return Future<Database>.value(existing);
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'student_major.db');
    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Major (
            IDMajor INTEGER PRIMARY KEY AUTOINCREMENT,
            nameMajor TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE Student (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            gender TEXT NOT NULL,
            email TEXT NOT NULL,
            Address TEXT NOT NULL,
            Phone TEXT NOT NULL,
            idMajor INTEGER NOT NULL,
            FOREIGN KEY (idMajor) REFERENCES Major (IDMajor)
          )
        ''');
      },
    );
    await _seedIfEmpty(db);
    _db = db;
    return db;
  }

  Future<void> _seedIfEmpty(Database db) async {
    if (seedStudents.isEmpty) return;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Student'),
        ) ??
        0;
    if (count > 0) return;

    await db.transaction((txn) async {
      final majorIds = <String, int>{};
      for (final student in seedStudents) {
        final majorName = student.majorName.trim();
        var majorId = majorIds[majorName];
        if (majorId == null) {
          final existing = await txn.query(
            'Major',
            columns: ['IDMajor'],
            where: 'nameMajor = ?',
            whereArgs: [majorName],
          );
          if (existing.isNotEmpty) {
            majorId = existing.first['IDMajor']! as int;
          } else {
            majorId = await txn.insert('Major', {'nameMajor': majorName});
          }
          majorIds[majorName] = majorId;
        }
        await txn.insert('Student', {
          'name': student.name.trim(),
          'date': student.date.trim(),
          'gender': student.gender.trim(),
          'email': student.email.trim(),
          'Address': student.address.trim(),
          'Phone': student.phone.trim(),
          'idMajor': majorId,
        });
      }
    });
  }

  Future<List<Major>> majors() async {
    final db = await database;
    final rows = await db.query('Major', orderBy: 'nameMajor COLLATE NOCASE');
    return rows.map(Major.fromMap).toList();
  }

  Future<int> insertMajor(String nameMajor) async {
    final db = await database;
    return db.insert('Major', {'nameMajor': nameMajor.trim()});
  }

  Future<void> updateMajor(int idMajor, String nameMajor) async {
    final db = await database;
    await db.update(
      'Major',
      {'nameMajor': nameMajor.trim()},
      where: 'IDMajor = ?',
      whereArgs: [idMajor],
    );
  }

  Future<void> deleteMajor(int idMajor) async {
    final db = await database;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Student WHERE idMajor = ?', [
            idMajor,
          ]),
        ) ??
        0;
    if (count > 0) throw MajorInUseException(count);
    await db.delete('Major', where: 'IDMajor = ?', whereArgs: [idMajor]);
  }

  Future<List<StudentWithMajor>> studentsWithMajor() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        Student.ID AS ID,
        Student.name AS name,
        Student.date AS date,
        Student.gender AS gender,
        Student.email AS email,
        Student.Address AS Address,
        Student.Phone AS Phone,
        Student.idMajor AS idMajor,
        Major.nameMajor AS nameMajor
      FROM Student
      INNER JOIN Major ON Student.idMajor = Major.IDMajor
      ORDER BY Student.name COLLATE NOCASE, Student.ID
    ''');
    return rows.map(StudentWithMajor.fromMap).toList();
  }

  Future<int> insertStudent(StudentInput input) async {
    final db = await database;
    return db.insert('Student', input.toMap());
  }

  Future<void> updateStudent(int id, StudentInput input) async {
    final db = await database;
    await db.update('Student', input.toMap(), where: 'ID = ?', whereArgs: [id]);
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete('Student', where: 'ID = ?', whereArgs: [id]);
  }
}
