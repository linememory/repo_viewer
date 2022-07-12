import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastructure/dio_extensions.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';

class RepoStarRemoteService {
  final Dio _dio;

  RepoStarRemoteService(this._dio);

  /// Returns 'null' if there is no internet connection.
  Future<bool?> getStarredStatus(String fullRepoName) async {
    final requestUri = Uri.https(
      'api.github.com',
      '/user/starred/$fullRepoName',
    );

    try {
      final response = await _dio.getUri(
        requestUri,
        options: Options(
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 400) || status == 404),
        ),
      );
      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return null;
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }

  /// Returns 'null' if there is no internet connection.
  Future<Unit?> switchStarredStatus(
    String fullRepoName, {
    required bool isCurrentlyStarred,
  }) async {
    final requestUri = Uri.https(
      'api.github.com',
      '/user/starred/$fullRepoName',
    );
    try {
      final response = await (isCurrentlyStarred
          ? _dio.deleteUri(
              requestUri,
            )
          : _dio.putUri(requestUri));
      if (response.statusCode == 204) {
        return unit;
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return null;
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }
}
