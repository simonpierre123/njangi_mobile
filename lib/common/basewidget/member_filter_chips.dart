import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

/// Chips de filtre horizontal scrollable, réutilisé dans plusieurs
/// écrans (Trésorerie > Contributions, Membres).
class MemberFilterChips extends StatelessWidget {
  const MemberFilterChips({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: AppDimensions.spaceSm.w),
        itemBuilder: (context, i) {
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.filterChipActiveBg : AppColors.filterChipInactiveBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.neutralGray : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}