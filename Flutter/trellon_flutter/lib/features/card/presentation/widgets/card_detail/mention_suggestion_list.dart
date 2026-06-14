import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/card_entity.dart';

class ActiveMentionToken {
  final int start;
  final int end;
  final String query;

  const ActiveMentionToken({
    required this.start,
    required this.end,
    required this.query,
  });
}

ActiveMentionToken? detectActiveMentionToken(String text, int cursorOffset) {
  if (cursorOffset <= 0 || cursorOffset > text.length) return null;

  final previousChar = text[cursorOffset - 1];
  if (_isMentionBoundary(previousChar)) return null;

  var segmentStart = cursorOffset - 1;
  while (segmentStart >= 0 && !_isMentionBoundary(text[segmentStart])) {
    segmentStart--;
  }
  segmentStart++;

  final segment = text.substring(segmentStart, cursorOffset);
  final mentionOffset = segment.indexOf('@');
  if (mentionOffset >= 0) {
    final start = segmentStart + mentionOffset;
    final query = text.substring(start + 1, cursorOffset);
    return ActiveMentionToken(start: start, end: cursorOffset, query: query);
  }

  return null;
}

List<CardMemberEntity> filterMentionMembers(
  List<CardMemberEntity> members,
  String query, {
  int limit = 5,
}) {
  final normalized = query.trim().toLowerCase();
  final results = members
      .where((member) {
        final userName = member.userName.toLowerCase();
        final email = member.email.toLowerCase();
        final emailPrefix = email.split('@').first;
        return normalized.isEmpty ||
            userName.contains(normalized) ||
            emailPrefix.contains(normalized) ||
            email.contains(normalized);
      })
      .take(limit)
      .toList();
  return results;
}

String mentionReplacementFor(CardMemberEntity member) {
  final userName = member.userName.trim();
  if (userName.isNotEmpty && userName != 'Unknown') {
    return '@${userName.replaceAll(RegExp(r'\s+'), '')} ';
  }
  return '@${member.email} ';
}

bool _isMentionBoundary(String char) {
  return RegExp(r'[\s,;:!?()[\]{}<>]').hasMatch(char);
}

class MentionSuggestionList extends StatelessWidget {
  final List<CardMemberEntity> members;
  final String query;
  final ValueChanged<CardMemberEntity> onSelected;

  const MentionSuggestionList({
    super.key,
    required this.members,
    required this.query,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = filterMentionMembers(members, query);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            final member = suggestions[index];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 18,
                backgroundImage:
                    member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                    ? Text(_initials(member.userName))
                    : null,
              ),
              title: Text(
                member.userName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                member.email,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              onTap: () => onSelected(member),
            );
          },
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts
        .map((p) => p[0])
        .join()
        .toUpperCase()
        .substring(0, parts.length > 1 ? 2 : 1);
  }
}
