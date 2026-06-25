import '../../domain/entities/level.dart';
import '../../domain/entities/term.dart';
import '../../domain/entities/unit.dart';

abstract class IVocabularyService {
  Future<List<Level>> getLevels({bool forceRefresh = false});

  Future<List<Unit>> getUnits(String levelCode, {bool forceRefresh = false});

  Future<List<Term>> getTerms({
    required String levelCode,
    required String unitName,
    bool forceRefresh = false,
  });
}
