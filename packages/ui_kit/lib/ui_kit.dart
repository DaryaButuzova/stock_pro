import 'dart:async';

import 'package:injectable/injectable.dart';

export 'src/colors/app_colors.dart';
export 'src/styles/text_styles.dart';
export 'src/widgets/app_button.dart';

/// DI module for UI components.
///
/// Currently does not register any dependencies.
/// Available for future extensions.
class UIKitModule extends MicroPackageModule {
  @override
  FutureOr<void> init(GetItHelper gh) {
    // UI components don't need DI registration
  }
}
