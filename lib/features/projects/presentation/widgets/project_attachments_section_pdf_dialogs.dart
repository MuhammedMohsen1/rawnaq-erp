import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_attachment_entity.dart';
import 'project_attachments_section_support_widgets.dart';

Future<void> openProjectAttachment(
  BuildContext context,
  ProjectAttachmentEntity attachment,
  Future<void> Function(ProjectAttachmentEntity attachment, List<int> bytes)
  onReplacePdf,
  Future<void> Function(ProjectAttachmentEntity attachment) onDownload,
) async {
  if (attachment.isImage) {
    await showDialog<void>(
      context: context,
      builder: (context) => ProjectAttachmentsImagePreviewDialog(
        attachment: attachment,
        onDownload: () => onDownload(attachment),
      ),
    );
    return;
  }

  if (attachment.isPdf) {
    await showDialog<void>(
      context: context,
      builder: (context) => _PdfAttachmentPreview(
        attachment: attachment,
        onReplacePdf: onReplacePdf,
        onDownload: onDownload,
      ),
    );
    return;
  }

  if (!context.mounted) return;
  _showSnackBar(context, 'تعذر فتح الملف');
}

class _PdfAttachmentPreview extends StatefulWidget {
  final ProjectAttachmentEntity attachment;
  final Future<void> Function(
    ProjectAttachmentEntity attachment,
    List<int> bytes,
  )
  onReplacePdf;
  final Future<void> Function(ProjectAttachmentEntity attachment) onDownload;

  const _PdfAttachmentPreview({
    required this.attachment,
    required this.onReplacePdf,
    required this.onDownload,
  });

  @override
  State<_PdfAttachmentPreview> createState() => _PdfAttachmentPreviewState();
}

class _PdfAttachmentPreviewState extends State<_PdfAttachmentPreview> {
  final PdfViewerController _controller = PdfViewerController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'pdf_attachment_preview');
  double _zoomLevel = 1.0;
  int _currentPage = 1;
  int _totalPages = 0;
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

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final isModifier =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!isModifier) return;
    final delta = event.scrollDelta.dy < 0 ? 0.15 : -0.15;
    _setZoom(_zoomLevel + delta);
  }

  void _handlePanZoomStart(PointerPanZoomStartEvent event) {
    _baseZoom = _zoomLevel;
  }

  void _handlePanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (event.scale != 1.0) {
      _setZoom(_baseZoom * event.scale);
    }
  }

  Future<void> _openEditor() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PdfMarkupEditorDialog(
        attachment: widget.attachment,
        onSave: (bytes) => widget.onReplacePdf(widget.attachment, bytes),
      ),
    );
  }

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
                      ProjectAttachmentsPdfPageIndicator(
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
                      ProjectAttachmentsZoomControls(
                        zoomLevel: _zoomLevel,
                        onZoomIn: () => _setZoom(_zoomLevel + 0.25),
                        onZoomOut: () => _setZoom(_zoomLevel - 0.25),
                        onReset: () => _setZoom(1.0),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'تعديل',
                        child: InkWell(
                          onTap: _openEditor,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'تحميل',
                        child: InkWell(
                          onTap: () => widget.onDownload(widget.attachment),
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
                Expanded(
                  child: KeyboardListener(
                    focusNode: _focusNode,
                    autofocus: true,
                    onKeyEvent: _handleKeyEvent,
                    child: Listener(
                      onPointerSignal: _handlePointerSignal,
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

class _PdfMarkupEditorDialog extends StatefulWidget {
  final ProjectAttachmentEntity attachment;
  final Future<void> Function(List<int> bytes) onSave;

  const _PdfMarkupEditorDialog({
    required this.attachment,
    required this.onSave,
  });

  @override
  State<_PdfMarkupEditorDialog> createState() => _PdfMarkupEditorDialogState();
}

class _PdfMarkupEditorDialogState extends State<_PdfMarkupEditorDialog> {
  final PdfViewerController _controller = PdfViewerController();
  final List<_PdfMarkup> _markups = [];
  final List<_PdfMarkup> _redoStack = [];
  List<int>? _pdfBytes;
  ProjectAttachmentsMarkupTool _tool = ProjectAttachmentsMarkupTool.pen;
  Color _color = AppColors.error;
  double _strokeWidth = 3;
  double _zoomLevel = 1;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  _PdfMarkupDraft? _draft;

  bool get _hasUnsavedChanges => _markups.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadPdfBytes();
  }

  Future<void> _loadPdfBytes() async {
    try {
      final response = await Dio().get<List<int>>(
        widget.attachment.url,
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() {
        _pdfBytes = response.data ?? <int>[];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(context, 'تعذر تحميل ملف PDF للتعديل');
    }
  }

  void _setZoom(double value) {
    final clamped = value.clamp(0.75, 4.0);
    setState(() {
      _zoomLevel = clamped;
      _controller.zoomLevel = clamped;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء التعديل'),
        content: const Text('هناك تعديلات غير محفوظة. هل تريد إغلاق المحرر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('إغلاق بدون حفظ'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _undo() {
    if (_markups.isEmpty) return;
    setState(() => _redoStack.add(_markups.removeLast()));
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() => _markups.add(_redoStack.removeLast()));
  }

  void _addMarkup(_PdfMarkup markup) {
    setState(() {
      _markups.add(markup);
      _redoStack.clear();
    });
  }

  void _eraseAt(Offset normalizedPoint) {
    final pageMarkups = _markups
        .where((markup) => markup.pageNumber == _currentPage)
        .toList()
        .reversed;

    for (final markup in pageMarkups) {
      if (markup.hitTest(normalizedPoint)) {
        setState(() {
          _markups.remove(markup);
          _redoStack.clear();
        });
        return;
      }
    }
  }

  Future<void> _addTextAt(Offset normalizedPoint) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة نص'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اكتب الملاحظة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    _addMarkup(
      _PdfMarkup.text(
        pageNumber: _currentPage,
        point: normalizedPoint,
        color: _color,
        strokeWidth: _strokeWidth,
        text: text,
      ),
    );
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    final point = _normalize(details.localPosition, size);
    if (point == null) return;

    if (_tool == ProjectAttachmentsMarkupTool.eraser) {
      _eraseAt(point);
      return;
    }

    if (_tool == ProjectAttachmentsMarkupTool.text) {
      _addTextAt(point);
      return;
    }

    setState(() {
      _draft = _PdfMarkupDraft(
        tool: _tool,
        pageNumber: _currentPage,
        color: _color,
        strokeWidth: _strokeWidth,
        points: [point],
      );
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    final draft = _draft;
    if (draft == null) return;
    final point = _normalize(details.localPosition, size);
    if (point == null) return;
    setState(() {
      if (draft.tool == ProjectAttachmentsMarkupTool.pen) {
        draft.points.add(point);
      } else {
        draft.points
          ..clear()
          ..addAll([draft.startPoint, point]);
      }
    });
  }

  void _handlePanEnd() {
    final draft = _draft;
    if (draft == null) return;
    _draft = null;
    if (draft.points.length < 2 &&
        draft.tool != ProjectAttachmentsMarkupTool.text) {
      setState(() {});
      return;
    }
    _addMarkup(draft.toMarkup());
  }

  Offset? _normalize(Offset point, Size size) {
    if (size.width <= 0 || size.height <= 0) return null;
    final dx = (point.dx / size.width).clamp(0.0, 1.0);
    final dy = (point.dy / size.height).clamp(0.0, 1.0);
    return Offset(dx, dy);
  }

  Future<void> _save() async {
    final sourceBytes = _pdfBytes;
    if (sourceBytes == null || sourceBytes.isEmpty || _markups.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final savedBytes = await compute(_flattenPdfMarkups, {
        'bytes': sourceBytes,
        'markups': _markups.map((markup) => markup.toMap()).toList(),
      });
      await widget.onSave(savedBytes);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnackBar(context, 'تم حفظ التعديلات على PDF');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(context, 'فشل حفظ تعديلات PDF');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: AppColors.cardBackground,
          appBar: AppBar(
            title: Text(
              widget.attachment.originalName,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (await _confirmDiscard() && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
            ),
            actions: [
              IconButton(
                tooltip: 'تراجع',
                onPressed: _markups.isEmpty || _isSaving ? null : _undo,
                icon: const Icon(Icons.undo_rounded),
              ),
              IconButton(
                tooltip: 'إعادة',
                onPressed: _redoStack.isEmpty || _isSaving ? null : _redo,
                icon: const Icon(Icons.redo_rounded),
              ),
              TextButton.icon(
                onPressed: _hasUnsavedChanges && !_isSaving ? _save : null,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('حفظ'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              ProjectAttachmentsMarkupToolbar(
                tool: _tool,
                color: _color,
                strokeWidth: _strokeWidth,
                zoomLevel: _zoomLevel,
                onToolChanged: (tool) => setState(() => _tool = tool),
                onColorChanged: (color) => setState(() => _color = color),
                onStrokeWidthChanged: (width) =>
                    setState(() => _strokeWidth = width),
                onZoomIn: () => _setZoom(_zoomLevel + 0.25),
                onZoomOut: () => _setZoom(_zoomLevel - 0.25),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _pdfBytes == null || _pdfBytes!.isEmpty
                    ? const Center(child: Text('تعذر تحميل ملف PDF'))
                    : Stack(
                        children: [
                          SfPdfViewer.memory(
                            Uint8List.fromList(_pdfBytes!),
                            controller: _controller,
                            pageLayoutMode: PdfPageLayoutMode.single,
                            canShowPaginationDialog: false,
                            canShowScrollHead: false,
                            canShowScrollStatus: false,
                            onDocumentLoaded: (details) {
                              setState(() {
                                _totalPages = details.document.pages.count;
                              });
                            },
                            onPageChanged: (details) {
                              setState(() {
                                _currentPage = details.newPageNumber;
                                _draft = null;
                              });
                            },
                          ),
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final size = Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: _isSaving
                                      ? null
                                      : (details) =>
                                            _handlePanStart(details, size),
                                  onPanUpdate: _isSaving
                                      ? null
                                      : (details) =>
                                            _handlePanUpdate(details, size),
                                  onPanEnd: _isSaving
                                      ? null
                                      : (_) => _handlePanEnd(),
                                  child: CustomPaint(
                                    painter: _PdfMarkupPainter(
                                      markups: _markups
                                          .where(
                                            (markup) =>
                                                markup.pageNumber ==
                                                _currentPage,
                                          )
                                          .toList(),
                                      draft: _draft,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
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
                  children: [
                    ProjectAttachmentsPdfPageIndicator(
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
                    Text(
                      _hasUnsavedChanges
                          ? 'هناك تعديلات غير محفوظة'
                          : 'لا توجد تعديلات',
                      style: AppTextStyles.caption.copyWith(
                        color: _hasUnsavedChanges
                            ? AppColors.warning
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfMarkupPainter extends CustomPainter {
  final List<_PdfMarkup> markups;
  final _PdfMarkupDraft? draft;

  _PdfMarkupPainter({required this.markups, required this.draft});

  @override
  void paint(Canvas canvas, Size size) {
    for (final markup in markups) {
      markup.paint(canvas, size);
    }
    draft?.toMarkup().paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _PdfMarkupPainter oldDelegate) {
    return oldDelegate.markups != markups || oldDelegate.draft != draft;
  }
}

class _PdfMarkupDraft {
  final ProjectAttachmentsMarkupTool tool;
  final int pageNumber;
  final Color color;
  final double strokeWidth;
  final List<Offset> points;

  _PdfMarkupDraft({
    required this.tool,
    required this.pageNumber,
    required this.color,
    required this.strokeWidth,
    required this.points,
  });

  Offset get startPoint => points.first;

  _PdfMarkup toMarkup() {
    return _PdfMarkup(
      type: tool,
      pageNumber: pageNumber,
      points: List.of(points),
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

class _PdfMarkup {
  final ProjectAttachmentsMarkupTool type;
  final int pageNumber;
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String? text;

  const _PdfMarkup({
    required this.type,
    required this.pageNumber,
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.text,
  });

  factory _PdfMarkup.text({
    required int pageNumber,
    required Offset point,
    required Color color,
    required double strokeWidth,
    required String text,
  }) {
    return _PdfMarkup(
      type: ProjectAttachmentsMarkupTool.text,
      pageNumber: pageNumber,
      points: [point],
      color: color,
      strokeWidth: strokeWidth,
      text: text,
    );
  }

  bool hitTest(Offset point) {
    if (points.isEmpty) return false;
    if (type == ProjectAttachmentsMarkupTool.text) {
      return (points.first - point).distance < 0.04;
    }
    if (type == ProjectAttachmentsMarkupTool.pen) {
      return points.any((candidate) => (candidate - point).distance < 0.025);
    }
    final rect = _rectFromPoints.inflate(0.025);
    return rect.contains(point);
  }

  Rect get _rectFromPoints {
    final first = points.first;
    final last = points.length > 1 ? points.last : first;
    return Rect.fromPoints(first, last);
  }

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Offset scale(Offset point) =>
        Offset(point.dx * size.width, point.dy * size.height);

    switch (type) {
      case ProjectAttachmentsMarkupTool.pen:
        for (var i = 1; i < points.length; i++) {
          canvas.drawLine(scale(points[i - 1]), scale(points[i]), paint);
        }
        break;
      case ProjectAttachmentsMarkupTool.arrow:
        if (points.length < 2) return;
        final start = scale(points.first);
        final end = scale(points.last);
        canvas.drawLine(start, end, paint);
        _paintArrowHead(canvas, paint, start, end);
        break;
      case ProjectAttachmentsMarkupTool.rectangle:
        if (points.length < 2) return;
        canvas.drawRect(
          Rect.fromPoints(scale(points.first), scale(points.last)),
          paint,
        );
        break;
      case ProjectAttachmentsMarkupTool.circle:
        if (points.length < 2) return;
        canvas.drawOval(
          Rect.fromPoints(scale(points.first), scale(points.last)),
          paint,
        );
        break;
      case ProjectAttachmentsMarkupTool.text:
        final painter = TextPainter(
          text: TextSpan(
            text: text ?? '',
            style: TextStyle(
              color: color,
              fontSize: math.max(12, strokeWidth * 4),
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: ui.TextDirection.rtl,
        )..layout(maxWidth: 260);
        painter.paint(canvas, scale(points.first));
        break;
      case ProjectAttachmentsMarkupTool.eraser:
        break;
    }
  }

  void _paintArrowHead(Canvas canvas, Paint paint, Offset start, Offset end) {
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const length = 16.0;
    final p1 = Offset(
      end.dx - length * math.cos(angle - math.pi / 6),
      end.dy - length * math.sin(angle - math.pi / 6),
    );
    final p2 = Offset(
      end.dx - length * math.cos(angle + math.pi / 6),
      end.dy - length * math.sin(angle + math.pi / 6),
    );
    canvas
      ..drawLine(end, p1, paint)
      ..drawLine(end, p2, paint);
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'pageNumber': pageNumber,
      'points': points.map((point) => {'x': point.dx, 'y': point.dy}).toList(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'text': text,
    };
  }
}

List<int> _flattenPdfMarkups(Map<String, dynamic> input) {
  final bytes = (input['bytes'] as List).cast<int>();
  final markupMaps = (input['markups'] as List).cast<Map<String, dynamic>>();
  final document = sfpdf.PdfDocument(inputBytes: bytes);

  for (final markup in markupMaps) {
    final pageNumber = (markup['pageNumber'] as num).toInt();
    if (pageNumber < 1 || pageNumber > document.pages.count) continue;

    final page = document.pages[pageNumber - 1];
    final size = page.getClientSize();
    final colorValue = (markup['color'] as num).toInt();
    final red = (colorValue >> 16) & 0xff;
    final green = (colorValue >> 8) & 0xff;
    final blue = colorValue & 0xff;
    final pen = sfpdf.PdfPen(
      sfpdf.PdfColor(red, green, blue),
      width: (markup['strokeWidth'] as num).toDouble(),
    );
    final points = (markup['points'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (point) => Offset(
            (point['x'] as num).toDouble() * size.width,
            (point['y'] as num).toDouble() * size.height,
          ),
        )
        .toList();
    if (points.isEmpty) continue;

    switch (markup['type'] as String) {
      case 'pen':
        for (var i = 1; i < points.length; i++) {
          page.graphics.drawLine(pen, points[i - 1], points[i]);
        }
        break;
      case 'arrow':
        if (points.length < 2) break;
        _drawPdfArrow(page.graphics, pen, points.first, points.last);
        break;
      case 'rectangle':
        if (points.length < 2) break;
        page.graphics.drawRectangle(
          pen: pen,
          bounds: _pdfRectFromPoints(points.first, points.last),
        );
        break;
      case 'circle':
        if (points.length < 2) break;
        page.graphics.drawEllipse(
          _pdfRectFromPoints(points.first, points.last),
          pen: pen,
        );
        break;
      case 'text':
        final text = markup['text'] as String?;
        if (text == null || text.isEmpty) break;
        page.graphics.drawString(
          text,
          sfpdf.PdfStandardFont(
            sfpdf.PdfFontFamily.helvetica,
            math.max(10, (markup['strokeWidth'] as num).toDouble() * 4),
            style: sfpdf.PdfFontStyle.bold,
          ),
          pen: pen,
          bounds: Rect.fromLTWH(points.first.dx, points.first.dy, 240, 80),
          format: sfpdf.PdfStringFormat(
            textDirection: sfpdf.PdfTextDirection.rightToLeft,
          ),
        );
        break;
    }
  }

  final output = document.saveSync();
  document.dispose();
  return output;
}

Rect _pdfRectFromPoints(Offset first, Offset second) {
  final left = math.min(first.dx, second.dx);
  final top = math.min(first.dy, second.dy);
  final right = math.max(first.dx, second.dx);
  final bottom = math.max(first.dy, second.dy);
  return Rect.fromLTRB(left, top, right, bottom);
}

void _drawPdfArrow(
  sfpdf.PdfGraphics graphics,
  sfpdf.PdfPen pen,
  Offset start,
  Offset end,
) {
  graphics.drawLine(pen, start, end);
  final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
  const length = 16.0;
  final p1 = Offset(
    end.dx - length * math.cos(angle - math.pi / 6),
    end.dy - length * math.sin(angle - math.pi / 6),
  );
  final p2 = Offset(
    end.dx - length * math.cos(angle + math.pi / 6),
    end.dy - length * math.sin(angle + math.pi / 6),
  );
  graphics
    ..drawLine(pen, end, p1)
    ..drawLine(pen, end, p2);
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
