import 'dart:convert';

import 'package:web/web.dart' as web;

import '../dtos/level_dto.dart';
import '../dtos/term_dto.dart';
import '../dtos/unit_dto.dart';
import 'i_vocabulary_local_data_source.dart';

IVocabularyLocalDataSource createVocabularyStorageDataSource() {
  return VocabularyWebStorageDataSourceImpl();
}

class VocabularyWebStorageDataSourceImpl implements IVocabularyLocalDataSource {
  VocabularyWebStorageDataSourceImpl();

  static const _levelsKey = 'worduno:vocabulary:levels';

  @override
  Future<List<LevelDto>> getLevels() async {
    return _readList(_levelsKey, LevelDto.fromJson);
  }

  @override
  Future<void> saveLevels(List<LevelDto> levels) async {
    _writeList(_levelsKey, levels.map((level) => level.toJson()).toList());
  }

  @override
  Future<List<UnitDto>> getUnits(String levelCode) async {
    return _readList(_unitsKey(levelCode), UnitDto.fromJson);
  }

  @override
  Future<void> saveUnits({
    required String levelCode,
    required List<UnitDto> units,
  }) async {
    _writeList(
      _unitsKey(levelCode),
      units.map((unit) => unit.toJson()).toList(),
    );
  }

  @override
  Future<List<TermDto>> getTerms({
    required String levelCode,
    required String unitName,
  }) async {
    return _readList(_termsKey(levelCode, unitName), TermDto.fromJson);
  }

  @override
  Future<void> saveTerms({
    required String levelCode,
    required String unitName,
    required List<TermDto> terms,
  }) async {
    _writeList(
      _termsKey(levelCode, unitName),
      terms.map((term) => term.toJson()).toList(),
    );
  }

  List<T> _readList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final raw = web.window.localStorage.getItem(key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  void _writeList(String key, List<Map<String, dynamic>> value) {
    web.window.localStorage.setItem(key, jsonEncode(value));
  }

  String _unitsKey(String levelCode) => 'worduno:vocabulary:units:$levelCode';

  String _termsKey(String levelCode, String unitName) =>
      'worduno:vocabulary:terms:$levelCode::$unitName';
}
