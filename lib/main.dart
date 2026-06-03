import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takturns_flutter_app/core/di/injection_container.dart';
import 'package:takturns_flutter_app/core/router/app_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://jndikojudicmxthuvfbi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpuZGlrb2p1ZGljbXh0aHV2ZmJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzMzQwMTMsImV4cCI6MjA5NTkxMDAxM30.EcbalhMovKWOMRzFliDSYw_xepTnugmkh6DKwiAtn5E',
  );

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
        routerConfig: appRouter,
        theme: AppTheme.light,
        darkTheme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          return AppKitInitializer(child: child!);
        },
      ),
    );
  }
}

class AppKitInitializer extends StatefulWidget {
  final Widget child;
  const AppKitInitializer({super.key, required this.child});

  @override
  State<AppKitInitializer> createState() => _AppKitInitializerState();
}

class _AppKitInitializerState extends State<AppKitInitializer> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('[TakTurns] AppKitInitializer: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppKit();
    });
  }

  Future<void> _initAppKit() async {
    debugPrint('[TakTurns] AppKitInitializer: _initAppKit started');
    try {
      debugPrint('[TakTurns] AppKitInitializer: Creating ReownAppKitModal instance');
      final appKit = ReownAppKitModal(
        context: rootNavigatorKey.currentContext!,
        projectId: '69b21f1bb182c4dcf114a3dd7f1f5cac',
        metadata: const PairingMetadata(
          name: 'TakTurns',
          description: 'TakTurns Flutter App',
          url: 'https://takturns.com',
          icons: ['https://takturns.com/icon.png'],
          redirect: Redirect(
            native: 'takturns://',
            universal: 'https://takturns.com',
          ),
        ),
      );
      
      debugPrint('[TakTurns] AppKitInitializer: ReownAppKitModal instance created successfully');

      // Register Arbitrum Sepolia as a custom network BEFORE calling init()
      // It is a testnet and not in the default Reown network list
      debugPrint('[TakTurns] AppKitInitializer: Registering Arbitrum Sepolia network');
      ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
        ReownAppKitModalNetworkInfo(
          name: 'Arbitrum Sepolia',
          chainId: '421614',
          currency: 'ETH',
          rpcUrl: 'https://sepolia-rollup.arbitrum.io/rpc',
          explorerUrl: 'https://sepolia.arbiscan.io',
          isTestNetwork: true,
        ),
      ]);

      debugPrint('[TakTurns] AppKitInitializer: Awaiting appKit.init()...');
      await appKit.init().timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('ReownAppKitModal init() timed out after 15 seconds. Please clear your app data or check your network connection.');
      });
      debugPrint('[TakTurns] AppKitInitializer: appKit.init() completed successfully!');

      if (!sl.isRegistered<ReownAppKitModal>()) {
        debugPrint('[TakTurns] AppKitInitializer: Registering ReownAppKitModal with GetIt');
        sl.registerSingleton<ReownAppKitModal>(appKit);
      } else {
        debugPrint('[TakTurns] AppKitInitializer: ReownAppKitModal already registered with GetIt');
      }

      if (mounted) {
        debugPrint('[TakTurns] AppKitInitializer: Setting state to initialized = true');
        setState(() {
          _initialized = true;
        });
        
        debugPrint('[TakTurns] AppKitInitializer: Dispatching CheckStoredWalletEvent to WalletBloc');
        context.read<WalletBloc>().add(CheckStoredWalletEvent());
      } else {
        debugPrint('[TakTurns] AppKitInitializer: Widget unmounted before initialization could complete');
      }
    } catch (e, stackTrace) {
      debugPrint('[TakTurns] AppKitInitializer: ERROR CAUGHT DURING INIT -> $e');
      debugPrint('[TakTurns] AppKitInitializer: StackTrace -> $stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[TakTurns] AppKitInitializer: build called. initialized=$_initialized, error=$_error');
    
    return Stack(
      children: [
        // Always build the routing system so the Navigator mounts
        widget.child,
        
        // Show loading/error overlay on top if not initialized
        if (_error != null)
          Positioned.fill(
            child: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to initialize WalletConnect:\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          )
        else if (!_initialized)
          const Positioned.fill(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing Wallet Connect...', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
