import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/detail/application/repo_detail_notifier.dart';
import 'package:shimmer/shimmer.dart';

class RepoDetailPage extends ConsumerStatefulWidget {
  const RepoDetailPage({Key? key, required this.repo}) : super(key: key);

  final GithubRepo repo;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RepoDetailPageState();
}

class _RepoDetailPageState extends ConsumerState<RepoDetailPage> {
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(repoDetailNotifierProvider.notifier)
          .getRepoDetail(widget.repo.fullName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repoDetailNotifierProvider);
    ref.listen<RepoDetailState>(
      repoDetailNotifierProvider,
      (previous, next) {
        next.maybeWhen(
          loadSuccess: (repoDetail, _) {
            if (!repoDetail.isFresh && !hasAlreadyShownNoConnectionToast) {
              hasAlreadyShownNoConnectionToast = true;
              showNoConnectionToast(
                "You are not online. Some information may be outdated.",
                context,
              );
            }
          },
          orElse: () {},
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        if (state.hasStarredStatusChanged) {
          ref
              .read(starredReposNotifierProvider.notifier)
              .getFirstStarredReposPage();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Hero(
                tag: widget.repo.fullName,
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.repo.owner.avatarUrlSmall,
                  ),
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
            state.maybeMap(
              loadSuccess: (state) {
                return IconButton(
                  disabledColor: Theme.of(context).iconTheme.color,
                  onPressed: !state.repoDetail.isFresh
                      ? null
                      : () {
                          ref
                              .read(repoDetailNotifierProvider.notifier)
                              .switchStarredStatus(
                                state.repoDetail.entity!.fullName,
                              );
                        },
                  icon: Icon(
                    !state.repoDetail.isFresh
                        ? MdiIcons.starRemoveOutline
                        : state.repoDetail.entity?.starred == true
                            ? Icons.star
                            : Icons.star_border_outlined,
                  ),
                );
              },
              orElse: () {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade400,
                  highlightColor: Colors.grey.shade600,
                  child: IconButton(
                    disabledColor: Theme.of(context).iconTheme.color,
                    onPressed: null,
                    icon: const Icon(Icons.star),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
