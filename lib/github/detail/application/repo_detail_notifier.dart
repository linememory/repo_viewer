import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/detail/domain/github_repo_detail.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_repository.dart';
part 'repo_detail_notifier.freezed.dart';

class RepoDetailNotifier extends StateNotifier<RepoDetailState> {
  RepoDetailNotifier(this._repository) : super(const RepoDetailState.initial());

  final RepoDetailRepository _repository;

  Future<void> getRepoDetail(String fullRepoName) async {
    state = const RepoDetailState.loadInProgress();
    final failureOrRepoDetail = await _repository.getRepoDetail(fullRepoName);
    state = failureOrRepoDetail.fold(
      (l) => RepoDetailState.loadFailure(l),
      (r) => RepoDetailState.loadSuccess(r),
    );
  }

  Future<void> switchStarredStatus(String fullRepoName) async {
    state.maybeMap(
      loadSuccess: (successState) async {
        final stateCopy = successState.copyWith();
        final repoDetail = successState.repoDetail.entity;
        if (repoDetail != null) {
          state = successState.copyWith.repoDetail(
            entity: repoDetail.copyWith(starred: !repoDetail.starred),
          );
          final failureOrSuccess =
              await _repository.switchStarredStatus(repoDetail);
          failureOrSuccess.fold(
            (l) => state = stateCopy,
            (r) => r == null
                ? state = stateCopy
                : state = state.copyWith(hasStarredStatusChanged: true),
          );
        }
      },
      orElse: () {},
    );
  }
}

@freezed
class RepoDetailState with _$RepoDetailState {
  const factory RepoDetailState.initial({
    @Default(false) bool hasStarredStatusChanged,
  }) = _Initial;
  const factory RepoDetailState.loadInProgress({
    @Default(false) bool hasStarredStatusChanged,
  }) = _LoadInProgress;
  const factory RepoDetailState.loadSuccess(
    Fresh<GithubRepoDetail?> repoDetail, {
    @Default(false) bool hasStarredStatusChanged,
  }) = _LoadSuccess;
  const factory RepoDetailState.loadFailure(
    GithubFailure failure, {
    @Default(false) bool hasStarredStatusChanged,
  }) = _LoadFailure;
}
