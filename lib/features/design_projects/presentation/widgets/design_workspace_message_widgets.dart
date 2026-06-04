import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
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
                    Text(activity.message),
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

class DesignAttachmentBubble extends StatelessWidget {
  final DesignMedia media;

  const DesignAttachmentBubble({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.type == DesignMediaType.image && media.previewUrl != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openFullscreenImage(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 240,
              maxHeight: 180,
              minWidth: 120,
              minHeight: 90,
            ),
            color: AppColors.inputBackground.withValues(alpha: 0.65),
            child: Image.network(
              media.previewUrl!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => _fileTile(context),
            ),
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
                child: Material(
                  color: AppColors.cardBackground.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'إغلاق',
                  ),
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
          : () => launchUrl(Uri.parse(media.downloadUrl!)),
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
            const Icon(Icons.download_outlined, color: AppColors.primaryLight),
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
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.open_in_full, color: Colors.white),
                    iconSize: 18,
                    tooltip: 'معاينة',
                    onPressed: _isReady
                        ? () => _openVideoDialog(context)
                        : null,
                  ),
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
            child: Material(
              color: AppColors.cardBackground.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                tooltip: 'إغلاق',
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, color: AppColors.primaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              media.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
