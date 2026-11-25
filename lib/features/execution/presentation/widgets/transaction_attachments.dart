import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/execution_models.dart';

class TransactionAttachments extends StatelessWidget {
  final List<TransactionAttachmentModel> attachments;
  final bool compact;

  const TransactionAttachments({
    super.key,
    required this.attachments,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: attachments.asMap().entries.map((entry) {
        final attachment = entry.value;
        final label = attachment.fileName?.trim().isNotEmpty == true
            ? attachment.fileName!.trim()
            : 'مرفق ${entry.key + 1}';

        return InkWell(
          onTap: () => _openAttachment(context, attachment.url),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: BoxConstraints(maxWidth: compact ? 120 : 180),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 9,
              vertical: compact ? 3 : 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.of(context).primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.of(context).primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attachment_outlined,
                  size: compact ? 12 : 14,
                  color: AppColors.of(context).primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.of(context).caption.copyWith(
                      color: AppColors.of(context).primary,
                      fontSize: compact ? 10 : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _openAttachment(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.of(context).cardBackground,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.of(context).border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: AppColors.of(context).primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'معاينة المرفق',
                          style: AppTextStyles.of(context).bodyMedium.copyWith(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                        color: AppColors.of(context).textSecondary,
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 420,
                              height: 320,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              width: 420,
                              height: 220,
                              child: Center(
                                child: Text(
                                  'تعذر عرض الصورة',
                                  style: AppTextStyles.of(context).bodyMedium
                                      .copyWith(
                                        color: AppColors.of(context).error,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
