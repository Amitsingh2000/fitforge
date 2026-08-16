import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Deterministic gradient pair for a member avatar/detail header, derived from
/// a stable seed (user id / name) so the same client always shows the same
/// colors across screens.
List<Color> clientGradient(String seed) {
  const palettes = [
    [AppColors.accentBlue, AppColors.accentCyan],
    [AppColors.accentPurple, AppColors.accentCoral],
    [AppColors.accentOrange, AppColors.accentCoral],
    [AppColors.accentCyan, AppColors.accentBlue],
    [AppColors.accentBlue, AppColors.accentPurple],
    [AppColors.accentOrange, AppColors.accentPurple],
  ];
  final h = seed.hashCode.abs();
  return palettes[h % palettes.length];
}