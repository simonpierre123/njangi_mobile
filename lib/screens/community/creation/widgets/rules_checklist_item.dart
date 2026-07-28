import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

/// Item de checklist des règles — coche verte si activé, croix grise
/// atténuée sinon.
class RulesChecklistItem extends StatelessWidget {
  const RulesChecklistItem({super.key, required this.enabled, required this.label});

  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: enabled ? AppColors.ruleEnabledBg : AppColors.ruleDisabledBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              enabled ? Icons.check : Icons.close,
              size: 12,
              color: AppColors.neutralDark,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}