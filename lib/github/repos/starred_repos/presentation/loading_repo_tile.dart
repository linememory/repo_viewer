import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingRepoTile extends StatelessWidget {
  const LoadingRepoTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      color: Colors.grey,
    );
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.grey.shade300,
      child: ListTile(
        leading: const CircleAvatar(),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: boxDecoration,
            width: 100,
            height: 14,
          ),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: boxDecoration,
            height: 10,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_outline),
            Text(
              '',
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
