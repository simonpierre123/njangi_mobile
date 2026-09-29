import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Champ stepper numérique labellisé — boutons − / + de part et
/// d'autre d'une valeur centrale (ex: "Nombre maximum d'administrateurs").
class NumberStepperField extends StatelessWidget {
  const NumberStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        SizedBox(height: AppDimensions.spaceXs.h),
        Row(
          children: [
            _StepButton(icon: Icons.remove, onTap: value > min ? () => onChanged(value - 1) : null),
            SizedBox(width: AppDimensions.spaceSm.w),
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Text(
                  '$value',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.spaceSm.w),
            _StepButton(icon: Icons.add, onTap: value < max ? () => onChanged(value + 1) : null),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.tagMintBg : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: enabled ? AppColors.primaryDark : AppColors.textSecondary),
        ),
      ),
    );
  }
}