import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/repo_star_remote_service.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_repository.dart';

class SearchedReposNotifier extends PaginatedReposNotifier {
  final SearchedReposRepository _repository;
  final RepoStarRemoteService _repoStarRemoteService;

  SearchedReposNotifier(
    this._repository,
    this._repoStarRemoteService,
  ) : super();

  Future<void> getFirstSearchedReposPage(String query) async {
    super.resetState();
    await getNextSearchedReposPage(query);
  }

  Future<void> getNextSearchedReposPage(String query) async {
    super.getNextPage((page) => _repository.getSearchedReposPage(query, page));
  }

  @override
  Future<void> switchStarred(
    String fullRepoName, {
    required bool isCurrentlyStarred,
  }) async {
    _repoStarRemoteService.switchStarredStatus(
      fullRepoName,
      isCurrentlyStarred: isCurrentlyStarred,
    );
    final githubRepos = List<GithubRepo>.from(state.repos.entity);

    final index =
        githubRepos.indexWhere((element) => element.fullName == fullRepoName);
    githubRepos[index] =
        githubRepos[index].copyWith(starred: !isCurrentlyStarred);
    state = state.copyWith(
      repos: state.repos.copyWith(entity: githubRepos),
    );
  }

  Future<void> reload(String? query) async {
    getFirstSearchedReposPage(query ?? "");
  }
}
