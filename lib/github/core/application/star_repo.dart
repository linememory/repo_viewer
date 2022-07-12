import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/repo_star_repository.dart';

class StarRepo {
  final RepoStarRepository _repository;

  StarRepo(this._repository);

  Future<void> switchStarred(GithubRepo repo) async {
    _repository.switchStarredStatus(repo);
  }
}
