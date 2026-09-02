import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'login_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Navigation Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(AppConstants.logoPath, height: 40, fit: BoxFit.contain),
                      const SizedBox(width: 12),
                      const Column(
                        cross: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.academyName,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'ACADEMY ERP SYSTEM',
                            style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                    },
                    icon: const Icon(Icons.lock_outline, size: 16),
                    label: const Text('Sign In to ERP Portal'),
                  ),
                ],
              ),
            ),

            // Hero Section (Clean Public Introduction)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'MASTERED ACADEMY MANAGEMENT SYSTEM',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Empowering Excellence in Academy Operations, CRM & Fee Collections',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unified secure portal for student admissions, course ledgers, batch management, and academy financial accounting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 15),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                    },
                    icon: const Icon(Icons.login, size: 20),
                    label: const Text('SIGN IN TO PORTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
