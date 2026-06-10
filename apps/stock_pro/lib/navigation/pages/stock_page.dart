import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:profile_feature/profile_feature.dart';
import 'package:stock_feature/stock_feature.dart';

/// Navigation wrapper that picks stock UI by user role.
@RoutePage()
class StockPage extends StatelessWidget {
  /// Creates the stock page.
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleGate(
      staff: StockScreen(),
      admin: AdminStockScreen(),
    );
  }
}
