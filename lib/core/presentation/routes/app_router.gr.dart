// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;

import '../../../auth/presentation/authorization_page.dart' as _i5;
import '../../../auth/presentation/sign_in_page.dart' as _i2;
import '../../../github/core/domain/github_repo.dart' as _i9;
import '../../../github/detail/presentation/repo_detail_page.dart' as _i6;
import '../../../github/repos/searched_repos/presentation/searched_repos_page.dart'
    as _i4;
import '../../../github/repos/starred_repos/presentation/starred_repos_page.dart'
    as _i3;
import '../../../splash/presentation/splash_page.dart' as _i1;

class AppRouter extends _i7.RootStackRouter {
  AppRouter([_i8.GlobalKey<_i8.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    SplashRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.SplashPage());
    },
    SignInRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.SignInPage());
    },
    StarredReposRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.StarredReposPage());
    },
    SearchedReposRoute.name: (routeData) {
      final args = routeData.argsAs<SearchedReposRouteArgs>();
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i4.SearchedReposPage(
              key: args.key, searchedTerm: args.searchedTerm));
    },
    AuthorizationRoute.name: (routeData) {
      final args = routeData.argsAs<AuthorizationRouteArgs>();
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i5.AuthorizationPage(
              key: args.key,
              authorizationUrl: args.authorizationUrl,
              onAuthorizationCodeRedirectAttempt:
                  args.onAuthorizationCodeRedirectAttempt));
    },
    RepoDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RepoDetailRouteArgs>();
      return _i7.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i6.RepoDetailPage(key: args.key, repo: args.repo));
    }
  };

  @override
  List<_i7.RouteConfig> get routes => [
        _i7.RouteConfig(SplashRoute.name, path: '/'),
        _i7.RouteConfig(SignInRoute.name, path: '/sign-in'),
        _i7.RouteConfig(StarredReposRoute.name, path: '/starred'),
        _i7.RouteConfig(SearchedReposRoute.name, path: '/search'),
        _i7.RouteConfig(AuthorizationRoute.name, path: '/authorization'),
        _i7.RouteConfig(RepoDetailRoute.name, path: '/detail')
      ];
}

/// generated route for
/// [_i1.SplashPage]
class SplashRoute extends _i7.PageRouteInfo<void> {
  const SplashRoute() : super(SplashRoute.name, path: '/');

  static const String name = 'SplashRoute';
}

/// generated route for
/// [_i2.SignInPage]
class SignInRoute extends _i7.PageRouteInfo<void> {
  const SignInRoute() : super(SignInRoute.name, path: '/sign-in');

  static const String name = 'SignInRoute';
}

/// generated route for
/// [_i3.StarredReposPage]
class StarredReposRoute extends _i7.PageRouteInfo<void> {
  const StarredReposRoute() : super(StarredReposRoute.name, path: '/starred');

  static const String name = 'StarredReposRoute';
}

/// generated route for
/// [_i4.SearchedReposPage]
class SearchedReposRoute extends _i7.PageRouteInfo<SearchedReposRouteArgs> {
  SearchedReposRoute({_i8.Key? key, required String searchedTerm})
      : super(SearchedReposRoute.name,
            path: '/search',
            args: SearchedReposRouteArgs(key: key, searchedTerm: searchedTerm));

  static const String name = 'SearchedReposRoute';
}

class SearchedReposRouteArgs {
  const SearchedReposRouteArgs({this.key, required this.searchedTerm});

  final _i8.Key? key;

  final String searchedTerm;

  @override
  String toString() {
    return 'SearchedReposRouteArgs{key: $key, searchedTerm: $searchedTerm}';
  }
}

/// generated route for
/// [_i5.AuthorizationPage]
class AuthorizationRoute extends _i7.PageRouteInfo<AuthorizationRouteArgs> {
  AuthorizationRoute(
      {_i8.Key? key,
      required Uri authorizationUrl,
      required void Function(Uri) onAuthorizationCodeRedirectAttempt})
      : super(AuthorizationRoute.name,
            path: '/authorization',
            args: AuthorizationRouteArgs(
                key: key,
                authorizationUrl: authorizationUrl,
                onAuthorizationCodeRedirectAttempt:
                    onAuthorizationCodeRedirectAttempt));

  static const String name = 'AuthorizationRoute';
}

class AuthorizationRouteArgs {
  const AuthorizationRouteArgs(
      {this.key,
      required this.authorizationUrl,
      required this.onAuthorizationCodeRedirectAttempt});

  final _i8.Key? key;

  final Uri authorizationUrl;

  final void Function(Uri) onAuthorizationCodeRedirectAttempt;

  @override
  String toString() {
    return 'AuthorizationRouteArgs{key: $key, authorizationUrl: $authorizationUrl, onAuthorizationCodeRedirectAttempt: $onAuthorizationCodeRedirectAttempt}';
  }
}

/// generated route for
/// [_i6.RepoDetailPage]
class RepoDetailRoute extends _i7.PageRouteInfo<RepoDetailRouteArgs> {
  RepoDetailRoute({_i8.Key? key, required _i9.GithubRepo repo})
      : super(RepoDetailRoute.name,
            path: '/detail', args: RepoDetailRouteArgs(key: key, repo: repo));

  static const String name = 'RepoDetailRoute';
}

class RepoDetailRouteArgs {
  const RepoDetailRouteArgs({this.key, required this.repo});

  final _i8.Key? key;

  final _i9.GithubRepo repo;

  @override
  String toString() {
    return 'RepoDetailRouteArgs{key: $key, repo: $repo}';
  }
}
