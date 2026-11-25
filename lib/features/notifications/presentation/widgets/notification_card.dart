import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notification.isUnread
            ? AppColors.of(context).selectedSurface
            : AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArabicNumberTransformer.transform(notification.message),
                  style: AppTextStyles.of(context).bodyMedium.copyWith(
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      ArabicNumberTransformer.transform(notification.timestamp),
                      style: AppTextStyles.of(context).caption.copyWith(
                        color: AppColors.of(context).textMuted,
                      ),
                    ),
                    const Spacer(),
                    ...notification.actionButtons.map(
                      (button) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _NotificationActionButton(
                          button: button,
                          primaryColor: notification.iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationActionButton extends StatelessWidget {
  final NotificationActionButton button;
  final Color primaryColor;

  const _NotificationActionButton({
    required this.button,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = button.isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppColors.of(context).textSecondary,
            side: BorderSide(color: AppColors.of(context).border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          );

    final labelStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    return button.isPrimary
        ? ElevatedButton(
            onPressed: button.onPressed,
            style: style,
            child: Text(
              ArabicNumberTransformer.transform(button.label),
              style: labelStyle,
            ),
          )
        : OutlinedButton(
            onPressed: button.onPressed,
            style: style,
            child: Text(
              ArabicNumberTransformer.transform(button.label),
              style: labelStyle,
            ),
          );
  }
}
