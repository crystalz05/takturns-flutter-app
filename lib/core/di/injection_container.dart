import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web3dart/web3dart.dart';

import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/groups/group_injection.dart';
import 'package:takturns_flutter_app/features/home/home_injection.dart';
import 'package:takturns_flutter_app/features/wallet/wallet_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ───────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<Web3Client>(
    Web3Client(AppConstants.rpcUrl, http.Client()),
  );

  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // ─── Feature Modules ────────────────────────────────────────────────────────
  registerWalletDependencies(sl);
  registerHomeDependencies(sl);
  registerGroupDependencies(sl);
}