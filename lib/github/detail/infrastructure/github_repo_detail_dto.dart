import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/detail/domain/github_repo_detail.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

part 'github_repo_detail_dto.freezed.dart';
part 'github_repo_detail_dto.g.dart';

@freezed
class GithubRepoDetailDTO with _$GithubRepoDetailDTO {
  const factory GithubRepoDetailDTO({
    required String fullName,
    required String html,
    required bool starred,
  }) = _GithubRepoDetailDTO;

  factory GithubRepoDetailDTO.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDetailDTOFromJson(json);

  GithubRepoDetail toDomain() => GithubRepoDetail(
        fullName: fullName,
        html: html,
        starred: starred,
      );

  static const lastUsedFieldName = 'lastUsed';

  Map<String, dynamic> toSembast() {
    return toJson()
      ..remove('fullName')
      ..addAll({lastUsedFieldName: Timestamp.now()});
  }

  factory GithubRepoDetailDTO.fromSembast(
    RecordSnapshot<String, Map<String, dynamic>> snapshot,
  ) {
    final json = Map<String, dynamic>.from(snapshot.value)
      ..['fullName'] = snapshot.key;
    return GithubRepoDetailDTO.fromJson(json);
  }
}
