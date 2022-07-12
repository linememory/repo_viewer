import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

part 'github_repo_detail_dto.freezed.dart';
part 'github_repo_detail_dto.g.dart';

@freezed
class GithubRepoDetailDTO with _$GithubRepoDetailDTO {
  const GithubRepoDetailDTO._();
  const factory GithubRepoDetailDTO({
    required String fullName,
    required String html,
  }) = _GithubRepoDetailDTO;

  factory GithubRepoDetailDTO.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDetailDTOFromJson(json);

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
