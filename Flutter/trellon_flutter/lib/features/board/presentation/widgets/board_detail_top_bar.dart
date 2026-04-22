import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Top bar for the Board Detail page
class BoardDetailTopBarWidget extends StatelessWidget {
  final String boardName;
  final VoidCallback onMorePressed;

  const BoardDetailTopBarWidget({
    super.key,
    required this.boardName,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              boardName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: onMorePressed,
          ),
        ],
      ),
    );
  }
}

