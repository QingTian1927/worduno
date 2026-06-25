import '../../domain/entities/user_word_state.dart';
import 'i_word_state_local_data_source.dart';

class WordStateMemoryDataSourceImpl implements IWordStateLocalDataSource {
  WordStateMemoryDataSourceImpl();

  final Map<String, Map<String, UserWordState>> _statesByUnit = {};

  @override
  Future<List<UserWordState>> getByUnit(String unitId) async {
    return List<UserWordState>.unmodifiable(
      _statesByUnit[unitId]?.values ?? const <UserWordState>[],
    );
  }

  @override
  Future<UserWordState?> getByTerm({
    required String unitId,
    required String termId,
  }) async {
    return _statesByUnit[unitId]?[termId];
  }

  @override
  Future<void> upsert(UserWordState state) async {
    final unitStates = _statesByUnit.putIfAbsent(
      state.unitId,
      () => <String, UserWordState>{},
    );
    unitStates[state.termId] = state;
  }
}
