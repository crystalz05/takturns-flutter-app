import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:takturns_flutter_app/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:takturns_flutter_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:takturns_flutter_app/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:web3dart/credentials.dart';

void registerHomeDependencies(GetIt sl){
  
  sl.registerFactory(
      () => HomeBloc(getGroupDetails: sl<GetGroupDetails>())
  );
}