import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/invite_batch_result.dart';
import '../../domain/entities/invite_suggestion.dart';

typedef InviteSuggestionSearch =
    Future<List<InviteSuggestion>> Function({
      required String query,
      required List<InviteSuggestion> selected,
    });

typedef InviteSubmit =
    Future<InviteBatchResult> Function(List<InviteSuggestion> selected);

class MemberInvitePicker extends StatefulWidget {
  static const defaultDebounceDuration = Duration(milliseconds: 300);

  final String title;
  final InviteSuggestionSearch searchSuggestions;
  final InviteSubmit onSubmit;
  final Widget? roleControl;
  final Duration debounceDuration;

  const MemberInvitePicker({
    super.key,
    required this.title,
    required this.searchSuggestions,
    required this.onSubmit,
    this.roleControl,
    this.debounceDuration = defaultDebounceDuration,
  });

  @override
  State<MemberInvitePicker> createState() => _MemberInvitePickerState();
}

class _MemberInvitePickerState extends State<MemberInvitePicker> {
  static const _selectionAnimationDuration = Duration(milliseconds: 280);
  static const _panelAnimationDuration = Duration(milliseconds: 340);
  static const _animationCurve = Curves.easeOutCubic;

  final _controller = TextEditingController();
  final _selected = <InviteSuggestion>[];
  final _removingUserIds = <String>{};
  List<InviteSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () async {
      final query = value.trim();
      if (query.length < 2) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _errorText = null;
          });
        }
        return;
      }

      try {
        setState(() {
          _loading = true;
          _errorText = null;
        });
        final suggestions = await widget.searchSuggestions(
          query: query,
          selected: List.unmodifiable(_selected),
        );
        if (!mounted) return;
        setState(() {
          _suggestions = suggestions
              .where((item) => !_selected.any((s) => s.userUId == item.userUId))
              .toList();
          _loading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _loading = false;
          _errorText = 'Không thể tải gợi ý thành viên.';
        });
      }
    });
  }

  void _select(InviteSuggestion suggestion) {
    setState(() {
      _selected.add(suggestion);
      _suggestions = [];
      _errorText = null;
      _controller.clear();
    });
  }

  void _removeSelected(InviteSuggestion user) {
    if (_removingUserIds.contains(user.userUId)) return;
    setState(() => _removingUserIds.add(user.userUId));
    Future<void>.delayed(_selectionAnimationDuration, () {
      if (!mounted) return;
      setState(() {
        _selected.removeWhere((item) => item.userUId == user.userUId);
        _removingUserIds.remove(user.userUId);
      });
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    final result = await widget.onSubmit(List.unmodifiable(_selected));
    if (!mounted) return;
    setState(() => _submitting = false);
    final message = result.failureCount == 0
        ? 'Đã mời ${result.successCount} thành viên.'
        : 'Đã mời ${result.successCount}/${result.totalCount} thành viên. ${result.failureCount} lời mời không thành công.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (result.successCount > 0 && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _panelTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(parent: animation, curve: _animationCurve);
    return FadeTransition(
      opacity: curved,
      child: SizeTransition(
        sizeFactor: curved,
        axis: Axis.vertical,
        axisAlignment: -1.0,
        child: child,
      ),
    );
  }

  Duration _suggestionAnimationDuration(int index) {
    final staggerMs = (index * 28).clamp(0, 112).toInt();
    return _panelAnimationDuration + Duration(milliseconds: staggerMs);
  }

  Widget _buildLoadingIndicator() {
    return AnimatedSwitcher(
      duration: _panelAnimationDuration,
      switchInCurve: _animationCurve,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: _panelTransition,
      child: _loading
          ? const Padding(
              key: ValueKey('invite-loading'),
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 3),
            )
          : const SizedBox.shrink(key: ValueKey('invite-loading-idle')),
    );
  }

  Widget _buildSuggestions() {
    return AnimatedSwitcher(
      duration: _panelAnimationDuration,
      switchInCurve: _animationCurve,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: _panelTransition,
      child: _suggestions.isEmpty
          ? const SizedBox.shrink(key: ValueKey('invite-suggestions-empty'))
          : ConstrainedBox(
              key: ValueKey(_suggestions.map((item) => item.userUId).join(',')),
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return TweenAnimationBuilder<double>(
                    key: ValueKey('suggestion-${suggestion.userUId}'),
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: _suggestionAnimationDuration(index),
                    curve: _animationCurve,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.985 + (0.015 * value),
                        alignment: Alignment.centerLeft,
                        child: Transform.translate(
                          offset: Offset(0, 5 * (1 - value)),
                          child: child,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: suggestion.avatarUrl == null
                            ? null
                            : NetworkImage(suggestion.avatarUrl!),
                        child: suggestion.avatarUrl == null
                            ? Text(
                                suggestion.displayName.characters.first
                                    .toUpperCase(),
                              )
                            : null,
                      ),
                      title: Text(suggestion.displayName),
                      subtitle: Text(
                        suggestion.workspaceRole == null
                            ? suggestion.email
                            : '${suggestion.email} • ${suggestion.workspaceRole}',
                      ),
                      onTap: () => _select(suggestion),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSelectedUsers() {
    return AnimatedSize(
      duration: _panelAnimationDuration,
      curve: _animationCurve,
      alignment: Alignment.topLeft,
      clipBehavior: Clip.none,
      child: _selected.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final user in _selected) _buildSelectedChip(user),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectedChip(InviteSuggestion user) {
    final isRemoving = _removingUserIds.contains(user.userUId);
    return TweenAnimationBuilder<double>(
      key: ValueKey('selected-${user.userUId}'),
      tween: Tween<double>(begin: 0, end: isRemoving ? 0 : 1),
      duration: _selectionAnimationDuration,
      curve: _animationCurve,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.965 + (0.035 * value), child: child),
      ),
      child: InputChip(
        label: Text(user.displayName),
        onDeleted: () => _removeSelected(user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom - 48;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: maxHeight < 320 ? 320 : maxHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                decoration: const InputDecoration(
                  labelText: 'Tên hoặc email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_add_alt_1),
                ),
              ),
              _buildLoadingIndicator(),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              _buildSuggestions(),
              _buildSelectedUsers(),
              if (widget.roleControl != null) ...[
                const SizedBox(height: 12),
                widget.roleControl!,
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _selected.isEmpty || _submitting ? null : _submit,
                  child: Text(_submitting ? 'Đang mời...' : 'Mời'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
