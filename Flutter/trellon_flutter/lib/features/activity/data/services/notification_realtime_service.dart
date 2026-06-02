import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';
import '../../presentation/cubit/notification_cubit.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../planner/presentation/cubit/planner_cubit.dart';
import 'notification_hub_url_builder.dart';

class NotificationRealtimeService {
  final NotificationCubit cubit;
  final WorkspaceCubit workspaceCubit;
  final PlannerCubit plannerCubit;
  final FlutterSecureStorage secureStorage;

  HubConnection? _connection;

  NotificationRealtimeService({
    required this.cubit,
    required this.workspaceCubit,
    required this.plannerCubit,
    this.secureStorage = const FlutterSecureStorage(),
  });

  Future<void> start() async {
    if (_connection?.state == HubConnectionState.Connected ||
        _connection?.state == HubConnectionState.Connecting) {
      return;
    }

    final hubUrl = _notificationHubUrl();
    final connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await secureStorage.read(key: 'access_token') ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    connection.on('NotificationCreated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      cubit.applyRealtimeNotification(
        NotificationModel.fromJson(payload).toEntity(),
      );
    });

    connection.on('UnreadCountChanged', (args) {
      final count = args?.isNotEmpty == true ? args!.first : null;
      if (count is int) {
        cubit.applyUnreadCount(count);
      }
    });

    connection.on('NotificationRead', (args) {
      final notiId = args?.isNotEmpty == true ? args!.first?.toString() : null;
      if (notiId != null && notiId.isNotEmpty) {
        cubit.applyNotificationRead(notiId);
      }
    });

    connection.on('NotificationDeleted', (args) {
      final notiId = args?.isNotEmpty == true ? args!.first?.toString() : null;
      if (notiId != null && notiId.isNotEmpty) {
        cubit.applyNotificationDeleted(notiId);
      }
    });

    connection.on('NotificationReadAll', (_) {
      cubit.applyNotificationReadAll();
    });

    // Workspace Events
    connection.on('WorkspaceCreated', (_) {
      workspaceCubit.loadWorkspaces();
    });

    connection.on('WorkspaceUpdated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      workspaceCubit.applyRealtimeWorkspaceUpdated(payload);
    });

    connection.on('WorkspaceDeleted', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      workspaceCubit.applyRealtimeWorkspaceDeleted(payload['workspaceId']);
    });

    // Profile Events
    connection.on('ProfileUpdated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      cubit.applyRealtimeProfileUpdated(payload);
    });

    // Planner Events
    connection.on('CardDueDateUpdated', (_) {
      plannerCubit.applyRealtimeCardDueDateUpdated();
    });

    connection.on('AccountLocked', (_) {
      cubit.applyAccountLocked();
    });

    _connection = connection;
    await connection.start();
  }

  Future<void> stop() async {
    await _connection?.stop();
    _connection = null;
  }

  String _notificationHubUrl() {
    return NotificationHubUrlBuilder.build(ApiEndpoints.baseUrl);
  }

  Map<String, dynamic>? _firstMapArg(List<Object?>? args) {
    if (args == null || args.isEmpty || args.first is! Map) return null;
    return Map<String, dynamic>.from(args.first as Map);
  }
}
