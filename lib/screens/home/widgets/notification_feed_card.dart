import 'package:flutter/material.dart';
import '../../../Models/notification_feed_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Carte d'une notification — fond teinté + pastille verte si non lue,
/// fond blanc bordé sinon.
class NotificationFeedCard extends StatelessWidget {
  const NotificationFeedCard({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: item.isUnread ? AppColors.mintPale : AppColors.inputBorder, width: item.isUnread ? 1.5 : 1),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: item.iconBg, shape: BoxShape.circle),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: item.isUnread ? AppColors.secondaryGreen : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(item.timeLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (item.isUnread)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.secondaryGreen, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}