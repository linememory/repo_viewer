import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';

class RepoTile extends StatelessWidget {
  const RepoTile({
    Key? key,
    required this.repo,
    this.onStarTab,
    required this.onTab,
  }) : super(key: key);

  final GithubRepo repo;
  final VoidCallback? onStarTab;
  final VoidCallback onTab;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: repo.fullName,
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            repo.owner.avatarUrlSmall,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      title: Text(repo.name),
      subtitle: Text(
        repo.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onStarTab,
            icon: (onStarTab == null)
                ? const Icon(MdiIcons.starRemoveOutline)
                : (repo.starred == true)
                    ? const Icon(
                        Icons.star,
                      )
                    : const Icon(
                        Icons.star_border,
                      ),
          ),
          Text(
            repo.stargazersCount.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
      onTap: onTab,
    );
  }
}
