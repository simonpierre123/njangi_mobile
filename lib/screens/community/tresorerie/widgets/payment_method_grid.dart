import 'package:flutter/material.dart';
import '../../../../Models/contribution_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Grille 3 colonnes de sélection du mode de paiement.
class PaymentMethodGrid extends StatelessWidget {
  const PaymentMethodGrid({super.key, required this.selected, required this.onSelect});

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;

  static const _icons = {
    PaymentMethod.cash: Icons.payments_outlined,
    PaymentMethod.mobileMoney: Icons.phone_iphone,
    PaymentMethod.transfer: Icons.account_balance_outlined,
  };

  static const _labelKeys = {
    PaymentMethod.cash: 'payment_cash',
    PaymentMethod.mobileMoney: 'payment_mobile_money',
    PaymentMethod.transfer: 'payment_transfer',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final method in PaymentMethod.values) ...[
          Expanded(
            child: _MethodTile(
              icon: _icons[method]!,
              label: AppLocalizations.t(_labelKeys[method]!),
              isSelected: selected == method,
              onTap: () => onSelect(method),
            ),
          ),
          if (method != PaymentMethod.values.last) SizedBox(width: AppDimensions.spaceSm.w),
        ],
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.icon, required this.label, required this.isSelected, required this.onTap});

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.tagMintBg : AppColors.paymentMethodUnselectedBg,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMd.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.inputBorder, width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}