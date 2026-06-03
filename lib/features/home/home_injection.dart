import 'package:get_it/get_it.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/home/presentation/bloc/home_bloc.dart';

void registerHomeDependencies(GetIt sl){
  
  sl.registerFactory(() => HomeBloc(
    getUserGroups: sl<GetUserGroups>(),
    getCreatedGroups: sl<GetCreatedGroups>(),
  ));
}