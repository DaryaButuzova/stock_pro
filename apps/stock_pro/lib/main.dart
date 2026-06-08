import 'package:flutter/material.dart';
import 'package:stock_pro/di/injection.dart';

import 'package:stock_pro/navigation/app_router.dart';
import 'package:ui_kit/ui_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const StockProApp());
}

/// Root application widget.
class StockProApp extends StatelessWidget {
  /// Creates the root application.
  const StockProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stock Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: appTextTheme,
      ),
      routerConfig: _appRouter.config(),
    );
  }

  static final _appRouter = AppRouter();
}
