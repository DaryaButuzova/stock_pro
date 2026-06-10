import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sales_feature/sales_feature.dart';

/// Navigation wrapper for [SalesScreen].
@RoutePage()
class SalesPage extends StatelessWidget {
  /// Creates the sales page.
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SalesScreen();
  }
}
