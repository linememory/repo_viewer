import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/paginated_repos_list_view.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

class SearchedReposPage extends ConsumerStatefulWidget {
  const SearchedReposPage({
    Key? key,
    required this.searchedTerm,
  }) : super(key: key);

  final String searchedTerm;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchedReposPageState();
}

class _SearchedReposPageState extends ConsumerState<SearchedReposPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(searchedReposNotifierProvider.notifier)
          .getFirstSearchedReposPage(widget.searchedTerm),
    );
    // also possible instead of microtask to delay the execution
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.read(searchedReposNotifierProvider.notifier).getNextSearchedReposPage();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        title: widget.searchedTerm,
        hint: AppLocalizations.of(context)!.searchedReposPageSearchHint,
        onSignOutButtonPressed: () =>
            ref.read(authNotifierProvider.notifier).signOut(),
        onShouldNavigateToResultPage: (searchTerm) {
          AutoRouter.of(context).pushAndPopUntil(
            SearchedReposRoute(searchedTerm: searchTerm),
            predicate: (route) {
              return route.settings.name == StarredReposRoute.name;
            },
          );
        },
        body: PaginatedReposListView(
          paginatedReposNotifier: searchedReposNotifierProvider,
          getNextPage: (ref) => ref
              .read(searchedReposNotifierProvider.notifier)
              .getNextSearchedReposPage(widget.searchedTerm),
          noResultsMessage: AppLocalizations.of(context)!
              .searchedReposPageNoResults(widget.searchedTerm),
        ),
      ),
    );
  }
}
