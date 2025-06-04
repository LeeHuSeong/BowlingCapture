import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'bowling_app.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE,
              password TEXT
            );
          ''');

          await db.execute('''
            CREATE TABLE analysis_results (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              video_file TEXT,
              pitch_type TEXT,
              accuracy_score REAL,
              dtw_score REAL,
              feedback TEXT,
              timestamp TEXT,
              FOREIGN KEY (user_id) REFERENCES users(id)
            );
          ''');
        },
      );
    } catch (e) {
      print('🚨 DB 초기화 중 오류 발생: $e');
      rethrow; // 앱을 죽이지 않고 에러 로그를 볼 수 있게 함
    }
  }
}
