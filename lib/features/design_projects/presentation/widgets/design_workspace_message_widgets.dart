import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_helper.dart';
import '../../domain/entities/design_workspace_entities.dart';

class DesignChatBubble extends StatelessWidget {
  final DesignActivity activity;
  final bool isMine;

  const DesignChatBubble({
    super.key,
    required this.activity,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine
        ? AppColors.secondary.withValues(alpha: 0.18)
        : AppColors.surfaceColor.withValues(alpha: 0.90);
    final borderRadius = isMine
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(6),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(18),
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              Text(
                activity.author,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activity.message.trim().isNotEmpty)
                    _LinkifiedMessageText(
                      message: activity.message,
                      isMine: isMine,
                    ),
                  if (activity.media != null) ...[
                    if (activity.message.trim().isNotEmpty)
                      const SizedBox(height: 8),
                    DesignAttachmentBubble(media: activity.media!),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        relativeTime(activity.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.done_all,
                          size: 16,
                          color: AppColors.secondaryLight,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkifiedMessageText extends StatefulWidget {
  final String message;
  final bool isMine;

  const _LinkifiedMessageText({required this.message, required this.isMine});

  @override
  State<_LinkifiedMessageText> createState() => _LinkifiedMessageTextState();
}

class _LinkifiedMessageTextState extends State<_LinkifiedMessageText> {
  late List<_MessageSegment> _segments;
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _rebuildSegments();
  }

  @override
  void didUpdateWidget(covariant _LinkifiedMessageText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _rebuildSegments();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final linkColor = widget.isMine
        ? AppColors.secondary
        : AppColors.primaryLight;

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          for (var index = 0; index < _segments.length; index++)
            _segments[index].isLink
                ? TextSpan(
                    text: _segments[index].text,
                    style: baseStyle?.copyWith(
                      color: linkColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: _recognizers[index],
                  )
                : TextSpan(text: _segments[index].text),
        ],
      ),
    );
  }

  void _rebuildSegments() {
    _disposeRecognizers();
    _segments = _splitMessageSegments(widget.message);
    for (final segment in _segments) {
      if (!segment.isLink) {
        _recognizers.add(TapGestureRecognizer());
        continue;
      }
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => _openLink(segment.text),
      );
    }
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _openLink(String rawLink) async {
    final uri = _messageLinkUri(rawLink);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('تعذر فتح الرابط'),
      ),
    );
  }
}

class _MessageSegment {
  final String text;
  final bool isLink;

  const _MessageSegment({required this.text, required this.isLink});
}

final RegExp _messageLinkPattern = RegExp(
  r'((?:https?:\/\/|www\.)[^\s]+)',
  caseSensitive: false,
);

List<_MessageSegment> _splitMessageSegments(String message) {
  final segments = <_MessageSegment>[];
  var currentIndex = 0;

  for (final match in _messageLinkPattern.allMatches(message)) {
    final rawMatch = match.group(0);
    if (rawMatch == null || rawMatch.isEmpty) continue;

    final trimmedMatch = _trimTrailingLinkPunctuation(rawMatch);
    if (trimmedMatch.isEmpty) continue;
    final trimmedLength = trimmedMatch.length;
    final matchStart = match.start;
    final matchEnd = matchStart + trimmedLength;

    if (matchStart > currentIndex) {
      segments.add(
        _MessageSegment(
          text: message.substring(currentIndex, matchStart),
          isLink: false,
        ),
      );
    }

    segments.add(_MessageSegment(text: trimmedMatch, isLink: true));

    if (match.end > matchEnd) {
      segments.add(
        _MessageSegment(
          text: message.substring(matchEnd, match.end),
          isLink: false,
        ),
      );
    }

    currentIndex = match.end;
  }

  if (currentIndex < message.length) {
    segments.add(
      _MessageSegment(text: message.substring(currentIndex), isLink: false),
    );
  }

  return segments.isEmpty
      ? [const _MessageSegment(text: '', isLink: false)]
      : segments;
}

String _trimTrailingLinkPunctuation(String value) {
  const trailingPunctuation = '.,!?;:)]}>"\'،؛';
  var end = value.length;
  while (end > 0 && trailingPunctuation.contains(value[end - 1])) {
    end--;
  }
  return value.substring(0, end);
}

Uri? _messageLinkUri(String rawLink) {
  final trimmed = rawLink.trim();
  if (trimmed.isEmpty) return null;

  final normalized = trimmed.toLowerCase().startsWith('www.')
      ? 'https://$trimmed'
      : trimmed;
  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasScheme) return null;
  return uri;
}

class DesignAttachmentBubble extends StatelessWidget {
  final DesignMedia media;

  const DesignAttachmentBubble({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.type == DesignMediaType.image && media.previewUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 240,
            maxHeight: 180,
            minWidth: 120,
            minHeight: 90,
          ),
          color: AppColors.inputBackground.withValues(alpha: 0.65),
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () => _openFullscreenImage(context),
                  child: Image.network(
                    media.previewUrl!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) => _fileTile(context),
                  ),
                ),
              ),
              if (media.downloadUrl != null)
                PositionedDirectional(
                  end: 8,
                  top: 8,
                  child: _MediaOverlayButton(
                    icon: Icons.download_outlined,
                    tooltip: 'تحميل',
                    onPressed: () => downloadDesignMedia(context, media),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (media.type == DesignMediaType.video && media.downloadUrl != null) {
      return DesignVideoPreview(media: media);
    }

    return _fileTile(context);
  }

  Future<void> _openFullscreenImage(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Image preview',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (dialogContext, _, __) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200,
                      maxHeight: 900,
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          media.previewUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.cardBackground,
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'تعذر فتح الصورة',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 16,
                end: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (media.downloadUrl != null) ...[
                      _FullscreenActionButton(
                        icon: Icons.download_outlined,
                        tooltip: 'تحميل',
                        onPressed: () => downloadDesignMedia(context, media),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _FullscreenActionButton(
                      icon: Icons.close,
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fileTile(BuildContext context) {
    return InkWell(
      onTap: media.downloadUrl == null
          ? null
          : () => downloadDesignMedia(context, media),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconFor(media.type),
                color: AppColors.primaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    media.size,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.download_outlined,
                color: AppColors.primaryLight,
              ),
              tooltip: 'تحميل',
              onPressed: media.downloadUrl == null
                  ? null
                  : () => downloadDesignMedia(context, media),
            ),
          ],
        ),
      ),
    );
  }
}

class DesignVideoPreview extends StatefulWidget {
  final DesignMedia media;

  const DesignVideoPreview({super.key, required this.media});

  @override
  State<DesignVideoPreview> createState() => _DesignVideoPreviewState();
}

class _DesignVideoPreviewState extends State<DesignVideoPreview> {
  late final VideoPlayerController _controller;
  var _isReady = false;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.media.downloadUrl!),
    );
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _isReady = true);
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _hasError = true);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _VideoFallbackTile(media: widget.media);
    }

    final aspectRatio = _isReady && _controller.value.aspectRatio > 0
        ? _controller.value.aspectRatio
        : 16 / 9;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isReady)
                VideoPlayer(_controller)
              else
                const CircularProgressIndicator(),
              if (_isReady)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _togglePlayback,
                      onDoubleTap: () => _openVideoDialog(context),
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              PositionedDirectional(
                end: 8,
                top: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MediaOverlayButton(
                      icon: Icons.download_outlined,
                      tooltip: 'تحميل',
                      onPressed: () =>
                          downloadDesignMedia(context, widget.media),
                    ),
                    const SizedBox(width: 6),
                    _MediaOverlayButton(
                      icon: Icons.open_in_full,
                      tooltip: 'معاينة',
                      onPressed: _isReady
                          ? () => _openVideoDialog(context)
                          : null,
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

  void _togglePlayback() {
    if (!_isReady) return;
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  Future<void> _openVideoDialog(BuildContext context) {
    _controller.pause();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Video preview',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (dialogContext, _, __) => _FullscreenVideoDialog(
        media: widget.media,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}

class _FullscreenVideoDialog extends StatefulWidget {
  final DesignMedia media;
  final VoidCallback onClose;

  const _FullscreenVideoDialog({required this.media, required this.onClose});

  @override
  State<_FullscreenVideoDialog> createState() => _FullscreenVideoDialogState();
}

class _FullscreenVideoDialogState extends State<_FullscreenVideoDialog> {
  late final VideoPlayerController _controller;
  var _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.media.downloadUrl!),
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isReady = true);
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _isReady && _controller.value.aspectRatio > 0
        ? _controller.value.aspectRatio
        : 16 / 9;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                  maxHeight: 900,
                ),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Colors.black,
                      child: _isReady
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_controller),
                                IconButton(
                                  iconSize: 54,
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    });
                                  },
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                  ),
                                ),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 16,
            end: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FullscreenActionButton(
                  icon: Icons.download_outlined,
                  tooltip: 'تحميل',
                  onPressed: () => downloadDesignMedia(context, widget.media),
                ),
                const SizedBox(width: 8),
                _FullscreenActionButton(
                  icon: Icons.close,
                  tooltip: 'إغلاق',
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoFallbackTile extends StatelessWidget {
  final DesignMedia media;

  const _VideoFallbackTile({required this.media});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => downloadDesignMedia(context, media),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                media.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.download_outlined,
                color: AppColors.primaryLight,
              ),
              tooltip: 'تحميل',
              onPressed: () => downloadDesignMedia(context, media),
            ),
          ],
        ),
      ),
    );
  }
}

class DesignWorkspaceComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final Future<void> Function()? onPaste;
  final VoidCallback onSend;

  const DesignWorkspaceComposer({
    super.key,
    required this.controller,
    required this.onAttach,
    this.onPaste,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        if (onPaste != null)
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
              onPaste!.call(),
        if (onPaste != null)
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true): () =>
              onPaste!.call(),
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ChatActionButton(
              icon: Icons.attach_file,
              tooltip: 'إرفاق ملف',
              onPressed: onAttach,
              enabledColor: AppColors.primary,
              disabledColor: AppColors.textDisabled,
              backgroundColor: AppColors.primary.withValues(alpha: 0.14),
              disabledBackgroundColor: AppColors.surfaceColor.withValues(
                alpha: 0.65,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالة...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty;
                return _ChatActionButton(
                  icon: Icons.send,
                  tooltip: 'إرسال',
                  onPressed: canSend ? onSend : null,
                  enabledColor: AppColors.white,
                  disabledColor: AppColors.textDisabled,
                  backgroundColor: AppColors.secondary,
                  disabledBackgroundColor: AppColors.surfaceColor.withValues(
                    alpha: 0.65,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color enabledColor;
  final Color disabledColor;
  final Color backgroundColor;
  final Color disabledBackgroundColor;

  const _ChatActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.enabledColor,
    required this.disabledColor,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? backgroundColor : disabledBackgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? enabledColor : disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaOverlayButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _MediaOverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.50),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 18,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _FullscreenActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _FullscreenActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
      ),
    );
  }
}

Future<void> downloadDesignMedia(
  BuildContext context,
  DesignMedia media,
) async {
  final url = media.downloadUrl;
  if (url == null || url.isEmpty) {
    _showDesignMediaSnackBar(context, 'لا يوجد رابط تحميل لهذا الملف');
    return;
  }

  if (kIsWeb) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    return;
  }

  try {
    final fileName = _safeDesignMediaFileName(media.name);
    final targetPath = await FilePicker.platform.saveFile(
      dialogTitle: 'حفظ الملف',
      fileName: fileName,
    );
    if (targetPath == null) return;

    await DioHelper.dio.download(
      url,
      targetPath,
      options: Options(responseType: ResponseType.bytes),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
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
    _showDesignMediaSnackBar(context, 'تعذر تحميل الملف');
  }
}

void _showDesignMediaSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(message),
    ),
  );
}

String _safeDesignMediaFileName(String fileName) {
  final sanitized = fileName
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return sanitized.isEmpty ? 'design-media' : sanitized;
}

IconData iconFor(DesignMediaType type) => switch (type) {
  DesignMediaType.image => Icons.image_outlined,
  DesignMediaType.pdf => Icons.picture_as_pdf_outlined,
  DesignMediaType.video => Icons.play_circle_outline,
  DesignMediaType.technical => Icons.description_outlined,
};

String relativeTime(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inHours < 1) return 'منذ ${difference.inMinutes} دقيقة';
  if (difference.inDays < 1) return 'منذ ${difference.inHours} ساعة';
  return 'منذ ${difference.inDays} يوم';
}
