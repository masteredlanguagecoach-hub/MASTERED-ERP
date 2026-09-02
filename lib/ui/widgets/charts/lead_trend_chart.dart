import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class LeadTrendChart extends StatelessWidget {
  const LeadTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['New', 'Demo', 'Interested', 'Converted', 'Lost'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Text(labels[value.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: AppColors.info, width: 14, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: const Color(0xFF06B6D4), width: 14, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 15, color: AppColors.warning, width: 14, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: AppColors.success, width: 14, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 3, color: AppColors.danger, width: 14, borderRadius: BorderRadius.circular(4))]),
          ],
        ),
      ),
    );
  }
}
