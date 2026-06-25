import '../dtos/level_dto.dart';
import '../dtos/term_dto.dart';
import '../dtos/unit_dto.dart';

abstract class IVocabularyLocalDataSource {
  Future<List<LevelDto>> getLevels();

  Future<void> saveLevels(List<LevelDto> levels);

  Future<List<UnitDto>> getUnits(String levelCode);

  Future<void> saveUnits({
    required String levelCode,
    required List<UnitDto> units,
  });

  Future<List<TermDto>> getTerms({
    required String levelCode,
    required String unitName,
  });

  Future<void> saveTerms({
    required String levelCode,
    required String unitName,
    required List<TermDto> terms,
  });
}
