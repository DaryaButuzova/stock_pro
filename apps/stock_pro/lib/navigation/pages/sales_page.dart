import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:profile_feature/profile_feature.dart';
import 'package:sales_feature/sales_feature.dart';

/// Navigation wrapper that picks sales UI by user role.
@RoutePage()
class SalesPage extends StatelessWidget {
  /// Creates the sales page.
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleGate(
      staff: SalesScreen(),
      admin: AdminSalesHistoryScreen(),
    );
  }
}
