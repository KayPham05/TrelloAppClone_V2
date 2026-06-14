import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../data/datasources/board_remote_data_source.dart';
import '../../domain/entities/board_member.dart';

// ── States ──────────────────────────────────────────────────────────────────
abstract class BoardMemberState {}

class BoardMemberInitial extends BoardMemberState {}
class BoardMemberLoading extends BoardMemberState {}
class BoardMemberLoaded extends BoardMemberState {
  final List<BoardMember> members;
  final String currentUserRole;
  BoardMemberLoaded({required this.members, required this.currentUserRole});
}
class BoardMemberError extends BoardMemberState {
  final String message;
  BoardMemberError(this.message);
}

// ── Cubit ────────────────────────────────────────────────────────────────────
class BoardMemberCubit extends Cubit<BoardMemberState> {
  final BoardRemoteDataSource _dataSource;
  final UserLocalDataSource _userLocalDataSource;

  BoardMemberCubit({
    required BoardRemoteDataSource dataSource,
    required UserLocalDataSource userLocalDataSource,
  })  : _dataSource = dataSource,
        _userLocalDataSource = userLocalDataSource,
        super(BoardMemberInitial());

  Future<void> loadMembers(String boardId) async {
    emit(BoardMemberLoading());
    try {
      final currentUserUId = await _userLocalDataSource.getUserId() ?? '';
      final data = await _dataSource.getBoardMembers(boardId);
      final members = data.map((e) => BoardMember.fromJson(e as Map<String, dynamic>)).toList();
      final currentRole = members
              .firstWhere(
                (m) => m.userUId == currentUserUId,
                orElse: () => const BoardMember(
                  userUId: '', userName: '', email: '', role: 'Viewer'),
              )
              .role;
      emit(BoardMemberLoaded(members: members, currentUserRole: currentRole));
    } catch (e) {
      emit(BoardMemberError(e.toString()));
    }
  }

  Future<bool> addMember({
    required String boardId,
    required String userId,
    required String role,
  }) async {
    try {
      final requesterUId = await _userLocalDataSource.getUserId() ?? '';
      final success = await _dataSource.addBoardMember(
        boardId: boardId,
        userId: userId,
        role: role,
        requesterUId: requesterUId,
      );
      if (success) {
        await loadMembers(boardId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateRole({
    required String boardId,
    required String userId,
    required String newRole,
  }) async {
    try {
      final requesterUId = await _userLocalDataSource.getUserId() ?? '';
      final success = await _dataSource.updateBoardMemberRole(
        boardId: boardId,
        userId: userId,
        newRole: newRole,
        requesterUId: requesterUId,
      );
      if (success) {
        await loadMembers(boardId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeMember({
    required String boardId,
    required String userId,
  }) async {
    try {
      final requesterUId = await _userLocalDataSource.getUserId() ?? '';
      final success = await _dataSource.removeBoardMember(
        boardId: boardId,
        userId: userId,
        requesterUId: requesterUId,
      );
      if (success) {
        await loadMembers(boardId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      return await _dataSource.findUserByEmail(email);
    } catch (_) {
      return null;
    }
  }
}
