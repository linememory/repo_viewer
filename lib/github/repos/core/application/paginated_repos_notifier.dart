import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';

part 'paginated_repos_notifier.freezed.dart';

typedef RepositoryGetter
    = Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> Function(int page);

class PaginatedReposNotifier extends StateNotifier<PaginatedReposState> {
  int _page = 1;

  PaginatedReposNotifier() : super(PaginatedReposState.initial(Fresh.yes([])));

  @protected
  Future<void> getNextPage(
    RepositoryGetter getter,
  ) async {
    state = PaginatedReposState.loadInProgress(
      state.repos,
      PaginationConfig.itemsPerPage,
    );

    final failureOrRepos = await getter(_page);
    state = failureOrRepos.fold(
      (failure) => PaginatedReposState.loadFailure(state.repos, failure),
      (fresh) {
        _page++;
        return PaginatedReposState.loadSuccess(
          fresh.copyWith(entity: state.repos.entity + fresh.entity),
          isNextPageAvailable: fresh.isNextPageAvailable ?? false,
        );
      },
    );
  }
}

@freezed
class PaginatedReposState with _$PaginatedReposState {
  const factory PaginatedReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory PaginatedReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerPage,
  ) = _LoadInProgress;
  const factory PaginatedReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool isNextPageAvailable,
  }) = _LoadSuccess;
  const factory PaginatedReposState.loadFailure(
    Fresh<List<GithubRepo>> repos,
    GithubFailure failure,
  ) = _LoadFailure;
}
