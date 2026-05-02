import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_attachment_entity.dart';

// ─── Main Section ────────────────────────────────────────────────────────────

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
              const _CompactEmptyAttachments()
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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

// ─── Open Attachment ──────────────────────────────────────────────────────────

Future<void> _openProjectAttachment(
  BuildContext context,
  ProjectAttachmentEntity attachment,
) async {
  if (attachment.isImage) {
    await showDialog<void>(
      context: context,
      builder: (context) => _ImagePreviewDialog(attachment: attachment),
    );
    return;
  }

  if (attachment.isPdf) {
    await showDialog<void>(
      context: context,
      builder: (context) => _PdfAttachmentPreview(attachment: attachment),
    );
    return;
  }

  final uri = Uri.parse(attachment.url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    _showSnackBar(context, 'تعذر فتح الملف');
  }
}

// ─── Image Preview Dialog ─────────────────────────────────────────────────────

class _ImagePreviewDialog extends StatelessWidget {
  final ProjectAttachmentEntity attachment;

  const _ImagePreviewDialog({required this.attachment});

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
                _DialogHeader(
                  icon: Icons.image_outlined,
                  title: attachment.originalName,
                  trailing: IconButton(
                    tooltip: 'تحميل',
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () =>
                        _downloadProjectAttachment(context, attachment),
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

// ─── PDF Preview Dialog ───────────────────────────────────────────────────────

class _PdfAttachmentPreview extends StatefulWidget {
  final ProjectAttachmentEntity attachment;

  const _PdfAttachmentPreview({required this.attachment});

  @override
  State<_PdfAttachmentPreview> createState() => _PdfAttachmentPreviewState();
}

class _PdfAttachmentPreviewState extends State<_PdfAttachmentPreview> {
  final PdfViewerController _controller = PdfViewerController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'pdf_attachment_preview');
  double _zoomLevel = 1.0;
  int _currentPage = 1;
  int _totalPages = 0;

  // Tracks the zoom level at the start of a pinch/pan-zoom gesture.
  double _baseZoom = 1.0;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setZoom(double zoomLevel) {
    final clamped = zoomLevel.clamp(0.5, 5.0);
    setState(() {
      _zoomLevel = clamped;
      _controller.zoomLevel = clamped;
    });
  }

  // ── Keyboard ─────────────────────────────────────────────────────────────

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final isModifier =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final key = event.logicalKey;

    if (isModifier) {
      if (key == LogicalKeyboardKey.equal ||
          key == LogicalKeyboardKey.add ||
          key == LogicalKeyboardKey.numpadAdd) {
        _setZoom(_zoomLevel + 0.25);
        return;
      }
      if (key == LogicalKeyboardKey.minus ||
          key == LogicalKeyboardKey.numpadSubtract) {
        _setZoom(_zoomLevel - 0.25);
        return;
      }
      if (key == LogicalKeyboardKey.digit0 ||
          key == LogicalKeyboardKey.numpad0) {
        _setZoom(1.0);
        return;
      }
    }

    // RTL: ← / PageDown / ↓  → next page (visual "forward" in Arabic)
    //      → / PageUp  / ↑   → previous page
    if (key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft) {
      _controller.nextPage();
      return;
    }
    if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowRight) {
      _controller.previousPage();
    }
  }

  // ── Mouse scroll wheel: Ctrl/⌘ + scroll → zoom ──────────────────────────

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final isModifier =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!isModifier) return;
    final delta = event.scrollDelta.dy < 0 ? 0.15 : -0.15;
    _setZoom(_zoomLevel + delta);
  }

  // ── Trackpad pinch (PointerPanZoomUpdateEvent) ───────────────────────────

  void _handlePanZoomStart(PointerPanZoomStartEvent event) {
    _baseZoom = _zoomLevel;
  }

  void _handlePanZoomUpdate(PointerPanZoomUpdateEvent event) {
    // event.scale == 1.0 for pure panning; > 1 spreading, < 1 pinching.
    if (event.scale != 1.0) {
      _setZoom(_baseZoom * event.scale);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 820),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scaffold(
            backgroundColor: AppColors.cardBackground,
            body: Column(
              children: [
                // ── Row 1: title + close ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.attachment.originalName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'إغلاق',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                // ── Row 2: toolbar (page indicator + zoom + download) ──────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      // Page indicator — always shown; shows "…" before load
                      _PdfPageIndicator(
                        current: _currentPage,
                        total: _totalPages,
                        onPrev: (_totalPages > 0 && _currentPage > 1)
                            ? () => _controller.previousPage()
                            : null,
                        onNext: (_totalPages > 0 && _currentPage < _totalPages)
                            ? () => _controller.nextPage()
                            : null,
                      ),
                      const Spacer(),
                      // Zoom controls
                      _ZoomControls(
                        zoomLevel: _zoomLevel,
                        onZoomIn: () => _setZoom(_zoomLevel + 0.25),
                        onZoomOut: () => _setZoom(_zoomLevel - 0.25),
                        onReset: () => _setZoom(1.0),
                      ),
                      const SizedBox(width: 8),
                      // Download
                      Tooltip(
                        message: 'تحميل',
                        child: InkWell(
                          onTap: () => _downloadProjectAttachment(
                            context,
                            widget.attachment,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.download_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── PDF Viewer ─────────────────────────────────────────────
                Expanded(
                  child: KeyboardListener(
                    focusNode: _focusNode,
                    autofocus: true,
                    onKeyEvent: _handleKeyEvent,
                    child: Listener(
                      // Mouse scroll wheel zoom (Ctrl/⌘)
                      onPointerSignal: _handlePointerSignal,
                      // Trackpad pinch zoom
                      onPointerPanZoomStart: _handlePanZoomStart,
                      onPointerPanZoomUpdate: _handlePanZoomUpdate,
                      child: SfPdfViewer.network(
                        widget.attachment.url,
                        controller: _controller,
                        pageLayoutMode: PdfPageLayoutMode.single,
                        canShowPaginationDialog: false,
                        canShowScrollHead: false,
                        canShowScrollStatus: false,
                        onPageChanged: (details) {
                          setState(() {
                            _currentPage = details.newPageNumber;
                          });
                        },
                        onDocumentLoaded: (details) {
                          setState(() {
                            _totalPages = details.document.pages.count;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // ── Footer hint ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                        isDesktop
                            ? 'Ctrl/⌘ + تمرير أو قرصة للتكبير  ·  ← → للتنقل بين الصفحات'
                            : 'قرصة بإصبعين للتكبير  ·  اسحب للتنقل',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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

// ─── Reusable Dialog Header ───────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _DialogHeader({required this.icon, required this.title, this.trailing});

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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }
}

// ─── PDF Page Indicator ───────────────────────────────────────────────────────

class _PdfPageIndicator extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PdfPageIndicator({
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
          // RTL: right chevron → visual "forward" = next page
          _PageNavButton(
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
          // RTL: left chevron → visual "back" = previous page
          _PageNavButton(
            icon: Icons.chevron_right_rounded,
            onTap: loaded ? onPrev : null,
            tooltip: 'الصفحة السابقة',
          ),
        ],
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _PageNavButton({required this.icon, required this.tooltip, this.onTap});

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

// ─── Zoom Controls ────────────────────────────────────────────────────────────

class _ZoomControls extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const _ZoomControls({
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

// ─── Download ─────────────────────────────────────────────────────────────────

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

class _AttachmentTile extends StatefulWidget {
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
  State<_AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<_AttachmentTile> {
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
            // File type icon with colored background
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

            // File info
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
                      _MetaChip(
                        label: _formatSize(widget.attachment.size),
                        icon: Icons.data_usage_rounded,
                      ),
                      const SizedBox(width: 6),
                      _MetaChip(
                        label: DateFormat(
                          'yyyy/MM/dd',
                        ).format(widget.attachment.createdAt),
                        icon: Icons.calendar_today_outlined,
                      ),
                      if (widget.attachment.uploadedByName?.isNotEmpty ==
                          true) ...[
                        const SizedBox(width: 6),
                        _MetaChip(
                          label: widget.attachment.uploadedByName!,
                          icon: Icons.person_outline_rounded,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            _TileActions(
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

// ─── Meta Chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetaChip({required this.label, required this.icon});

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

// ─── Tile Actions ─────────────────────────────────────────────────────────────

class _TileActions extends StatelessWidget {
  final ProjectAttachmentEntity attachment;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _TileActions({
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
        _ActionIconButton(
          icon: attachment.isPdf || attachment.isImage
              ? Icons.visibility_outlined
              : Icons.open_in_new_rounded,
          tooltip: attachment.isPdf || attachment.isImage ? 'معاينة' : 'فتح',
          onPressed: onOpen,
        ),
        _ActionIconButton(
          icon: Icons.download_outlined,
          tooltip: 'تحميل',
          onPressed: onDownload,
        ),
        if (canDelete)
          _ActionIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'حذف',
            color: AppColors.error,
            onPressed: isDeleting ? null : onDelete,
          ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _ActionIconButton({
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _CompactEmptyAttachments extends StatelessWidget {
  const _CompactEmptyAttachments();

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
