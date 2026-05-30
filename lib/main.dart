import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takturns_flutter_app/core/di/injection_container.dart';
import 'package:takturns_flutter_app/core/router/app_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';

import 'features/home/presentation/bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TakturnsApp());
}

class TakturnsApp extends StatelessWidget {
  const TakturnsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<WalletBloc>()),
        BlocProvider(create: (_) => sl<HomeBloc>())
      ],
      child: MaterialApp.router(
        title: 'TakTurns',
        theme: AppTheme.dark,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
