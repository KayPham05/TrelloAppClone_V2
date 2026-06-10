import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../presentation/cubit/board_detail_cubit.dart';

class BoardRealtimeService {
  final FlutterSecureStorage secureStorage;
  HubConnection? _connection;
  String? _currentBoardUId;

  BoardRealtimeService({
    this.secureStorage = const FlutterSecureStorage(),
  });

  Future<void> start() async {
    if (_connection?.state == HubConnectionState.Connected ||
        _connection?.state == HubConnectionState.Connecting) {
      return;
    }

    final hubUrl = '${ApiEndpoints.baseUrl.replaceAll('/v1/api', '')}/hubs/board';
    
    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => await secureStorage.read(key: 'access_token') ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Board Events
    _connection!.on('BoardUpdated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeBoardUpdated(payload);
    });

    _connection!.on('BoardBackgroundUpdated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeBoardBackgroundUpdated(payload['url']);
    });

    // List Events
    _connection!.on('ListCreated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeListCreated(payload);
    });

    _connection!.on('ListStatusUpdated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeListStatusUpdated(payload['listUId'], payload['newStatus']);
    });

    _connection!.on('ListReordered', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeListReordered(payload['order']);
    });

    // Card Events
    _connection!.on('CardAdded', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeCardAdded(payload);
    });

    _connection!.on('CardUpdated', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeCardUpdated(payload);
    });

    _connection!.on('CardDeleted', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeCardDeleted(payload['cardUId']);
    });

    _connection!.on('CardMoved', (args) {
      final payload = _firstMapArg(args);
      if (payload == null) return;
      _getBoardCubit()?.applyRealtimeCardMoved(
        payload['cardUId'],
        payload['newListUId'],
        payload['position'],
      );
    });

    // Comment Events
    _connection!.on('CommentAdded', (args) {
        final payload = _firstMapArg(args);
        if (payload == null) return;
        _getBoardCubit()?.applyRealtimeCommentAdded(payload);
    });

    _connection!.on('CommentDeleted', (args) {
        final payload = _firstMapArg(args);
        if (payload == null) return;
        _getBoardCubit()?.applyRealtimeCommentDeleted(payload['commentUId'], payload['cardUId']);
    });

    await _connection!.start();
  }

  Future<void> joinBoard(String boardUId) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    if (_currentBoardUId == boardUId) return;
    
    if (_currentBoardUId != null) {
      await leaveBoard(_currentBoardUId!);
    }
    
    await _connection!.invoke('JoinBoard', args: [boardUId]);
    _currentBoardUId = boardUId;
  }

  Future<void> leaveBoard(String boardUId) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    await _connection!.invoke('LeaveBoard', args: [boardUId]);
    if (_currentBoardUId == boardUId) _currentBoardUId = null;
  }

  Future<void> stop() async {
    await _connection?.stop();
    _connection = null;
    _currentBoardUId = null;
  }

  BoardDetailCubit? _getBoardCubit() {
    try {
      return GetIt.instance<BoardDetailCubit>();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _firstMapArg(List<Object?>? args) {
    if (args == null || args.isEmpty || args.first is! Map) return null;
    return Map<String, dynamic>.from(args.first as Map);
  }
}
