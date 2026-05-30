import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/di/injection_container.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/create_group_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/group_detail_bloc.dart';
import 'package:takturns_flutter_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/join_group_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/screens/create_group_screen.dart';
import 'package:takturns_flutter_app/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:takturns_flutter_app/features/home/presentation/screens/home_screen.dart';
import 'package:takturns_flutter_app/features/groups/presentation/screens/join_group_screen.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/screens/wallet_connect_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/wallet',
  routes: [
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
