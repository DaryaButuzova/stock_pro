import 'package:authorization_feature/authorization_feature.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:registration_feature/registration_feature.dart';
import 'package:stock_pro/di/injection.config.dart';
import 'package:ui_kit/ui_kit.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(UIKitModule),
    ExternalModule(RegistrationModule),
    ExternalModule(AuthorizationModule),
  ],
)
/// Configures all dependencies via generated extension.
Future<void> configureDependencies() async => getIt.init();
