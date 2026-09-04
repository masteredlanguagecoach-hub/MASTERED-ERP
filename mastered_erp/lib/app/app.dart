import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class MasteredErpApp extends StatelessWidget {
  const MasteredErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MASTERED ERP v8.0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
