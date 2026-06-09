import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Placeholder for the sales tab (not implemented yet).
@RoutePage()
class SalesPage extends StatelessWidget {
  /// Creates the sales page.
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Продажи')),
      body: const Center(
        child: Text(
          'Раздел в разработке',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
