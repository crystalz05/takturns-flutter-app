import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/groups/data/repositories/group_repository_impl.dart';
import 'package:takturns_flutter_app/features/groups/domain/repositories/group_repository.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/create_group_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/group_detail_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/home_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/join_group_bloc.dart';
import 'package:takturns_flutter_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:takturns_flutter_app/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ───────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<Web3Client>(
    Web3Client(AppConstants.rpcUrl, http.Client()),
  );

  // ─── Repositories ────────────────────────────────────────────────────────────
  sl.registerSingleton<WalletRepository>(
    WalletRepositoryImpl(sl<Web3Client>(), sl<SharedPreferences>()),
  );

  sl.registerSingleton<GroupRepository>(
    GroupRepositoryImpl(
      sl<Web3Client>(),
      () {
        final walletRepo = sl<WalletRepository>() as WalletRepositoryImpl;
        final creds = walletRepo.credentials;
        if (creds == null) throw Exception('Wallet not connected');
        return creds;
      },
    ),
  );

  // ─── Wallet Use Cases ────────────────────────────────────────────────────────
  sl.registerFactory(() => ConnectWallet(sl<WalletRepository>()));
  sl.registerFactory(() => GetStoredWallet(sl<WalletRepository>()));
  sl.registerFactory(() => GetUsdcBalance(sl<WalletRepository>()));
  sl.registerFactory(() => DisconnectWallet(sl<WalletRepository>()));

  // ─── Group Use Cases ─────────────────────────────────────────────────────────
  sl.registerFactory(() => CreateGroup(sl<GroupRepository>()));
  sl.registerFactory(() => GetCollateralAmount(sl<GroupRepository>()));
  sl.registerFactory(() => ApproveUsdc(sl<GroupRepository>()));
  sl.registerFactory(() => JoinGroup(sl<GroupRepository>()));
  sl.registerFactory(() => StartGroup(sl<GroupRepository>()));
  sl.registerFactory(() => Contribute(sl<GroupRepository>()));
  sl.registerFactory(() => FlagDefaulter(sl<GroupRepository>()));
  sl.registerFactory(() => CastVote(sl<GroupRepository>()));
  sl.registerFactory(() => ResolveVote(sl<GroupRepository>()));
  sl.registerFactory(() => GetGroupDetails(sl<GroupRepository>()));
  sl.registerFactory(() => GetCycleProgress(sl<GroupRepository>()));
  sl.registerFactory(() => GetMembers(sl<GroupRepository>()));
  sl.registerFactory(() => HasContributed(sl<GroupRepository>()));

  // ─── BLoCs ──────────────────────────────────────────────────────────────────
  sl.registerFactory(() => WalletBloc(
    connectWallet: sl<ConnectWallet>(),
    getStoredWallet: sl<GetStoredWallet>(),
    disconnectWallet: sl<DisconnectWallet>(),
    getUsdcBalance: sl<GetUsdcBalance>(),
  ));

  sl.registerFactory(() => HomeBloc(
    getGroupDetails: sl<GetGroupDetails>(),
  ));

  sl.registerFactory(() => CreateGroupBloc(
    createGroup: sl<CreateGroup>(),
    approveUsdc: sl<ApproveUsdc>(),
    walletRepository: sl<WalletRepository>(),
  ));

  sl.registerFactory(() => JoinGroupBloc(
    getGroupDetails: sl<GetGroupDetails>(),
    approveUsdc: sl<ApproveUsdc>(),
    joinGroup: sl<JoinGroup>(),
    getCollateralAmount: sl<GetCollateralAmount>(),
  ));

  sl.registerFactory(() => GroupDetailBloc(
    getGroupDetails: sl<GetGroupDetails>(),
    getCycleProgress: sl<GetCycleProgress>(),
    getMembers: sl<GetMembers>(),
    hasContributed: sl<HasContributed>(),
    flagDefaulter: sl<FlagDefaulter>(),
    castVote: sl<CastVote>(),
    resolveVote: sl<ResolveVote>(),
    startGroup: sl<StartGroup>(),
    contribute: sl<Contribute>(),
    walletRepository: sl<WalletRepository>(),
  ));
}
