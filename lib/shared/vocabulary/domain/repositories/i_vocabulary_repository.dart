import '../entities/level.dart';
import '../entities/term.dart';
import '../entities/unit.dart';

abstract class IVocabularyRepository {
  Future<List<Level>> getLevels({bool forceRefresh = false});

  Future<List<Unit>> getUnits(String levelCode, {bool forceRefresh = false});

  Future<List<Term>> getTerms({
    required String levelCode,
    required String unitName,
    bool forceRefresh = false,
  });
}
