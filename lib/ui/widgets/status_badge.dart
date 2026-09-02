import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getBadgeColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color _getBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return AppColors.info;
      case 'contacted':
        return const Color(0xFF8B5CF6); // Purple
      case 'interested':
        return AppColors.warning;
      case 'demo':
        return const Color(0xFF06B6D4); // Cyan
      case 'follow-up':
        return const Color(0xFFF97316); // Orange
      case 'converted':
      case 'paid':
      case 'active':
        return AppColors.success;
      case 'lost':
      case 'disabled':
      case 'overdue':
        return AppColors.danger;
      case 'partial':
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
