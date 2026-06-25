import '../../domain/entities/level.dart';
import '../../domain/entities/term.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/i_vocabulary_repository.dart';
import 'i_vocabulary_service.dart';

class VocabularyServiceImpl implements IVocabularyService {
  VocabularyServiceImpl(this._repository);

  final IVocabularyRepository _repository;
  List<Level>? _levelsCache;
  final Map<String, List<Unit>> _unitsCache = {};
  final Map<String, List<Term>> _termsCache = {};

  @override
  Future<List<Level>> getLevels({bool forceRefresh = false}) async {
    if (!forceRefresh && _levelsCache != null) {
      return _levelsCache!;
    }

    final levels = await _repository.getLevels(forceRefresh: forceRefresh);
    _levelsCache = levels;
    return levels;
  }

  @override
  Future<List<Unit>> getUnits(
    String levelCode, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _unitsCache.containsKey(levelCode)) {
      return _unitsCache[levelCode]!;
    }

    final units = await _repository.getUnits(
      levelCode,
      forceRefresh: forceRefresh,
    );
    _unitsCache[levelCode] = units;
    return units;
  }

  @override
  Future<List<Term>> getTerms({
    required String levelCode,
    required String unitName,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$levelCode::$unitName';
    if (!forceRefresh && _termsCache.containsKey(cacheKey)) {
      return _termsCache[cacheKey]!;
    }

    final terms = await _repository.getTerms(
      levelCode: levelCode,
      unitName: unitName,
      forceRefresh: forceRefresh,
    );
    _termsCache[cacheKey] = terms;
    return terms;
  }
}
