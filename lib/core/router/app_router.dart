import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/di/injection_container.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/create_group/create_group_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/group_detail/group_detail_bloc.dart';
import 'package:takturns_flutter_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/join_group/join_group_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/screens/create_group_screen.dart';
import 'package:takturns_flutter_app/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:takturns_flutter_app/features/home/presentation/screens/home_screen.dart';
import 'package:takturns_flutter_app/features/groups/presentation/screens/join_group_screen.dart';
import 'dart:async';
import 'package:takturns_flutter_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/screens/wallet_connect_screen.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_state.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(sl<WalletBloc>().stream),
  redirect: (context, state) {
    final walletState = sl<WalletBloc>().state;
    final isChecking = walletState is WalletInitial || walletState is WalletChecking;
    final isConnected = walletState is WalletConnected;

    final isSplash = state.uri.path == '/';
    final isWallet = state.uri.path == '/wallet';

    if (isChecking) {
      return '/';
    }

    if (!isConnected) {
      // Allow joining routes if there was an auth guard exception needed,
      // but usually everything requires auth.
      if (state.uri.path != '/wallet') {
        return '/wallet';
      }
    } else {
      if (isSplash || isWallet) {
        return '/home';
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/wallet',
      name: 'wallet',
      builder: (context, state) => const WalletConnectScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<HomeBloc>(),
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/create-group',
      name: 'create-group',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CreateGroupBloc>(),
        child: const CreateGroupScreen(),
      ),
    ),
    GoRoute(
      path: '/join-group',
      name: 'join-group',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BlocProvider(
          create: (_) => sl<JoinGroupBloc>(),
          child: JoinGroupScreen(
            initialAddress: state.uri.queryParameters['address'],
          ),
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
      ),
    ),
    GoRoute(
      path: '/group/:address',
      name: 'group-detail',
      builder: (context, state) {
        final address = state.pathParameters['address']!;
        return BlocProvider(
          create: (_) => sl<GroupDetailBloc>(),
          child: GroupDetailScreen(groupAddress: address),
        );
      },
    ),
  ],
);
