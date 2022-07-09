import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({
    Key? key,
    required this.body,
    required this.title,
    required this.hint,
    required this.onShouldNavigateToResultPage,
    required this.onSignOutButtonPressed,
  }) : super(key: key);

  final String title;
  final String hint;
  final Widget body;
  final void Function(String searchTerm) onShouldNavigateToResultPage;
  final void Function() onSignOutButtonPressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late FloatingSearchBarController _controller;
  @override
  void initState() {
    super.initState();
    _controller = FloatingSearchBarController();
    Future.microtask(
      () => ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms(),
    );
  }

  void pushPageAndPutFirstInHistory(String searchTerm) {
    _controller.close();
    widget.onShouldNavigateToResultPage(searchTerm);
    ref
        .read(searchHistoryNotifierProvider.notifier)
        .putSearchTermFirst(searchTerm);
  }

  void pushPageAndAddToHistory(String searchTerm) {
    _controller.close();
    widget.onShouldNavigateToResultPage(searchTerm);
    ref.read(searchHistoryNotifierProvider.notifier).addTerm(searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: _controller,
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          child: IconButton(
            splashRadius: 18,
            onPressed: () {
              widget.onSignOutButtonPressed();
            },
            icon: const Icon(
              MdiIcons.logout,
            ),
          ),
        )
      ],
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Tap to search 👆',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      hint: widget.hint,
      onSubmitted: (value) {
        pushPageAndAddToHistory(value);
      },
      onQueryChanged: (query) {
        ref
            .read(searchHistoryNotifierProvider.notifier)
            .watchSearchTerms(filter: query);
      },
      body: FloatingSearchBarScrollNotifier(
        child: widget.body,
      ),
      builder: (context, transition) {
        void pushPageAndPutFirstInHistory(String searchTerm) {
          _controller.close();
          widget.onShouldNavigateToResultPage(searchTerm);
          ref
              .read(searchHistoryNotifierProvider.notifier)
              .putSearchTermFirst(searchTerm);
        }

        final searchHistoryState = ref.watch(searchHistoryNotifierProvider);
        return Card(
          clipBehavior: Clip.hardEdge,
          elevation: 4,
          child: searchHistoryState.map(
            data: (history) {
              if (_controller.query.isEmpty && history.value.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  height: 56,
                  child: Text(
                    'Start searching',
                    style: Theme.of(context).textTheme.caption,
                  ),
                );
              } else if (history.value.isEmpty) {
                return ListTile(
                  title: Text(
                    _controller.query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.search),
                  onTap: () {
                    pushPageAndPutFirstInHistory(_controller.query);
                  },
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: history.value
                      .map(
                        (term) => ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(
                            term,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              ref
                                  .read(searchHistoryNotifierProvider.notifier)
                                  .deleteTerm(term);
                            },
                            icon: const Icon(Icons.clear),
                          ),
                          onTap: () {
                            pushPageAndPutFirstInHistory(term);
                          },
                        ),
                      )
                      .toList(),
                );
              }
            },
            loading: (loading) {
              return const ListTile(
                title: LinearProgressIndicator(),
              );
            },
            error: (error) {
              // shouldn't occur
              return ListTile(
                title: Text('Unexpected error $error'),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
