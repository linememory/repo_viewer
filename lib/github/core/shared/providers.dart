import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/shared/providers.dart';
import 'package:repo_viewer/github/core/application/star_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/repo_star_remote_service.dart';
import 'package:repo_viewer/github/detail/application/repo_detail_notifier.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_local_service.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_remote_service.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_repository.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repos/application/searched_repos_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_remote_service.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_repository.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

final githubHeadersCacheProvider = Provider<GithubHeadersCache>(
  (ref) {
    return GithubHeadersCache(
      ref.watch(sembastProvider),
    );
  },
);

final starredReposLocalServiceProvider = Provider<StarredReposLocalService>(
  (ref) {
    return StarredReposLocalService(
      ref.watch(sembastProvider),
    );
  },
);

final starredReposRemoteServiceProvider = Provider<StarredReposRemoteService>(
  (ref) {
    return StarredReposRemoteService(
      ref.watch(dioProvider),
      ref.watch(githubHeadersCacheProvider),
    );
  },
);

final starredReposRepositoryProvider = Provider<StarredReposRepository>(
  (ref) {
    return StarredReposRepository(
      ref.watch(starredReposRemoteServiceProvider),
      ref.watch(starredReposLocalServiceProvider),
    );
  },
);

final starredReposNotifierProvider = StateNotifierProvider.autoDispose<
    StarredReposNotifier, PaginatedReposState>(
  (ref) {
    return StarredReposNotifier(
      ref.watch(starredReposRepositoryProvider),
    );
  },
);

final searchedReposRemoteServiceProvider = Provider<SearchedReposRemoteService>(
  (ref) {
    return SearchedReposRemoteService(
      ref.watch(dioProvider),
      ref.watch(githubHeadersCacheProvider),
    );
  },
);

final repoStarRemoteServiceProvider = Provider<RepoStarRemoteService>((ref) {
  return RepoStarRemoteService(
    ref.watch(dioProvider),
  );
});

final searchedReposRepositoryProvider = Provider<SearchedReposRepository>(
  (ref) {
    return SearchedReposRepository(
      ref.watch(searchedReposRemoteServiceProvider),
      ref.watch(repoStarRemoteServiceProvider),
    );
  },
);

final searchedReposNotifierProvider = StateNotifierProvider.autoDispose<
    SearchedReposNotifier, PaginatedReposState>(
  (ref) {
    return SearchedReposNotifier(
      ref.watch(searchedReposRepositoryProvider),
    );
  },
);

final repoDetailLocalServiceProvider = Provider<RepoDetailLocalService>((ref) {
  return RepoDetailLocalService(
    ref.watch(sembastProvider),
    ref.watch(githubHeadersCacheProvider),
  );
});

final repoDetailRemoteServiceProvider =
    Provider<RepoDetailRemoteService>((ref) {
  return RepoDetailRemoteService(
    ref.watch(dioProvider),
    ref.watch(githubHeadersCacheProvider),
  );
});

final repoDetailRepositoryProvider = Provider<RepoDetailRepository>((ref) {
  return RepoDetailRepository(
    ref.watch(repoDetailLocalServiceProvider),
    ref.watch(repoDetailRemoteServiceProvider),
  );
});

final repoDetailNotifierProvider =
    StateNotifierProvider.autoDispose<RepoDetailNotifier, RepoDetailState>(
        (ref) {
  return RepoDetailNotifier(
    ref.watch(repoDetailRepositoryProvider),
  );
});

final starRepoProvider = Provider<StarRepo>((ref) {
  return StarRepo(
    ref.watch(repoStarRemoteServiceProvider),
  );
});
