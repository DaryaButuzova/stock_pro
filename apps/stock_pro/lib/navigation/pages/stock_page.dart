import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stock_feature/stock_feature.dart';

/// Navigation wrapper for [StockScreen].
@RoutePage()
class StockPage extends StatelessWidget {
  /// Creates the stock page.
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StockScreen();
  }
}
