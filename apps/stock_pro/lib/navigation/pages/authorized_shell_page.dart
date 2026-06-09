import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:stock_pro/di/injection.dart';
import 'package:stock_pro/navigation/app_router.dart';

/// Authorized zone shell with bottom navigation tabs.
@RoutePage()
class AuthorizedShellPage extends StatefulWidget {
  /// Creates the authorized shell page.
  const AuthorizedShellPage({super.key});

  @override
  State<AuthorizedShellPage> createState() => _AuthorizedShellPageState();
}

class _AuthorizedShellPageState extends State<AuthorizedShellPage> {
  @override
  void initState() {
    super.initState();
    getIt<GoodsRealtimeService>().start();
  }

  @override
  void dispose() {
    unawaited(getIt<GoodsRealtimeService>().stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        SalesPageRoute(),
        StockPageRoute(),
        ProfilePageRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale),
              label: 'Продажи',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Склад',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        );
      },
    );
  }
}
