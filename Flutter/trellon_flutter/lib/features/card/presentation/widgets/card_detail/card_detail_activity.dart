import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
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

class CardDetailActivityList extends StatelessWidget {
  final List<CardActivityItemData> activities;

  const CardDetailActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'BÌNH LUẬN',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...activities
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCommentItem(item),
                  )),
          const SizedBox(height: 8),
          const CardDetailCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CardActivityItemData item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.initial,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.authorName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                    Text(
                      item.time,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardDetailCommentInput extends StatefulWidget {
  const CardDetailCommentInput({super.key});

  @override
  State<CardDetailCommentInput> createState() => _CardDetailCommentInputState();
}

class _CardDetailCommentInputState extends State<CardDetailCommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Viết bình luận...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.attach_file_rounded,
                size: 20, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.emoji_emotions_outlined,
                size: 20, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1D4ED8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
