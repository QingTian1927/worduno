import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase();

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'worduno.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createVocabularyCacheTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
          CREATE TABLE user_word_states (
            unit_id TEXT NOT NULL,
            term_id TEXT NOT NULL,
            is_starred INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'new',
            PRIMARY KEY (unit_id, term_id)
          )
        ''');

    await db.execute('''
          CREATE TABLE exam_history (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            unit_id TEXT NOT NULL,
            score REAL NOT NULL
          )
        ''');

    await db.execute('''
          CREATE TABLE question_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exam_id TEXT NOT NULL,
            type TEXT NOT NULL,
            question TEXT NOT NULL,
            user_answer TEXT NOT NULL,
            correct_answer TEXT NOT NULL,
            FOREIGN KEY (exam_id) REFERENCES exam_history (id)
          )
        ''');

    await db.execute('''
          CREATE TABLE coach_history (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            word TEXT NOT NULL,
            user_sentence TEXT NOT NULL,
            grammar_feedback TEXT NOT NULL,
            vocabulary_feedback TEXT NOT NULL,
            naturalness_feedback TEXT NOT NULL,
            suggestion_feedback TEXT NOT NULL
          )
        ''');

    await _createVocabularyCacheTables(db);
  }

  Future<void> _createVocabularyCacheTables(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_levels (
            code TEXT PRIMARY KEY,
            total_terms INTEGER NOT NULL DEFAULT 0,
            known_terms INTEGER NOT NULL DEFAULT 0,
            position INTEGER NOT NULL DEFAULT 0
          )
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_units (
            level_code TEXT NOT NULL,
            id TEXT NOT NULL,
            name TEXT NOT NULL,
            total_terms INTEGER NOT NULL DEFAULT 0,
            known_terms INTEGER NOT NULL DEFAULT 0,
            position INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (level_code, id)
          )
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_terms (
            level_code TEXT NOT NULL,
            unit_name TEXT NOT NULL,
            id TEXT NOT NULL,
            text TEXT NOT NULL,
            definition TEXT NOT NULL,
            position INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (level_code, unit_name, id)
          )
        ''');
  }
}
