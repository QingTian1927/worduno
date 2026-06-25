import 'i_vocabulary_local_data_source.dart';
import 'vocabulary_memory_storage_data_source_impl.dart'
    if (dart.library.html) 'vocabulary_web_storage_data_source_impl.dart';

IVocabularyLocalDataSource createVocabularyLocalStorageDataSource() {
  return createVocabularyStorageDataSource();
}
