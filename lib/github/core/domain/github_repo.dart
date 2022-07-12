import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/core/domain/user.dart';
part 'github_repo.freezed.dart';

@freezed
class GithubRepo with _$GithubRepo {
  const GithubRepo._();
  const factory GithubRepo({
    required String name,
    required User owner,
    required String description,
    required int stargazersCount,
    bool? starred,
  }) = _GithubRepo;

  String get fullName => '${owner.name}/$name';
}
