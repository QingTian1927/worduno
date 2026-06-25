import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../dtos/level_dto.dart';
import '../dtos/term_dto.dart';
import '../dtos/unit_dto.dart';
import 'i_vocabulary_local_data_source.dart';

class VocabularyLocalDataSourceImpl implements IVocabularyLocalDataSource {
  VocabularyLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<LevelDto>> getLevels() async {
    final db = await _database.database;
    final rows = await db.query('cached_levels', orderBy: 'position ASC');
    return rows.map(_levelFromRow).toList(growable: false);
  }

  @override
  Future<void> saveLevels(List<LevelDto> levels) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('cached_levels');
      final batch = txn.batch();
      for (final entry in levels.asMap().entries) {
        batch.insert('cached_levels', {
          'code': entry.value.code,
          'total_terms': entry.value.totalTerms,
          'known_terms': entry.value.knownTerms,
          'position': entry.key,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<UnitDto>> getUnits(String levelCode) async {
    final db = await _database.database;
    final rows = await db.query(
      'cached_units',
      where: 'level_code = ?',
      whereArgs: [levelCode],
      orderBy: 'position ASC',
    );
    return rows.map(_unitFromRow).toList(growable: false);
  }

  @override
  Future<void> saveUnits({
    required String levelCode,
    required List<UnitDto> units,
  }) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'cached_units',
        where: 'level_code = ?',
        whereArgs: [levelCode],
      );
      final batch = txn.batch();
      for (final entry in units.asMap().entries) {
        final unit = entry.value;
        batch.insert('cached_units', {
          'level_code': levelCode,
          'id': unit.id,
          'name': unit.name,
          'total_terms': unit.totalTerms,
          'known_terms': unit.knownTerms,
          'position': entry.key,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<TermDto>> getTerms({
    required String levelCode,
    required String unitName,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'cached_terms',
      where: 'level_code = ? AND unit_name = ?',
      whereArgs: [levelCode, unitName],
      orderBy: 'position ASC',
    );
    return rows.map(_termFromRow).toList(growable: false);
  }

  @override
  Future<void> saveTerms({
    required String levelCode,
    required String unitName,
    required List<TermDto> terms,
  }) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'cached_terms',
        where: 'level_code = ? AND unit_name = ?',
        whereArgs: [levelCode, unitName],
      );
      final batch = txn.batch();
      for (final entry in terms.asMap().entries) {
        final term = entry.value;
        batch.insert('cached_terms', {
          'level_code': levelCode,
          'unit_name': unitName,
          'id': term.id,
          'text': term.text,
          'definition': term.definition,
          'position': entry.key,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  LevelDto _levelFromRow(Map<String, Object?> row) {
    return LevelDto(
      code: row['code']! as String,
      totalTerms: row['total_terms'] as int? ?? 0,
      knownTerms: row['known_terms'] as int? ?? 0,
    );
  }

  UnitDto _unitFromRow(Map<String, Object?> row) {
    return UnitDto(
      id: row['id']! as String,
      name: row['name']! as String,
      totalTerms: row['total_terms'] as int? ?? 0,
      knownTerms: row['known_terms'] as int? ?? 0,
    );
  }

  TermDto _termFromRow(Map<String, Object?> row) {
    return TermDto(
      id: row['id']! as String,
      text: row['text']! as String,
      definition: row['definition']! as String,
    );
  }
}
