import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/core/shared/providers.dart';

final initializationProvider = FutureProvider((ref) async {
  await ref.read(sembastProvider).init();
  await Future.delayed(const Duration(seconds: 1));
  await ref.read(authNotifierProvider.notifier).checkAndUpdateAuthStatus();
  return unit;
});

class AppWidget extends ConsumerWidget {
  AppWidget({Key? key}) : super(key: key);

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (previous, next) {});
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeMap(
        unauthenticated: (_) {
          appRouter.pushAndPopUntil(
            const SignInRoute(),
            predicate: (route) => false,
          );
        },
        authenticated: (_) {
          appRouter.pushAndPopUntil(
            const StarredReposRoute(),
            predicate: (route) => false,
          );
        },
        orElse: () {},
      );
    });

    return MaterialApp.router(
      title: 'Repo Viewer',
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}
