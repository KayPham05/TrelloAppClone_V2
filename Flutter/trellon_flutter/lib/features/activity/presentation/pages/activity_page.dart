import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/activity_entity.dart';
import '../widgets/activity_empty_state_widget.dart';
import '../widgets/activity_item_widget.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // Empty for demo (như trong ảnh)
  final List<ActivityEntity> _activities = [];

  void _onRefresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Hoạt động',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_box_outlined, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            if (_activities.isEmpty)
              ActivityEmptyStateWidget(onRefresh: _onRefresh)
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _activities.length,
                  separatorBuilder: (_, __) => Container(height: 0.5, color: AppColors.border),
                  itemBuilder: (ctx, i) => ActivityItemWidget(item: _activities[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
