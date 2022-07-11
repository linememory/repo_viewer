import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/detail/application/repo_detail_notifier.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_local_service.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_remote_service.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_repository.dart';

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
    StateNotifierProvider<RepoDetailNotifier, RepoDetailState>((ref) {
  return RepoDetailNotifier(
    ref.watch(repoDetailRepositoryProvider),
  );
});
