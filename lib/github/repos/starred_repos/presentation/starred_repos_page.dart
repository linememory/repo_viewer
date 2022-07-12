import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/paginated_repos_list_view.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

class StarredReposPage extends ConsumerStatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StarredReposPageState();
}

class _StarredReposPageState extends ConsumerState<StarredReposPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(starredReposNotifierProvider.notifier)
          .getNextStarredReposPage(),
    );
    // also possible instead of microtask to delay the execution
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        title: AppLocalizations.of(context)!.starredReposPageTitle,
        hint: AppLocalizations.of(context)!.starredReposPageSearchHint,
        onShouldNavigateToResultPage: (searchTerm) {
          AutoRouter.of(context)
              .push(SearchedReposRoute(searchedTerm: searchTerm));
        },
        onSignOutButtonPressed: () =>
            ref.read(authNotifierProvider.notifier).signOut(),
        body: PaginatedReposListView(
          paginatedReposNotifier: starredReposNotifierProvider,
          getNextPage: (ref) => ref
              .read(starredReposNotifierProvider.notifier)
              .getNextStarredReposPage(),
          noResultsMessage:
              AppLocalizations.of(context)!.starredReposPageNoResults,
        ),
      ),
    );
  }
}
