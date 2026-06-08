import 'package:flutter/material.dart';

/// App color palette based on a soft lavender primary with warm accents.
abstract final class AppColors {
  // ——— Primary (Lavender) ———

  /// Main brand — soft lavender `#7E57C2`
  static const Color primary = Color(0xFF7E57C2);

  /// Lighter lavender for hover/active states `#9575CD`
  static const Color primaryLight = Color(0xFF9575CD);

  /// Deeper purple for pressed/important states `#5E35B1`
  static const Color primaryDark = Color(0xFF5E35B1);

  /// Very light lavender for subtle backgrounds `#EDE7F6`
  static const Color primarySubtle = Color(0xFFEDE7F6);

  /// Ultra-light lavender tint for large areas `#F5F0FC`
  static const Color primaryMuted = Color(0xFFF5F0FC);

  // ——— On-colors (content on top of colored backgrounds) ———

  /// Text/icon on primary background — pure white
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text/icon on primary light — pure white
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  /// Text/icon on primary dark — soft white `#F3EEFA`
  static const Color onPrimaryDark = Color(0xFFF3EEFA);

  // ——— Secondary (Warm Sand) ———

  /// Warm sand — complementary neutral `#C9B99A`
  static const Color secondary = Color(0xFFC9B99A);

  /// Lighter warm sand `#DDD0B5`
  static const Color secondaryLight = Color(0xFFDDD0B5);

  /// Darker warm brown `#8C7A5E`
  static const Color secondaryDark = Color(0xFF8C7A5E);

  /// Very subtle warm tint `#F2EDE4`
  static const Color secondaryMuted = Color(0xFFF2EDE4);

  // ——— On-secondary ———

  /// Text/icon on secondary background — dark warm brown `#3E342A`
  static const Color onSecondary = Color(0xFF3E342A);

  /// Text/icon on secondary light — dark warm brown `#3E342A`
  static const Color onSecondaryLight = Color(0xFF3E342A);

  // ——— Neutral ———

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Warm off-white background `#FAF8F5`
  static const Color background = Color(0xFFFAF8F5);

  /// Surface / card — near-white with warmth `#FFFFFF`
  static const Color surface = Color(0xFFFFFFFF);

  /// Elevated surface with subtle warmth `#FFFDF9`
  static const Color surfaceVariant = Color(0xFFFFFDF9);

  /// Soft warm divider `#E8E4DF`
  static const Color divider = Color(0xFFE8E4DF);

  /// Lighter warm border `#F0EDE8`
  static const Color border = Color(0xFFF0EDE8);

  // ——— Overlay ———

  /// Dark overlay with transparency — 40% warm black `#662C2C2C`
  static const Color overlay = Color(0x662C2C2C);

  /// Light overlay — lavender-tinted 20% `#33EDE7F6`
  static const Color overlayLight = Color(0x33EDE7F6);

  // ——— Text ———

  /// Primary text — warm charcoal `#2C2C2C`
  static const Color textPrimary = Color(0xFF2C2C2C);

  /// Secondary text — soft brownish grey `#6D6D6D`
  static const Color textSecondary = Color(0xFF6D6D6D);

  /// Hint / placeholder text — light warm grey `#A39F9A`
  static const Color textHint = Color(0xFFA39F9A);

  /// Disabled / inactive text — faded warm grey `#C4C0BA`
  static const Color textDisabled = Color(0xFFC4C0BA);

  /// Inverse text — light on dark backgrounds `#F5F0E8`
  static const Color textInverse = Color(0xFFF5F0E8);

  // ——— Status / Accents (Warm) ———

  /// Success — warm sage green `#6BAF6B`
  static const Color success = Color(0xFF6BAF6B);

  /// Success subtle — soft sage tint `#E8F3E8`
  static const Color successSubtle = Color(0xFFE8F3E8);

  /// Warning — warm amber `#F0A500`
  static const Color warning = Color(0xFFF0A500);

  /// Warning subtle — soft amber tint `#FFF4DC`
  static const Color warningSubtle = Color(0xFFFFF4DC);

  /// Error — warm terracotta `#E06050`
  static const Color error = Color(0xFFE06050);

  /// Error subtle — soft terracotta tint `#FCEAE6`
  static const Color errorSubtle = Color(0xFFFCEAE6);

  /// Info — soft periwinkle `#5C9CE6`
  static const Color info = Color(0xFF5C9CE6);

  /// Info subtle — soft periwinkle tint `#E5F0FA`
  static const Color infoSubtle = Color(0xFFE5F0FA);
}
