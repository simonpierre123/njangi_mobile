import 'package:flutter/material.dart';
import '../../../../common/basewidget/shimmer_loading.dart';
import '../../../../utils/app_colors.dart';

enum TontineLoadingVariant { management, history, contribution }

class TontineLoadingSkeleton extends StatelessWidget {
  const TontineLoadingSkeleton({super.key, required this.variant});

  final TontineLoadingVariant variant;

  @override
  Widget build(BuildContext context) {
    final cardCount = switch (variant) {
      TontineLoadingVariant.management => 4,
      TontineLoadingVariant.history => 4,
      TontineLoadingVariant.contribution => 2,
    };

    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < cardCount; index++) ...[
            _SkeletonCard(variant: variant, index: index),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.variant, required this.index});

  final TontineLoadingVariant variant;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isSummary = variant == TontineLoadingVariant.management && index == 0;
    final isHistory = variant == TontineLoadingVariant.history;
    final isContribution = variant == TontineLoadingVariant.contribution;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 40, height: 40, isCircle: true),
              const SizedBox(width: 12),
              const Expanded(child: SkeletonBox(height: 16, width: 150)),
              if (isHistory || isSummary)
                const SkeletonBox(width: 52, height: 16),
            ],
          ),
          const SizedBox(height: 14),
          if (isSummary) ...[
            const SkeletonBox(height: 13, width: 110),
            const SizedBox(height: 10),
            const SkeletonBox(height: 24, width: 180),
            const SizedBox(height: 12),
            const SkeletonBox(height: 8),
          ] else if (isContribution) ...[
            const SkeletonBox(height: 13, width: 135),
            const SizedBox(height: 10),
            const SkeletonBox(height: 42),
            const SizedBox(height: 10),
            const SkeletonBox(height: 42),
          ] else ...[
            const SkeletonBox(height: 13, width: 190),
            const SizedBox(height: 8),
            const SkeletonBox(height: 13, width: 130),
          ],
        ],
      ),
    );
  }
}
