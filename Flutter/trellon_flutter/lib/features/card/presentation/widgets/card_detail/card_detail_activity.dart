import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/card_detail_cubit.dart';

class CardActivityItemData {
  final String authorName;
  final String initial;
  final String content;
  final String time;

  CardActivityItemData({
    required this.authorName,
    required this.initial,
    required this.content,
    required this.time,
  });
}

/// Activity list with flat section header + activity items + sticky comment input at bottom
class CardDetailActivityList extends StatelessWidget {
  final List<CardActivityItemData> activities;

  const CardDetailActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header: 三 Hoạt động + gear icon ─────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Icon(Icons.format_list_bulleted_rounded,
                  size: 20, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Hoạt động',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ),
              Icon(Icons.settings_outlined,
                  size: 20, color: Colors.grey.shade500),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Activity items ────────────────────────────────────────────
        ...activities.map((item) => _ActivityItem(item: item)),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final CardActivityItemData item;
  const _ActivityItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author avatar circle
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              item.initial.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content text
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                    children: [
                      TextSpan(
                        text: '${item.authorName} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: item.content),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(item.time,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky comment input bar ──────────────────────────────────────────────────
class CardDetailCommentBar extends StatefulWidget {
  const CardDetailCommentBar({super.key});

  @override
  State<CardDetailCommentBar> createState() => _CardDetailCommentBarState();
}

class _CardDetailCommentBarState extends State<CardDetailCommentBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<CardDetailCubit>().addComment(text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Current user avatar placeholder
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: Color(0xFF334155), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('K',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          const SizedBox(width: 10),
          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Bình luận...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: Colors.grey.shade500),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Attachment icon
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.attach_file_outlined,
                size: 22, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Keep old CardDetailCommentInput as an alias (used nowhere now but avoids breakage)
// ──────────────────────────────────────────────────────────────────────────────
class CardDetailCommentInput extends StatelessWidget {
  const CardDetailCommentInput({super.key});
  @override
  Widget build(BuildContext context) => const CardDetailCommentBar();
}
