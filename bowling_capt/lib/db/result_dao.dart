import 'package:sqflite/sqflite.dart';
import '../models/analysis_result.dart';
import 'database_helper.dart';

class ResultDao {
  static Future<List<AnalysisResult>> getResultsByUserId(int userId) async {
    final db = await DatabaseHelper.initDB();
    final res = await db.query(
      'analysis_results',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return res.map((e) => AnalysisResult.fromMap(e)).toList();
  }

  static Future<void> insertResult(AnalysisResult result) async {
    final db = await DatabaseHelper.initDB();
    await db.insert('analysis_results', result.toMap());
  }

  static Future<void> deleteResult(int id) async {
    final db = await DatabaseHelper.initDB();
    await db.delete(
      'analysis_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
