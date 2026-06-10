import 'package:auto_route/auto_route.dart';
import 'package:stock_pro/navigation/pages/authorization_page.dart';
import 'package:stock_pro/navigation/pages/authorized_shell_page.dart';
import 'package:stock_pro/navigation/pages/profile_page.dart';
import 'package:stock_pro/navigation/pages/registration_page.dart';
import 'package:stock_pro/navigation/pages/sales_page.dart';
import 'package:stock_pro/navigation/pages/stock_page.dart';
import 'package:stock_pro/navigation/routes/app_routes.dart';
import 'package:stock_pro/ui/ui_kit_showcase.dart';

part 'app_router.gr.dart';

/// Root application router.
@AutoRouterConfig(
  replaceInRouteName: 'Page,Route|Showcase,Route',
)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: AuthorizationPageRoute.page,
      path: AppRoutes.authorization,
      initial: true,
    ),
    AutoRoute(
      page: RegistrationPageRoute.page,
      path: AppRoutes.registration,
    ),
    AutoRoute(
      page: AuthorizedShellPageRoute.page,
      path: AppRoutes.authorized,
      children: [
        AutoRoute(
          page: SalesPageRoute.page,
          path: AppRoutes.sales,
        ),
        AutoRoute(
          page: StockPageRoute.page,
          path: AppRoutes.stock,
        ),
        AutoRoute(
          page: ProfilePageRoute.page,
          path: AppRoutes.profile,
          initial: true,
        ),
      ],
    ),
    AutoRoute(
      page: UIKitShowcaseRoute.page,
      path: AppRoutes.showcase,
    ),
  ];
}
