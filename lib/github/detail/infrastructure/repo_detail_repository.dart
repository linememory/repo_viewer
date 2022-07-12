import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/detail/infrastructure/github_repo_detail_dto.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_local_service.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_remote_service.dart';

class RepoDetailRepository {
  final RepoDetailLocalService _localService;
  final RepoDetailRemoteService _remoteService;

  RepoDetailRepository(this._localService, this._remoteService);

  Future<Either<GithubFailure, Fresh<GithubRepo?>>> getRepoDetail(
    GithubRepo repo,
  ) async {
    try {
      final htmlRemoteResponse =
          await _remoteService.getReadmeHtml(repo.fullName);
      return right(
        await htmlRemoteResponse.when(
          noConnection: () async {
            return Fresh.no(
              await _localService
                  .getRepoDetail(repo.fullName)
                  .then((dto) => repo.copyWith(readmeHtml: dto?.html)),
            );
          },
          notModified: (_) async {
            final cached = await _localService.getRepoDetail(repo.fullName);

            return Fresh.yes(repo.copyWith(readmeHtml: cached?.html));
          },
          withNewData: (
            html,
            _,
          ) async {
            final dto = GithubRepoDetailDTO(
              fullName: repo.fullName,
              html: html,
            );
            await _localService.upsertRepoDetail(dto);
            return Fresh.yes(repo.copyWith(readmeHtml: dto.html));
          },
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
