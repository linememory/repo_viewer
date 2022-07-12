import 'package:repo_viewer/github/core/infrastructure/repo_star_remote_service.dart';

class StarRepo {
  final RepoStarRemoteService _service;

  StarRepo(this._service);

  Future<void> switchStarred(
    String fullRepoName, {
    required bool isCurrentlyStarred,
  }) async {
    _service.switchStarredStatus(
      fullRepoName,
      isCurrentlyStarred: isCurrentlyStarred,
    );
  }
}
