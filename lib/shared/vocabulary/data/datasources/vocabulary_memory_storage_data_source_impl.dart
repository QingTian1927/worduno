import '../dtos/level_dto.dart';
import '../dtos/term_dto.dart';
import '../dtos/unit_dto.dart';
import 'i_vocabulary_local_data_source.dart';

IVocabularyLocalDataSource createVocabularyStorageDataSource() {
  return VocabularyMemoryStorageDataSourceImpl();
}

class VocabularyMemoryStorageDataSourceImpl
    implements IVocabularyLocalDataSource {
  VocabularyMemoryStorageDataSourceImpl();

  List<LevelDto> _levels = const <LevelDto>[];
  final Map<String, List<UnitDto>> _unitsByLevel = {};
  final Map<String, List<TermDto>> _termsByUnit = {};

  @override
  Future<List<LevelDto>> getLevels() async => List.unmodifiable(_levels);

  @override
  Future<void> saveLevels(List<LevelDto> levels) async {
    _levels = List.unmodifiable(levels);
  }

  @override
  Future<List<UnitDto>> getUnits(String levelCode) async {
    return List.unmodifiable(_unitsByLevel[levelCode] ?? const <UnitDto>[]);
  }

  @override
  Future<void> saveUnits({
    required String levelCode,
    required List<UnitDto> units,
  }) async {
    _unitsByLevel[levelCode] = List.unmodifiable(units);
  }

  @override
  Future<List<TermDto>> getTerms({
    required String levelCode,
    required String unitName,
  }) async {
    return List.unmodifiable(
      _termsByUnit[_termsKey(levelCode, unitName)] ?? const <TermDto>[],
    );
  }

  @override
  Future<void> saveTerms({
    required String levelCode,
    required String unitName,
    required List<TermDto> terms,
  }) async {
    _termsByUnit[_termsKey(levelCode, unitName)] = List.unmodifiable(terms);
  }

  String _termsKey(String levelCode, String unitName) =>
      '$levelCode::$unitName';
}
