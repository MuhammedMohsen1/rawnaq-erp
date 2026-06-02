import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_attachment_entity.dart';
import 'project_attachments_section_support_widgets.dart';
import 'project_attachments_section_pdf_dialogs.dart';

// ─── Main Section ────────────────────────────────────────────────────────────

class ProjectAttachmentsSection extends StatelessWidget {
  final List<ProjectAttachmentEntity> attachments;
  final bool canDelete;
  final bool canUpload;
  final bool isUploading;
  final bool isDeleting;
  final VoidCallback onUpload;
  final ValueChanged<ProjectAttachmentEntity> onDelete;
  final Future<void> Function(
    ProjectAttachmentEntity attachment,
    List<int> bytes,
  )
  onReplacePdf;

  const ProjectAttachmentsSection({
    super.key,
    required this.attachments,
    required this.canDelete,
    this.canUpload = true,
    required this.isUploading,
    required this.isDeleting,
    required this.onUpload,
    required this.onDelete,
    required this.onReplacePdf,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAttachments = attachments.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: attachments.isNotEmpty,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.attach_file_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: attachments.isEmpty
                ? Text(
                    'أضف ملفات المشروع عند الحاجة',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : Text(
                    visibleAttachments.map((a) => a.originalName).join('، '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canUpload)
                _UploadButton(isUploading: isUploading, onUpload: onUpload),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          children: [
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            if (attachments.isEmpty)
              const ProjectAttachmentsCompactEmptyState()
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final attachment = attachments[index];
                    return ProjectAttachmentTile(
                      attachment: attachment,
                      canDelete: canDelete,
                      isDeleting: isDeleting,
                      onOpen: () => _openProjectAttachment(
                        context,
                        attachment,
                        onReplacePdf,
                      ),
                      onDownload: () =>
                          _downloadProjectAttachment(context, attachment),
                      onDelete: () => onDelete(attachment),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Upload Button ────────────────────────────────────────────────────────────

class _UploadButton extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onUpload;

  const _UploadButton({required this.isUploading, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'إضافة مرفق',
      child: InkWell(
        onTap: isUploading ? null : onUpload,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'إضافة',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────

class _AttachmentCountBadge extends StatelessWidget {
  final int count;

  const _AttachmentCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: count > 0
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.caption.copyWith(
          color: count > 0 ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Download ─────────────────────────────────────────────────────────────────

Future<void> _openProjectAttachment(
  BuildContext context,
  ProjectAttachmentEntity attachment,
  Future<void> Function(ProjectAttachmentEntity attachment, List<int> bytes)
  onReplacePdf,
) async {
  if (attachment.isImage || attachment.isPdf) {
    await openProjectAttachment(
      context,
      attachment,
      onReplacePdf,
      (attachment) => _downloadProjectAttachment(context, attachment),
    );
    return;
  }

  final uri = Uri.parse(attachment.url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    _showSnackBar(context, 'تعذر فتح الملف');
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('تم تحميل: $fileName')),
          ],
        ),
        action: SnackBarAction(
          label: 'فتح',
          onPressed: () => OpenFile.open(targetPath),
        ),
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    _showSnackBar(context, 'تعذر تحميل الملف');
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(message),
    ),
  );
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

// ─── Attachment Tile ──────────────────────────────────────────────────────────
