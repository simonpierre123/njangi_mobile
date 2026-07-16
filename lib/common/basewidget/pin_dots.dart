import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

/// Cases affichant l'avancement de saisie d'un code PIN.
/// La case active (index == length) a une bordure accentuée.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, this.digitCount = 4});

  final int length;
  final int digitCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(digitCount, (index) {
        final isFilled = index < length;
        final isActive = index == length;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppDimensions.spaceSm.w),
          width: 52.w,
          height: 52.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isActive ? AppColors.primaryDark : AppColors.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: isFilled
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        );
      }),
    );
  }
}