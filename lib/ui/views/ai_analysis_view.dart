import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AiAnalysisView extends StatefulWidget {
  const AiAnalysisView({super.key});

  @override
  State<AiAnalysisView> createState() => _AiAnalysisViewState();
}

class _AiAnalysisViewState extends State<AiAnalysisView> {
  bool _isAnalyzing = false;
  bool _analysisComplete = false;

  void _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                cross: CrossAxisAlignment.start,
                children: [
                  Text('Admin AI Report Analysis & Trend Summarizer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Generates intelligent executive summaries from anonymized academy metrics.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _isAnalyzing ? null : _runAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Run AI Analysis'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (!_analysisComplete && !_isAnalyzing)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.psychology, size: 48, color: AppColors.primary),
                      SizedBox(height: 12),
                      Text('Click "Run AI Analysis" to summarize trends from anonymized academy data.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            )
          else if (_isAnalyzing)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView(
                children: [
                  _buildAnalysisCard(
                    'High-Converting Courses & Lead Sources',
                    '• BCA-1Y (Bachelor in Computer Applications) holds the highest conversion rate at 33.3%.\n• Meta Ads account for 55% of all qualified leads.\n• Organic Lead referrals have a 100% closure rate.',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                  const SizedBox(height: 14),
                  _buildAnalysisCard(
                    'Follow-up & Sales Executive Performance Risk',
                    '• 2 missed follow-ups detected for the current week.\n• Sales Executive conversion rate is currently at 20% against the 25% monthly target.\n• Action Item: Reassign inactive leads older than 7 days.',
                    Icons.warning_amber,
                    AppColors.warning,
                  ),
                  const SizedBox(height: 14),
                  _buildAnalysisCard(
                    'Fee Collection & Pending Balance Concentration',
                    '• Total Pending Fee Balance across active students: ₹115,000.\n• 1 student has an extended due date within the 10-day limit.\n• Recommended Action: Send automated WhatsApp payment reminders via Operations portal.',
                    Icons.account_balance,
                    AppColors.info,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String body, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          cross: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const Divider(height: 20),
            Text(body, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
