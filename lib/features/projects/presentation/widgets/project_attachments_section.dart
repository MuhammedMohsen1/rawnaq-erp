import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_attachment_entity.dart';

class ProjectAttachmentsSection extends StatelessWidget {
  final List<ProjectAttachmentEntity> attachments;
  final bool canDelete;
  final bool isUploading;
  final bool isDeleting;
  final VoidCallback onUpload;
  final ValueChanged<ProjectAttachmentEntity> onDelete;

  const ProjectAttachmentsSection({
    super.key,
    required this.attachments,
    required this.canDelete,
    required this.isUploading,
    required this.isDeleting,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAttachments = attachments.take(3).toList();

    return ExpansionTile(
      initiallyExpanded: attachments.isNotEmpty,
      tilePadding: const EdgeInsets.symmetric(horizontal: 14),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.cardBackground,
      collapsedBackgroundColor: AppColors.cardBackground,
      leading: const Icon(Icons.attach_file, color: AppColors.primary),
      title: Row(
        children: [
          Text(
            'المرفقات',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          _AttachmentCountBadge(count: attachments.length),
        ],
      ),
      subtitle: attachments.isEmpty
          ? Text(
              'أضف ملفات المشروع عند الحاجة',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Text(
              visibleAttachments
                  .map((attachment) => attachment.originalName)
                  .join('، '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'إضافة مرفقات',
            onPressed: isUploading ? null : onUpload,
            icon: isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
          const Icon(Icons.expand_more),
        ],
      ),
      children: [
        if (attachments.isEmpty)
          const _CompactEmptyAttachments()
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _AttachmentTile(
                  attachment: attachment,
                  canDelete: canDelete,
                  isDeleting: isDeleting,
                  onOpen: () => _openProjectAttachment(context, attachment),
                  onDownload: () =>
                      _downloadProjectAttachment(context, attachment),
                  onDelete: () => onDelete(attachment),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AttachmentCountBadge extends StatelessWidget {
  final int count;

  const _AttachmentCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Future<void> _openProjectAttachment(
  BuildContext context,
  ProjectAttachmentEntity attachment,
) async {
  if (attachment.isImage) {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        attachment.originalName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: CachedNetworkImage(
                  imageUrl: attachment.url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return;
  }

  if (attachment.isPdf) {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachment.originalName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'تحميل',
                      onPressed: () =>
                          _downloadProjectAttachment(context, attachment),
                      icon: const Icon(Icons.download_outlined),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SfPdfViewer.network(
                  attachment.url,
                  canShowPaginationDialog: true,
                  canShowScrollHead: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return;
  }

  final uri = Uri.parse(attachment.url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذر فتح الملف')));
  }
}

Future<void> _downloadProjectAttachment(
  BuildContext context,
  ProjectAttachmentEntity attachment,
) async {
  if (kIsWeb) {
    final uri = Uri.parse(attachment.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  try {
    final directory =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final fileName = _safeFileName(attachment.originalName);
    final targetPath = await _availableDownloadPath(directory.path, fileName);

    await Dio().download(attachment.url, targetPath);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحميل الملف: $fileName'),
        action: SnackBarAction(
          label: 'فتح',
          onPressed: () => OpenFile.open(targetPath),
        ),
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذر تحميل الملف')));
  }
}

String _safeFileName(String fileName) {
  final sanitized = fileName
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return sanitized.isEmpty ? 'attachment' : sanitized;
}

Future<String> _availableDownloadPath(
  String directoryPath,
  String fileName,
) async {
  final candidate = File('$directoryPath${Platform.pathSeparator}$fileName');
  if (!await candidate.exists()) return candidate.path;

  final dotIndex = fileName.lastIndexOf('.');
  final baseName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  final extension = dotIndex > 0 ? fileName.substring(dotIndex) : '';
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  return '$directoryPath${Platform.pathSeparator}${baseName}_$timestamp$extension';
}

class _AttachmentTile extends StatelessWidget {
  final ProjectAttachmentEntity attachment;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _AttachmentTile({
    required this.attachment,
    required this.canDelete,
    required this.isDeleting,
    required this.onOpen,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(_iconForMimeType(attachment.mimeType), color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.originalName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    _formatSize(attachment.size),
                    DateFormat('yyyy/MM/dd').format(attachment.createdAt),
                    if (attachment.uploadedByName?.isNotEmpty == true)
                      attachment.uploadedByName!,
                  ].join('  |  '),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: attachment.isPdf || attachment.isImage ? 'معاينة' : 'فتح',
            visualDensity: VisualDensity.compact,
            onPressed: onOpen,
            icon: Icon(
              attachment.isPdf || attachment.isImage
                  ? Icons.visibility
                  : Icons.open_in_new,
            ),
          ),
          IconButton(
            tooltip: 'تحميل',
            visualDensity: VisualDensity.compact,
            onPressed: onDownload,
            icon: const Icon(Icons.download_outlined),
          ),
          if (canDelete)
            IconButton(
              tooltip: 'حذف',
              visualDensity: VisualDensity.compact,
              onPressed: isDeleting ? null : onDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
        ],
      ),
    );
  }

  IconData _iconForMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('word')) return Icons.description_outlined;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart_outlined;
    }
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
      return Icons.slideshow_outlined;
    }
    if (mimeType.contains('zip')) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  String _formatSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _CompactEmptyAttachments extends StatelessWidget {
  const _CompactEmptyAttachments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.attach_file_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'لا توجد مرفقات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
