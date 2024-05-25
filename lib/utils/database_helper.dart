import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'debatex.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT,
        profileImagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_data (
        id INTEGER PRIMARY KEY,
        lessonId INTEGER,
        lastReadSection INTEGER,
        isCompleted BOOLEAN
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_subsections (
        id INTEGER PRIMARY KEY,
        lessonId INTEGER,
        subsectionId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_quizzes (
        id INTEGER PRIMARY KEY,
        lessonId INTEGER,
        quizId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE analysis_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        thumbnail TEXT,
        ai_report TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE completed_quizzes (
          id INTEGER PRIMARY KEY,
          lessonId INTEGER,
          quizId INTEGER
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE analysis_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          thumbnail TEXT,
          ai_report TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE user_profile (
          id INTEGER PRIMARY KEY,
          name TEXT,
        )
      ''');
    }
  }

  Future<bool> tableExists(Database db, String tableName) async {
    final result = await db.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name=?
    ''', [tableName]);
    return result.isNotEmpty;
  }

  Future<bool> userProfileExists() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('user_profile', limit: 1);
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('user_profile', limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> saveUserProfile(String name) async {
    Database db = await instance.database;
    await db.insert(
      'user_profile',
      {
        'name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> fetchUserData(int lessonId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'user_data',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  Future<List<int>> fetchCompletedSubsections(int lessonId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'completed_subsections',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );

    return result.map((map) => map['subsectionId'] as int).toList();
  }

  Future<void> markSubsectionCompleted(int lessonId, int subsectionId) async {
    Database db = await instance.database;
    await db.insert(
      'completed_subsections',
      {
        'lessonId': lessonId,
        'subsectionId': subsectionId,
      },
    );
  }

  Future<List<int>> fetchCompletedQuizzes(int lessonId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'completed_quizzes',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );

    return result.map((map) => map['quizId'] as int).toList();
  }

  Future<void> markQuizCompleted(int lessonId, int quizId) async {
    Database db = await instance.database;
    await db.insert(
      'completed_quizzes',
      {
        'lessonId': lessonId,
        'quizId': quizId,
      },
    );
  }

  Future<void> updateUserData(int lessonId, int lastReadSection, bool isCompleted) async {
    Database db = await instance.database;
    await db.insert(
      'user_data',
      {
        'lessonId': lessonId,
        'lastReadSection': lastReadSection,
        'isCompleted': isCompleted ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> resetLessonProgress(int lessonId) async {
    Database db = await instance.database;
    await db.delete(
      'user_data',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    await db.delete(
      'completed_subsections',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    await db.delete(
      'completed_quizzes',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
  }

  Future<void> saveAnalysis(String title, String thumbnail, String aiReport) async {
    Database db = await instance.database;
    await db.insert(
      'analysis_history',
      {
        'title': title,
        'thumbnail': thumbnail,
        'ai_report': aiReport,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAnalysisHistory() async {
    Database db = await instance.database;
    return await db.query('analysis_history');
  }
}
