import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/failure_repo_tile.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/loading_repo_tile.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile.dart';

class PaginatedReposListView extends ConsumerStatefulWidget {
  const PaginatedReposListView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaginatedReposListViewState();
}

class _PaginatedReposListViewState
    extends ConsumerState<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(starredReposNotifierProvider);

    ref.listen<StarredReposState>(
      starredReposNotifierProvider,
      (previous, next) {
        next.map(
          initial: (value) => canLoadNextPage = true,
          loadInProgress: (value) => canLoadNextPage = false,
          loadSuccess: (value) {
            if (!value.repos.isFresh && !hasAlreadyShownNoConnectionToast) {
              hasAlreadyShownNoConnectionToast = true;
              showNoConnectionToast(
                "You are not online. Some information may be outdated.",
                context,
              );
            }
            return canLoadNextPage = value.isNextPageAvailable;
          },
          loadFailure: (value) => canLoadNextPage = false,
        );
      },
    );
    return NotificationListener<ScrollNotification>(
      child: state.maybeWhen(
        loadSuccess: (repos, isNextPageAvailable) => repos.entity.isEmpty,
        orElse: () => false,
      )
          ? const NoResultsDisplay(
              message:
                  "Thats about everything we could find in your starred repos right now.",
            )
          : _PaginatedListView(state: state),
      onNotification: (notification) {
        final metrics = notification.metrics;
        final limit = metrics.maxScrollExtent - metrics.viewportDimension / 3;
        if (canLoadNextPage && metrics.pixels >= limit) {
          canLoadNextPage = false;
          ref
              .read(starredReposNotifierProvider.notifier)
              .getNextStarredReposPage();
        }
        return false;
      },
    );
  }
}

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final StarredReposState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.map(
        initial: (value) => 0,
        loadInProgress: (value) =>
            value.repos.entity.length + value.itemsPerPage,
        loadSuccess: (value) => value.repos.entity.length,
        loadFailure: (value) => value.repos.entity.length + 1,
      ),
      itemBuilder: (context, index) {
        return state.map(
          initial: (value) => RepoTile(
            repo: value.repos.entity[index],
          ),
          loadInProgress: (value) {
            if (index < value.repos.entity.length) {
              return RepoTile(
                repo: value.repos.entity[index],
              );
            } else {
              return const LoadingRepoTile();
            }
          },
          loadSuccess: (value) => RepoTile(
            repo: value.repos.entity[index],
          ),
          loadFailure: (value) {
            if (index < value.repos.entity.length) {
              return RepoTile(
                repo: value.repos.entity[index],
              );
            } else {
              return FailureRepoTile(failure: value.failure);
            }
          },
        );
      },
    );
  }
}
