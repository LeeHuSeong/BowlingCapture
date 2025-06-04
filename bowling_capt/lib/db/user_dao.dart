import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import 'database_helper.dart';

class UserDao {
  // 회원가입
  static Future<int?> signup(String username, String password) async {
    final db = await DatabaseHelper.initDB();

    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
      });
    } catch (e) {
      // UNIQUE 제약 위반 등
      return null;
    }
  }

  // 로그인
  static Future<User?> login(String username, String password) async {
    final db = await DatabaseHelper.initDB();
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }
}
