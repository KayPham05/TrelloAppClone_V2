import 'package:flutter/material.dart';

class AddListButtonWidget extends StatelessWidget {
  const AddListButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.add, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Thêm danh sách khác', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
