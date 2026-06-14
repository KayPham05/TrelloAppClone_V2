import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../domain/entities/workspace_member.dart';

// ── States ──────────────────────────────────────────────────────────────────
abstract class WorkspaceMemberState {}

class WorkspaceMemberInitial extends WorkspaceMemberState {}
class WorkspaceMemberLoading extends WorkspaceMemberState {}
class WorkspaceMemberLoaded extends WorkspaceMemberState {
  final List<WorkspaceMember> members;
  final String currentUserRole;
  WorkspaceMemberLoaded({required this.members, required this.currentUserRole});
}
class WorkspaceMemberError extends WorkspaceMemberState {
  final String message;
  WorkspaceMemberError(this.message);
}

// ── Cubit ────────────────────────────────────────────────────────────────────
class WorkspaceMemberCubit extends Cubit<WorkspaceMemberState> {
  final Dio _client;
  final UserLocalDataSource _userLocalDataSource;

  WorkspaceMemberCubit({
    required Dio client,
    required UserLocalDataSource userLocalDataSource,
  })  : _client = client,
        _userLocalDataSource = userLocalDataSource,
        super(WorkspaceMemberInitial());

  /// Lấy danh sách thành viên workspace
  Future<void> loadMembers(String workspaceId) async {
    emit(WorkspaceMemberLoading());
    try {
      final currentUserUId = await _userLocalDataSource.getUserId() ?? '';
      final response = await _client.get(
        '${ApiEndpoints.workspaceMember}/$workspaceId',
      );
      if (response.statusCode == 200) {
        final List data = response.data as List;
        final members = data.map((e) => WorkspaceMember.fromJson(e as Map<String, dynamic>)).toList();
        final currentRole = members
                .firstWhere(
                  (m) => m.userUId == currentUserUId,
                  orElse: () => const WorkspaceMember(
                    userUId: '', userName: '', email: '', role: 'Member'),
                )
                .role;
        emit(WorkspaceMemberLoaded(members: members, currentUserRole: currentRole));
      } else {
        emit(WorkspaceMemberError('Không thể tải danh sách thành viên.'));
      }
    } catch (e) {
      emit(WorkspaceMemberError(e.toString()));
    }
  }

  /// Mời thành viên mới bằng userId + role
  Future<bool> inviteMember({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    try {
      final requesterUId = await _userLocalDataSource.getUserId() ?? '';
      final response = await _client.post(
        '${ApiEndpoints.workspaceMember}/$workspaceId/invite',
        data: {'userId': userId, 'requesterUId': requesterUId, 'role': role},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadMembers(workspaceId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Cập nhật role của thành viên
  Future<bool> updateRole({
    required String workspaceId,
    required String userId,
    required String newRole,
  }) async {
    try {
      final requesterUId = await _userLocalDataSource.getUserId() ?? '';
      final response = await _client.put(
        '${ApiEndpoints.workspaceMember}/$workspaceId/role/$userId',
        queryParameters: {'newRole': newRole, 'requesterUId': requesterUId},
      );
      if (response.statusCode == 200) {
        await loadMembers(workspaceId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Xóa thành viên khỏi workspace
  Future<bool> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final requesterUId = await _userLocalDataSource.getUserId() ?? '';
      final response = await _client.delete(
        '${ApiEndpoints.workspaceMember}/$workspaceId/$userId',
        queryParameters: {'requesterUId': requesterUId},
      );
      if (response.statusCode == 200) {
        await loadMembers(workspaceId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Tìm user theo email (để dùng trong invite dialog)
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final response = await _client.get(
        'users/search',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
