import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Indicateur de progression pour carrousels (onboarding, etc.).
/// Le point actif est une pilule allongée, les autres sont des points.
class AppDotsIndicator extends StatelessWidget {
  const AppDotsIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryDark : AppColors.neutralGrayLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}