import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';

class FailureRepoTile extends ConsumerWidget {
  const FailureRepoTile({
    Key? key,
    required this.failure,
  }) : super(key: key);

  final GithubFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTileTheme(
      textColor: Theme.of(context).colorScheme.onError,
      iconColor: Theme.of(context).colorScheme.onError,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).errorColor,
        child: ListTile(
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.warning,
            ),
          ),
          title: const Text(
            'An error occurred, please retry',
          ),
          subtitle: Text(
            failure.map(
              api: (value) => 'API returned ${failure.errorCode}',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () {
              ref
                  .read(starredReposNotifierProvider.notifier)
                  .getNextStarredReposPage();
            },
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }
}
