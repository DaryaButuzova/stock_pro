import 'package:auto_route/auto_route.dart';
import 'package:stock_pro/features/authorized_zone/profile/profile.dart';
import 'package:stock_pro/features/unauthorized_zone/login/login.dart';
import 'package:stock_pro/features/unauthorized_zone/registration/registration.dart';
import 'package:stock_pro/ui/ui_kit_showcase.dart';

part 'app_router.gr.dart';

/// Root application router.
@AutoRouterConfig(
  replaceInRouteName: 'Screen,Route|Showcase,Route',
)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginScreenRoute.page, path: '/login', initial: true),
    AutoRoute(
      page: AppRegistrationScreenRoute.page,
      path: '/registration',
    ),
    AutoRoute(page: ProfilePageRoute.page, path: '/profile'),
    AutoRoute(page: UIKitShowcaseRoute.page, path: '/showcase'),
  ];
}
