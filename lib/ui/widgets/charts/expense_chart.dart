import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 35,
          sections: [
            PieChartSectionData(
              color: AppColors.primary,
              value: 40,
              title: 'Rent\n40%',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: AppColors.warning,
              value: 30,
              title: 'Mktg\n30%',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: AppColors.info,
              value: 18,
              title: 'Salary\n18%',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: AppColors.success,
              value: 12,
              title: 'Bills\n12%',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
