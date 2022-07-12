import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/repo_star_remote_service.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/extensions.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_remote_service.dart';

class SearchedReposRepository {
  final SearchedReposRemoteService _remoteService;
  final RepoStarRemoteService _starRemoteService;

  SearchedReposRepository(this._remoteService, this._starRemoteService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getSearchedReposPage(
    String query,
    int page,
  ) async {
    try {
      final remotePageItems = await _remoteService.getSearchedReposPage(
        query,
        page,
      );
      return right(
        await remotePageItems.maybeWhen(
          withNewData: (data, maxPage) async {
            final modifiedData = await Future.wait(
              data
                  .map(
                    (e) async => e.copyWith(
                      starred: await _starRemoteService
                          .getStarredStatus('${e.owner.name}/${e.name}'),
                    ),
                  )
                  .toList(),
            );
            return Fresh.yes(
              modifiedData.toDomain(),
              isNextPageAvailable: page < maxPage,
            );
          },
          orElse: () => Fresh.no([], isNextPageAvailable: false),
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
