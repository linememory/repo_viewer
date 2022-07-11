import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';

class RepoDetailPage extends ConsumerStatefulWidget {
  const RepoDetailPage({Key? key, required this.repo}) : super(key: key);

  final GithubRepo repo;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RepoDetailPageState();
}

class _RepoDetailPageState extends ConsumerState<RepoDetailPage> {
  @override
  void initState() {
    Future.microtask(
      () => ref
          .read(repoDetailNotifierProvider.notifier)
          .getRepoDetail(widget.repo.fullName),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repoDetailNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: widget.repo.fullName,
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.repo.owner.avatarUrlSmall),
                backgroundColor: Colors.transparent,
                radius: 16,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child:
                  Text(widget.repo.fullName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(repoDetailNotifierProvider.notifier)
                  .switchStarredStatus(widget.repo.fullName);
            },
            icon: Icon(
              state.maybeMap(
                loadSuccess: (value) {
                  return value.repoDetail.entity?.starred ?? false
                      ? Icons.star
                      : Icons.star_border_outlined;
                },
                orElse: () {
                  return Icons.star_border_outlined;
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
