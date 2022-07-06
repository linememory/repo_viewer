import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/paginated_repos_list_view.dart';

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
      appBar: AppBar(
        title: const Text('Starred repos'),
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.logoutVariant),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: PaginatedReposListView(
        paginatedReposNotifier: starredReposNotifierProvider,
        getNextPage: (ref) => ref
            .read(starredReposNotifierProvider.notifier)
            .getNextStarredReposPage(),
        noResultsMessage:
            "Thats about everything we could find in your starred repos right now.",
      ),
    );
  }
}
