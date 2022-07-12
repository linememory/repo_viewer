import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/repo_star_remote_service.dart';

class RepoStarRepository {
  final RepoStarRemoteService _remoteService;

  RepoStarRepository(this._remoteService);

  Future<Either<GithubFailure, Unit?>> switchStarredStatus(
    GithubRepo repoDetail,
  ) async {
    try {
      final actionCompleted = await _remoteService.switchStarredStatus(
        repoDetail.fullName,
        isCurrentlyStarred: repoDetail.starred ?? false,
      );
      return right(actionCompleted);
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
