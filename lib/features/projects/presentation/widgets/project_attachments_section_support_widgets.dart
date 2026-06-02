import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_attachment_entity.dart';

enum ProjectAttachmentsMarkupTool {
  pen,
  eraser,
  text,
  arrow,
  rectangle,
  circle,
}

class ProjectAttachmentsMarkupToolbar extends StatelessWidget {
  final ProjectAttachmentsMarkupTool tool;
  final Color color;
  final double strokeWidth;
  final double zoomLevel;
  final ValueChanged<ProjectAttachmentsMarkupTool> onToolChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ProjectAttachmentsMarkupToolbar({
    super.key,
    required this.tool,
    required this.color,
    required this.strokeWidth,
    required this.zoomLevel,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      (
        tool: ProjectAttachmentsMarkupTool.pen,
        icon: Icons.edit_rounded,
        label: 'قلم',
      ),
      (
        tool: ProjectAttachmentsMarkupTool.eraser,
        icon: Icons.cleaning_services_rounded,
        label: 'مسح',
      ),
      (
        tool: ProjectAttachmentsMarkupTool.text,
        icon: Icons.text_fields_rounded,
        label: 'نص',
      ),
      (
        tool: ProjectAttachmentsMarkupTool.arrow,
        icon: Icons.arrow_forward_rounded,
        label: 'سهم',
      ),
      (
        tool: ProjectAttachmentsMarkupTool.rectangle,
        icon: Icons.crop_square_rounded,
        label: 'مربع',
      ),
      (
        tool: ProjectAttachmentsMarkupTool.circle,
        icon: Icons.circle_outlined,
        label: 'دائرة',
      ),
    ];
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.primary,
      AppColors.success,
      Colors.black,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final item in tools)
            Tooltip(
              message: item.label,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: tool == item.tool
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.cardBackground,
                  foregroundColor: tool == item.tool
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  side: BorderSide(
                    color: tool == item.tool
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                onPressed: () => onToolChanged(item.tool),
                icon: Icon(item.icon, size: 18),
              ),
            ),
          const SizedBox(width: 4),
          for (final item in colors)
            InkWell(
              onTap: () => onColorChanged(item),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == item ? AppColors.textPrimary : Colors.white,
                    width: color == item ? 3 : 1,
                  ),
                ),
              ),
            ),
          SizedBox(
            width: 150,
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: strokeWidth,
              onChanged: onStrokeWidthChanged,
            ),
          ),
          ProjectAttachmentsZoomControls(
            zoomLevel: zoomLevel,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
            onReset: () {},
          ),
        ],
      ),
    );
  }
}

class ProjectAttachmentsZoomControls extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const ProjectAttachmentsZoomControls({
    super.key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'تصغير  (Ctrl/⌘ −)',
            child: InkWell(
              onTap: onZoomOut,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Icon(Icons.remove_rounded, size: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: AppColors.border),
                ),
              ),
              child: Text(
                '${(zoomLevel * 100).round()}%',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Tooltip(
            message: 'تكبير  (Ctrl/⌘ +)',
            child: InkWell(
              onTap: onZoomIn,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Icon(Icons.add_rounded, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectAttachmentsPreviewHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onClose;

  const ProjectAttachmentsPreviewHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.onClose,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }
}

class ProjectAttachmentsPdfPageIndicator extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const ProjectAttachmentsPdfPageIndicator({
    super.key,
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bool loaded = total > 0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProjectAttachmentsPageNavButton(
            icon: Icons.chevron_left_rounded,
            onTap: loaded ? onNext : null,
            tooltip: 'الصفحة التالية',
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 56),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: loaded
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$current',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' / $total',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
          ),
          _ProjectAttachmentsPageNavButton(
            icon: Icons.chevron_right_rounded,
            onTap: loaded ? onPrev : null,
            tooltip: 'الصفحة السابقة',
          ),
        ],
      ),
    );
  }
}

class _ProjectAttachmentsPageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _ProjectAttachmentsPageNavButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class ProjectAttachmentsPdfFooterHint extends StatelessWidget {
  final String text;

  const ProjectAttachmentsPdfFooterHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class ProjectAttachmentsImagePreviewDialog extends StatelessWidget {
  final ProjectAttachmentEntity attachment;
  final VoidCallback onDownload;

  const ProjectAttachmentsImagePreviewDialog({
    super.key,
    required this.attachment,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scaffold(
            backgroundColor: AppColors.cardBackground,
            body: Column(
              children: [
                ProjectAttachmentsPreviewHeader(
                  icon: Icons.image_outlined,
                  title: attachment.originalName,
                  onClose: () => Navigator.of(context).pop(),
                  trailing: IconButton(
                    tooltip: 'تحميل',
                    icon: const Icon(Icons.download_outlined),
                    onPressed: onDownload,
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: attachment.url,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectAttachmentTile extends StatefulWidget {
  final ProjectAttachmentEntity attachment;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const ProjectAttachmentTile({
    super.key,
    required this.attachment,
    required this.canDelete,
    required this.isDeleting,
    required this.onOpen,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  State<ProjectAttachmentTile> createState() => _ProjectAttachmentTileState();
}

class _ProjectAttachmentTileState extends State<ProjectAttachmentTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _typeColor(
                  widget.attachment.mimeType,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForMimeType(widget.attachment.mimeType),
                color: _typeColor(widget.attachment.mimeType),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.attachment.originalName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      ProjectAttachmentsMetaChip(
                        label: _formatSize(widget.attachment.size),
                        icon: Icons.data_usage_rounded,
                      ),
                      const SizedBox(width: 6),
                      ProjectAttachmentsMetaChip(
                        label: DateFormat(
                          'yyyy/MM/dd',
                        ).format(widget.attachment.createdAt),
                        icon: Icons.calendar_today_outlined,
                      ),
                      if (widget.attachment.uploadedByName?.isNotEmpty ==
                          true) ...[
                        const SizedBox(width: 6),
                        ProjectAttachmentsMetaChip(
                          label: widget.attachment.uploadedByName!,
                          icon: Icons.person_outline_rounded,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            ProjectAttachmentsTileActions(
              attachment: widget.attachment,
              canDelete: widget.canDelete,
              isDeleting: widget.isDeleting,
              onOpen: widget.onOpen,
              onDownload: widget.onDownload,
              onDelete: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_rounded;
    if (mimeType.contains('word')) return Icons.description_rounded;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart_rounded;
    }
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
      return Icons.slideshow_rounded;
    }
    if (mimeType.contains('zip')) return Icons.folder_zip_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _typeColor(String mimeType) {
    if (mimeType.startsWith('image/')) return const Color(0xFF0EA5E9);
    if (mimeType == 'application/pdf') return const Color(0xFFEF4444);
    if (mimeType.contains('word')) return const Color(0xFF3B82F6);
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return const Color(0xFF22C55E);
    }
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
      return const Color(0xFFF97316);
    }
    if (mimeType.contains('zip')) return const Color(0xFFA78BFA);
    return AppColors.textSecondary;
  }

  String _formatSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ProjectAttachmentsMetaChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const ProjectAttachmentsMetaChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class ProjectAttachmentsTileActions extends StatelessWidget {
  final ProjectAttachmentEntity attachment;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const ProjectAttachmentsTileActions({
    super.key,
    required this.attachment,
    required this.canDelete,
    required this.isDeleting,
    required this.onOpen,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProjectAttachmentsActionIconButton(
          icon: attachment.isPdf || attachment.isImage
              ? Icons.visibility_outlined
              : Icons.open_in_new_rounded,
          tooltip: attachment.isPdf || attachment.isImage ? 'معاينة' : 'فتح',
          onPressed: onOpen,
        ),
        ProjectAttachmentsActionIconButton(
          icon: Icons.download_outlined,
          tooltip: 'تحميل',
          onPressed: onDownload,
        ),
        if (canDelete)
          ProjectAttachmentsActionIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'حذف',
            color: AppColors.error,
            onPressed: isDeleting ? null : onDelete,
          ),
      ],
    );
  }
}

class ProjectAttachmentsActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const ProjectAttachmentsActionIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null
                ? AppColors.textMuted
                : (color ?? AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class ProjectAttachmentsCompactEmptyState extends StatelessWidget {
  const ProjectAttachmentsCompactEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_file_outlined,
              color: AppColors.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد مرفقات بعد',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اضغط على "إضافة" لرفع الملفات',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
