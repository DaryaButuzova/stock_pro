import 'package:auto_route/auto_route.dart';
import 'package:stock_pro/ui/ui_kit_showcase.dart';

part 'app_router.gr.dart';

/// Root application router.
@AutoRouterConfig(
  replaceInRouteName: 'Showcase,Route',
)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: UIKitRoute.page, path: '/', initial: true),
      ];
}
