import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/search/infrastructure/search_history_repository.dart';

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  SearchHistoryNotifier(this._repository) : super(const AsyncValue.loading());

  final SearchHistoryRepository _repository;

  void watchSearchTerms({String? filter}) {
    _repository.watchSearchTerms(filter: filter).listen((data) {
      state = AsyncValue.data(data);
    }).onError((Object error) {
      AsyncValue.error(error);
    });
  }

  void addTerm(String term) {
    _repository.addSearchTerm(term);
  }

  void deleteTerm(String term) {
    _repository.deleteSearchTerm(term);
  }

  void putSearchTermFirst(String term) { 
    _repository.putSearchTermFirst(term);
  }
}
