import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/core/presentation/failure_repo_tile.dart';
import 'package:repo_viewer/github/repos/core/presentation/loading_repo_tile.dart';
import 'package:repo_viewer/github/repos/core/presentation/repo_tile.dart';

class PaginatedReposListView extends ConsumerStatefulWidget {
  const PaginatedReposListView({
    Key? key,
    required this.paginatedReposNotifier,
    required this.getNextPage,
    required this.noResultsMessage,
  }) : super(key: key);

  final StateNotifierProvider<PaginatedReposNotifier, PaginatedReposState>
      paginatedReposNotifier;

  final void Function(WidgetRef ref) getNextPage;

  final String noResultsMessage;

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
    final state = ref.watch(widget.paginatedReposNotifier);

    ref.listen<PaginatedReposState>(
      widget.paginatedReposNotifier,
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
          ? NoResultsDisplay(
              message: widget.noResultsMessage,
            )
          : _PaginatedListView(state: state),
      onNotification: (notification) {
        final metrics = notification.metrics;
        final limit = metrics.maxScrollExtent - metrics.viewportDimension / 3;
        if (canLoadNextPage && metrics.pixels >= limit) {
          canLoadNextPage = false;
          widget.getNextPage(ref);
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

  final PaginatedReposState state;

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
