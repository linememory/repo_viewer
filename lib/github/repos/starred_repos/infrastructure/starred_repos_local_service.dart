import 'package:collection/collection.dart';
import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:sembast/sembast.dart';

class StarredReposLocalService {
  final SembastDatabase _sembastDatabase;
  final _store = intMapStoreFactory.store('starredRepos');

  StarredReposLocalService(this._sembastDatabase);

  Future<void> upsertPage(List<GithubRepoDTO> dtos, int page) async {
    final sembastPage = page - 1;
    final keys = dtos
        .mapIndexed(
          (index, _) => index + PaginationConfig.perPage * sembastPage,
        )
        .toList();
    await _store
        .records(keys)
        .put(_sembastDatabase.instance, dtos.map((e) => e.toJson()).toList());
  }

  Future<List<GithubRepoDTO>> getPage(int page) async {
    final sembastPage = page - 1;

    final records = await _store.find(
      _sembastDatabase.instance,
      finder: Finder(limit: PaginationConfig.perPage, offset: PaginationConfig.perPage * sembastPage),
    );
    return records.map((e) => GithubRepoDTO.fromJson(e.value)).toList();
  }
}
