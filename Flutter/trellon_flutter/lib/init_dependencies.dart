import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
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
import 'features/inbox/data/repositories/inbox_repositories_impl.dart';
import 'features/inbox/data/datasources/inbox_remote_data_source.dart';
import 'features/inbox/domain/repositories/i_inbox_repositories.dart';
import 'features/inbox/domain/usecases/get_user_inbox_card.dart';
import 'features/inbox/domain/usecases/add_inbox_card_usecase.dart';
import 'features/inbox/presentation/bloc/inbox_cubit.dart';
import 'features/card/data/repositories/card_repository_impl.dart';
import 'features/card/domain/repositories/i_card_repository.dart';
import 'features/card/domain/usecases/delete_card_usecase.dart';
import 'features/card/domain/usecases/update_card_status_usecase.dart';
import 'features/card/domain/usecases/add_card_comment_usecase.dart';
import 'features/card/domain/usecases/upload_attachment_usecase.dart';
import 'features/card/domain/usecases/get_attachments_usecase.dart';
import 'features/card/domain/usecases/delete_attachment_usecase.dart';
import 'features/card/domain/usecases/update_attachment_description_usecase.dart';
import 'features/card/domain/usecases/upload_card_cover_usecase.dart';
import 'features/card/presentation/cubit/card_detail_cubit.dart';
import 'features/board/data/datasources/board_remote_data_source.dart';
import 'features/board/data/repositories/board_repository_impl.dart';
import 'features/board/domain/repositories/board_repository.dart';
import 'features/board/domain/usecases/get_recent_boards_usecase.dart';
import 'features/board/domain/usecases/create_board_usecase.dart';
import 'features/board/domain/usecases/get_personal_boards_usecase.dart';
import 'features/board/domain/usecases/save_recent_board_usecase.dart';
import 'features/board/presentation/cubit/board_cubit.dart';
import 'features/board/presentation/cubit/board_detail_cubit.dart';
import 'features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'features/workspace/data/repositories/workspace_repository_impl.dart';
import 'features/workspace/domain/repositories/workspace_repository.dart';
import 'features/workspace/domain/usecases/get_workspaces_usecase.dart';
import 'features/workspace/domain/usecases/create_workspace_usecase.dart';
import 'features/workspace/domain/usecases/update_workspace_usecase.dart';
import 'features/workspace/domain/usecases/delete_workspace_usecase.dart';
import 'features/workspace/domain/usecases/add_workspace_member_usecase.dart';
import 'features/workspace/domain/usecases/get_workspace_boards_usecase.dart';
import 'features/workspace/presentation/cubit/workspace_cubit.dart';
import 'features/card/domain/usecases/update_list_uid_usecase.dart';
import 'features/activity/data/datasources/notification_remote_datasource.dart';
import 'features/activity/data/repositories/notification_repository_impl.dart';
import 'features/activity/data/services/notification_realtime_service.dart';
import 'features/activity/domain/repositories/i_notification_repository.dart';
import 'features/activity/domain/usecases/delete_notification_usecase.dart';
import 'features/activity/domain/usecases/get_notifications_usecase.dart';
import 'features/activity/domain/usecases/mark_all_read_usecase.dart';
import 'features/activity/domain/usecases/mark_as_read_usecase.dart';
import 'features/activity/presentation/cubit/notification_cubit.dart';

final serviceLocator = GetIt.instance;
Future<void> initDependencies() async {
  CookieJar cookieJar = CookieJar();
  serviceLocator.registerLazySingleton<CookieJar>(() => cookieJar);
  final dioClient = DioClient(persistentCookieJar: cookieJar);

  serviceLocator.registerLazySingleton<Dio>(() => dioClient.instance);
  serviceLocator.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSource());

  _initAuth();
  _initInbox();
  _initCard();
  _initBoard();
  _initWorkspace();
  _initNotification();
}

void _initWorkspace() {
  // Data Source
  serviceLocator.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSource(client: serviceLocator<Dio>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(remoteDataSource: serviceLocator<WorkspaceRemoteDataSource>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => GetWorkspacesUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => CreateWorkspaceUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateWorkspaceUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteWorkspaceUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AddWorkspaceMemberUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetWorkspaceBoardsUseCase(serviceLocator()));

  // Cubit
  serviceLocator.registerFactory(() => WorkspaceCubit(
    getWorkspacesUseCase: serviceLocator(),
    createWorkspaceUseCase: serviceLocator(),
    updateWorkspaceUseCase: serviceLocator(),
    deleteWorkspaceUseCase: serviceLocator(),
    addWorkspaceMemberUseCase: serviceLocator(),
    createBoardUseCase: serviceLocator(),
    userLocalDataSource: serviceLocator(),
  ));
}

void _initBoard() {
  // Data Source
  serviceLocator.registerLazySingleton<BoardRemoteDataSource>(
    () => BoardRemoteDataSourceImpl(client: serviceLocator<Dio>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<BoardRepository>(
    () => BoardRepositoryImpl(remoteDataSource: serviceLocator<BoardRemoteDataSource>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => GetRecentBoardsUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => CreateBoardUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetPersonalBoardsUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SaveRecentBoardUseCase(serviceLocator()));

  // BoardCubit
  serviceLocator.registerFactory(() => BoardCubit(
    getPersonalBoardsUseCase: serviceLocator(),
    getWorkspacesUseCase: serviceLocator(),
    getRecentBoardsUseCase: serviceLocator(),
    createBoardUseCase: serviceLocator(),
    userLocalDataSource: serviceLocator(),
  ));

  // BoardDetailCubit — uses data source, userLocalDataSource, and updateListUIdUseCase
  serviceLocator.registerFactory(() => BoardDetailCubit(
    dataSource: serviceLocator<BoardRemoteDataSource>(),
    userLocalDataSource: serviceLocator<UserLocalDataSource>(),
    updateListUIdUseCase: serviceLocator<UpdateListUIdUseCase>(),
    updateCardStatusUseCase: serviceLocator<UpdateCardStatusUseCase>(),
    saveRecentBoardUseCase: serviceLocator<SaveRecentBoardUseCase>(),
  ));
}

void _initCard() {
  // Repository
  serviceLocator.registerLazySingleton<ICardRepository>(
    () => CardRepositoryImpl(dio: serviceLocator<Dio>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => DeleteCardUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateCardStatusUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AddCardCommentUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UploadAttachmentUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetAttachmentsUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteAttachmentUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateAttachmentDescriptionUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UploadCardCoverUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateListUIdUseCase(serviceLocator()));

  // Cubit
  serviceLocator.registerFactory(() => CardDetailCubit(
    serviceLocator(),
    serviceLocator(),
    serviceLocator(),
    serviceLocator(),
    serviceLocator(),
    serviceLocator(),
    serviceLocator(),
    serviceLocator(),
  ));
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
  serviceLocator.registerLazySingleton(() => CheckOtpStatusUseCase(serviceLocator()));

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
      checkOtpStatusUseCase: serviceLocator(),
    ),
  );
}

void _initInbox() {
  // DataSource
  serviceLocator.registerLazySingleton<InboxRemoteDataSource>(
    () => InboxRemoteDataSourceImpl(dio: serviceLocator<Dio>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<InboxRepositories>(
    () => InboxRepositoriesImpl(remoteDataSource: serviceLocator<InboxRemoteDataSource>()),
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
      inboxRepositories: serviceLocator(),
      userLocalDataSource: serviceLocator(),
    ),
  );
}

void _initNotification() {
  // Data Source
  serviceLocator.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: serviceLocator<Dio>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: serviceLocator<NotificationRemoteDataSource>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton(() => GetNotificationsUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => MarkAsReadUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => MarkAllReadUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteNotificationUseCase(serviceLocator()));

  serviceLocator.registerLazySingleton(() => NotificationCubit(
    getNotificationsUseCase: serviceLocator(),
    markAsReadUseCase: serviceLocator(),
    markAllReadUseCase: serviceLocator(),
    deleteNotificationUseCase: serviceLocator(),
  ));

  serviceLocator.registerLazySingleton(() => NotificationRealtimeService(
    cubit: serviceLocator<NotificationCubit>(),
  ));
}
