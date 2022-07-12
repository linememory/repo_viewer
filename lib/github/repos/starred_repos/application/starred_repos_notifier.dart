import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/repo_star_remote_service.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

class StarredReposNotifier extends PaginatedReposNotifier {
  final StarredReposRepository _repository;
  final RepoStarRemoteService _repoStarRemoteService;

  StarredReposNotifier(
    this._repository,
    this._repoStarRemoteService,
  ) : super();

  Future<void> getFirstStarredReposPage() async {
    super.resetState();
    await getNextStarredReposPage();
  }

  Future<void> getNextStarredReposPage() async {
    super.getNextPage(_repository.getStarredReposPage);
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
    final githubRepos = List<GithubRepo>.from(state.repos.entity)
      ..removeWhere((element) => element.fullName == fullRepoName);
    state = state.copyWith(
      repos: state.repos.copyWith(entity: githubRepos),
    );
  }

  Future<void> reload() async {
    await getFirstStarredReposPage();
  }
}
