import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

part 'starred_repos_notifier.freezed.dart';

class StarredReposNotifier extends StateNotifier<StarredReposState> {
  final StarredReposRepository _repository;
  int _page = 1;

  StarredReposNotifier(this._repository)
      : super(StarredReposState.initial(Fresh.yes([])));

  Future<void> getNextStarredReposPage() async {
    state = StarredReposState.loadInProgress(
      state.repos,
      PaginationConfig.itemsPerPage,
    );

    final failureOrRepos = await _repository.getStarredReposPage(_page);
    state = failureOrRepos.fold(
      (failure) => StarredReposState.loadFailure(state.repos, failure),
      (fresh) {
        _page++;
        return StarredReposState.loadSuccess(
          fresh.copyWith(entity: state.repos.entity + fresh.entity),
          isNextPageAvailable: fresh.isNextPageAvailable ?? false,
        );
      },
    );
  }
}

@freezed
class StarredReposState with _$StarredReposState {
  const factory StarredReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory StarredReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerPage,
  ) = _LoadInProgress;
  const factory StarredReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool isNextPageAvailable,
  }) = _LoadSuccess;
  const factory StarredReposState.loadFailure(
    Fresh<List<GithubRepo>> repos,
    GithubFailure failure,
  ) = _LoadFailure;
}
