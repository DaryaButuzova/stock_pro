import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:ui_kit/ui_kit.dart';

/// Temporary showcase of ui_kit components.
/// To be replaced with proper app structure.
@RoutePage()
class UIKitShowcase extends StatelessWidget {
  /// Creates the showcase screen.
  const UIKitShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Typography'),
                    const SizedBox(height: 16),
                    const Text(
                      'Heading Large',
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Heading Medium',
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Heading Small',
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Body Large — Lorem ipsum dolor sit amet',
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Body Medium — Lorem ipsum dolor sit amet',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Body Small — Secondary text',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Caption — Hint text',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 32),

                    _sectionTitle('Colors'),
                    const SizedBox(height: 8),
                    _colorGroup('Primary', [
                      ('primary', AppColors.primary),
                      ('primaryLight', AppColors.primaryLight),
                      ('primaryDark', AppColors.primaryDark),
                      ('primarySubtle', AppColors.primarySubtle),
                      ('primaryMuted', AppColors.primaryMuted),
                    ]),
                    const SizedBox(height: 8),
                    _colorGroup('Secondary (Warm Sand)', [
                      ('secondary', AppColors.secondary),
                      ('secondaryLight', AppColors.secondaryLight),
                      ('secondaryDark', AppColors.secondaryDark),
                      ('secondaryMuted', AppColors.secondaryMuted),
                    ]),
                    const SizedBox(height: 8),
                    _colorGroup('Text', [
                      ('textPrimary', AppColors.textPrimary),
                      ('textSecondary', AppColors.textSecondary),
                      ('textHint', AppColors.textHint),
                      ('textDisabled', AppColors.textDisabled),
                      ('textInverse', AppColors.textInverse),
                    ]),
                    const SizedBox(height: 8),
                    _colorGroup('Status', [
                      ('success', AppColors.success),
                      ('successSubtle', AppColors.successSubtle),
                      ('warning', AppColors.warning),
                      ('warningSubtle', AppColors.warningSubtle),
                      ('error', AppColors.error),
                      ('errorSubtle', AppColors.errorSubtle),
                      ('info', AppColors.info),
                      ('infoSubtle', AppColors.infoSubtle),
                    ]),
                    const SizedBox(height: 8),
                    _colorGroup('Overlay', [
                      ('overlay', AppColors.overlay),
                      ('overlayLight', AppColors.overlayLight),
                    ]),
                    const SizedBox(height: 32),

                    _sectionTitle('Buttons'),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Primary',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Secondary',
                      onPressed: () {},
                      variant: AppButtonVariant.secondary,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Outlined',
                      onPressed: () {},
                      variant: AppButtonVariant.outlined,
                    ),
                    const SizedBox(height: 12),
                    const AppButton(
                      text: 'Disabled',
                      onPressed: null,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Loading…',
                      onPressed: () {},
                      isLoading: true,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Loading Secondary',
                      onPressed: () {},
                      variant: AppButtonVariant.secondary,
                      isLoading: true,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Loading Outlined',
                      onPressed: () {},
                      variant: AppButtonVariant.outlined,
                      isLoading: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: AppTextStyles.headingSmall);
  }

  Widget _colorGroup(
    String title,
    List<(String name, Color color)> colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(title, style: AppTextStyles.bodySmall),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in colors) _colorChip(color.$1, color.$2),
          ],
        ),
      ],
    );
  }

  Widget _colorChip(String label, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isLight(color) ? AppColors.divider : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  bool _isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }
}
