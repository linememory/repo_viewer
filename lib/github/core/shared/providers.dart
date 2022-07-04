import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/shared/providers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

final starredReposLocalServiceProvider = Provider<StarredReposLocalService>(
  (ref) {
    return StarredReposLocalService(
      ref.watch(sembastProvider),
    );
  },
);

final githubHeadersCacheProvider = Provider<GithubHeadersCache>(
  (ref) {
    return GithubHeadersCache(
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

final starredReposNotifierProvider =
    StateNotifierProvider<StarredReposNotifier, StarredReposState>(
  (ref) {
    return StarredReposNotifier(
      ref.watch(starredReposRepositoryProvider),
    );
  },
);
