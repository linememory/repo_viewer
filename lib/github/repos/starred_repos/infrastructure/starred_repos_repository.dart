import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/extensions.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';

class StarredReposRepository {
  final StarredReposRemoteService _remoteService;
  final StarredReposLocalService _localService;

  StarredReposRepository(this._remoteService, this._localService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
    int page,
  ) async {
    try {
      final remotePageItems = await _remoteService.getStarredReposPage(page);
      return right(
        await remotePageItems.when(
          noConnection: () async => Fresh.no(
            await _localService
                .getPage(page)
                .then((value) => value.map((e) => e.toDomain()).toList()),
            isNextPageAvailable: page < await _localService.getLocalPageCount(),
          ),
          notModified: (maxPage) async => Fresh.yes(
            await _localService
                .getPage(page)
                .then((value) => value.map((e) => e.toDomain()).toList()),
            isNextPageAvailable: page < maxPage,
          ),
          withNewData: (data, maxPage) {
            final modifiedData = data
                .map(
                  (e) => e.copyWith(
                    starred: true,
                  ),
                )
                .toList();
            _localService.upsertPage(modifiedData, page);
            return Fresh.yes(
              modifiedData.toDomain(),
              isNextPageAvailable: page < maxPage,
            );
          },
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
