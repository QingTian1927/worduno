import 'package:flutter/foundation.dart';

import '../../../../app/di/injection.dart';
import '../../../../shared/vocabulary/application/services/i_vocabulary_service.dart';
import '../../../../shared/vocabulary/domain/entities/term.dart';
import '../../../../shared/word_state/application/services/i_word_state_service.dart';

class TermListViewModel extends ChangeNotifier {
  TermListViewModel({
    required this.levelCode,
    required this.unitName,
    IVocabularyService? vocabularyService,
    IWordStateService? wordStateService,
  }) : _vocabularyService = vocabularyService ?? getIt<IVocabularyService>(),
       _wordStateService = wordStateService ?? getIt<IWordStateService>();

  final String levelCode;
  final String unitName;
  final IVocabularyService _vocabularyService;
  final IWordStateService _wordStateService;

  bool isLoading = false;
  String? errorMessage;
  List<Term> terms = const [];
  Set<String> starredTermIds = const <String>{};

  String get unitId => '$levelCode::$unitName';

  bool isStarred(Term term) => starredTermIds.contains(_termId(term));

  Future<void> loadTerms({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      terms = await _vocabularyService.getTerms(
        levelCode: levelCode,
        unitName: unitName,
        forceRefresh: forceRefresh,
      );
      await _loadStarredStates();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTerms() => loadTerms(forceRefresh: true);

  Future<void> toggleStar(Term term) async {
    final termId = _termId(term);
    final previous = starredTermIds;
    final next = Set<String>.of(previous);

    if (next.contains(termId)) {
      next.remove(termId);
    } else {
      next.add(termId);
    }

    starredTermIds = next;
    notifyListeners();

    try {
      await _wordStateService.toggleStar(unitId: unitId, termId: termId);
    } catch (error) {
      starredTermIds = previous;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> _loadStarredStates() async {
    final states = await _wordStateService.getByUnit(unitId);
    starredTermIds = states
        .where((state) => state.isStarred)
        .map((state) => state.termId)
        .toSet();
  }

  String _termId(Term term) => term.id.isNotEmpty ? term.id : term.text;
}
