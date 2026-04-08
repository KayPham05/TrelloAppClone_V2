import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'core/network/dio_client.dart';
import 'core/data_sources/user_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/verify_code_usecase.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/auth/presentation/cubit/register_cubit.dart';
import 'features/auth/presentation/cubit/verify_cubit.dart';
import 'features/inbox/data/repositories/inbox_repositories_Impl.dart';
import 'features/inbox/domain/repositories/i_inbox_repositories.dart';
import 'features/inbox/domain/usecases/get_user_inbox_card.dart';
import 'features/inbox/domain/usecases/add_inbox_card_usecase.dart';
import 'features/inbox/presentation/bloc/inbox_cubit.dart';
import 'features/card/data/repositories/card_repository_impl.dart';
import 'features/card/domain/repositories/i_card_repository.dart';
import 'features/card/domain/usecases/delete_card_usecase.dart';
import 'features/card/domain/usecases/update_card_status_usecase.dart';
import 'features/card/presentation/cubit/card_detail_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  serviceLocator.registerLazySingleton<Dio>(() => DioClient().instance);
  serviceLocator.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSource());

  _initAuth();
  _initInbox();
  _initCard();
}

void _initCard() {
  // Repository
  serviceLocator.registerLazySingleton<ICardRepository>(
    () => CardRepositoryImpl(dio: serviceLocator<Dio>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => DeleteCardUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateCardStatusUseCase(serviceLocator()));

  // Cubit
  serviceLocator.registerFactory(() => CardDetailCubit(serviceLocator()));
}

void _initAuth() {
  // Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator<Dio>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => LoginUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => RegisterUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => VerifyCodeUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => ResendCodeUseCase(serviceLocator()));

  // Cubits
  serviceLocator.registerFactory(
    () => LoginCubit(loginUseCase: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => RegisterCubit(registerUseCase: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => VerifyCubit(
      verifyCodeUseCase: serviceLocator(),
      resendCodeUseCase: serviceLocator(),
    ),
  );
}

void _initInbox() {
  // Repository
  serviceLocator.registerLazySingleton<InboxRepositories>(
    () => InboxRepositoriesImpl(dio: serviceLocator<Dio>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => GetInboxCardUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AddInboxCardUseCase(serviceLocator()));

  // Cubit
  serviceLocator.registerFactory(
    () => InboxCubit(
      getInboxCardsUseCase: serviceLocator(),
      addInboxCardUseCase: serviceLocator(),
      deleteCardUseCase: serviceLocator(),
      updateCardStatusUseCase: serviceLocator(),
      userLocalDataSource: serviceLocator(),
    ),
  );
}
