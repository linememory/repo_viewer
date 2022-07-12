import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
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
    required this.onSwitchStarred,
  }) : super(key: key);

  final AutoDisposeStateNotifierProvider<PaginatedReposNotifier,
      PaginatedReposState> paginatedReposNotifier;

  final void Function(WidgetRef ref) getNextPage;

  final String noResultsMessage;
  final VoidCallback onSwitchStarred;

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
                AppLocalizations.of(context)!.paginatedReposListOfflineMessage,
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
          : _PaginatedListView(
              state: state,
              onSwitchStarred: widget.onSwitchStarred,
            ),
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

class _PaginatedListView extends ConsumerWidget {
  const _PaginatedListView({
    Key? key,
    required this.state,
    required this.onSwitchStarred,
  }) : super(key: key);

  final PaginatedReposState state;
  final VoidCallback onSwitchStarred;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fsb = FloatingSearchBar.of(context)?.widget;
    return ListView.builder(
      padding: fsb == null
          ? EdgeInsets.zero
          : EdgeInsets.only(
              top: fsb.height + 8 + MediaQuery.of(context).padding.top,
            ),
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
          loadSuccess: (value) {
            final repo = value.repos.entity[index];
            return RepoTile(
              repo: repo,
              onStarTab: value.repos.isFresh
                  ? () {
                      ref.read(starRepoProvider).switchStarred(
                            repo.fullName,
                            isCurrentlyStarred: repo.starred ?? false,
                          );
                      onSwitchStarred();
                      ref
                          .read(starredReposNotifierProvider.notifier)
                          .getFirstStarredReposPage();
                    }
                  : null,
            );
          },
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
