import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../widgets/project_contact_actions.dart';

class ProjectListItemCardBaseGradient extends StatelessWidget {
  const ProjectListItemCardBaseGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.surfaceColor,
            AppColors.cardBackground,
            AppColors.scaffoldBackground,
          ],
          stops: [0, 0.52, 1],
        ),
      ),
    );
  }
}

class ProjectListItemGlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const ProjectListItemGlowOrb({
    super.key,
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.26),
              color.withOpacity(0),
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
      ),
    );
  }
}

class ProjectListItemStatusIconBox extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final bool hovered;
  final bool compact;

  const ProjectListItemStatusIconBox({
    super.key,
    required this.accent,
    required this.icon,
    required this.hovered,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: compact ? 31 : 38,
      height: compact ? 31 : 38,
      decoration: BoxDecoration(
        color: accent.withOpacity(hovered ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(compact ? 10 : 13),
        border: Border.all(color: accent.withOpacity(hovered ? 0.34 : 0.20)),
      ),
      child: Icon(icon, size: compact ? 15 : 18, color: accent),
    );
  }
}

class ProjectListItemPipelineLabel extends StatelessWidget {
  final Color accent;
  final String groupLabel;
  final bool compact;

  const ProjectListItemPipelineLabel({
    super.key,
    required this.accent,
    required this.groupLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.80)),
      ),
      child: Text(
        groupLabel,
        style: AppTextStyles.overline.copyWith(
          color: accent,
          fontSize: compact ? 8.4 : 9.2,
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ProjectListItemCardMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onMoveToExecution;
  final bool compact;

  const ProjectListItemCardMenu({
    super.key,
    required this.onEdit,
    this.onArchive,
    this.onRestore,
    this.onMoveToExecution,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 32 : 40,
      height: compact ? 32 : 40,
      child: PopupMenuButton<String>(
        tooltip: 'خيارات المشروع',
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_horiz_rounded,
          size: compact ? 17 : 19,
          color: AppColors.textMuted,
        ),
        color: AppColors.cardBackground,
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('تعديل')),
          if (onMoveToExecution != null)
            const PopupMenuItem(value: 'execution', child: Text('بدء التنفيذ')),
          if (onRestore != null)
            const PopupMenuItem(value: 'restore', child: Text('استعادة')),
          if (onArchive != null)
            const PopupMenuItem(value: 'archive', child: Text('أرشفة')),
        ],
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
              break;
            case 'archive':
              onArchive?.call();
              break;
            case 'restore':
              onRestore?.call();
              break;
            case 'execution':
              onMoveToExecution?.call();
              break;
          }
        },
      ),
    );
  }
}

class ProjectListItemContactRow extends StatelessWidget {
  final String clientName;
  final List<ProjectPhoneContact> contacts;
  final String? fallbackPhone;
  final String? mapUrl;
  final void Function(String, String) onCopy;

  const ProjectListItemContactRow({
    super.key,
    required this.clientName,
    this.contacts = const [],
    this.fallbackPhone,
    this.mapUrl,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final phones = contacts.isNotEmpty
        ? contacts
        : [
            if ((fallbackPhone ?? '').trim().isNotEmpty)
              ProjectPhoneContact(name: clientName, phone: fallbackPhone!),
          ];

    return Row(
      children: [
        const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            clientName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ProjectContactActions(
          contacts: phones,
          fallbackPhone: fallbackPhone,
          fallbackName: clientName,
          googleMapLink: mapUrl,
          onCopy: (phone, message) => onCopy(phone, message),
        ),
      ],
    );
  }
}

class ProjectListItemProgressSection extends StatelessWidget {
  final double? dateProgress;
  final double? receivedProgress;
  final int? dateInDays;
  final double? restInCash;
  final Color accentColor;
  final bool compact;

  const ProjectListItemProgressSection({
    super.key,
    required this.dateProgress,
    required this.receivedProgress,
    required this.dateInDays,
    required this.restInCash,
    required this.accentColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dateProgress == null && receivedProgress == null) {
      return const SizedBox.shrink();
    }

    final safeDateProgress = dateProgress?.clamp(0.0, 1.0).toDouble();
    final safeReceivedProgress = receivedProgress?.clamp(0.0, 1.0).toDouble();
    final compactStats = [
      if (safeDateProgress != null && dateInDays != null) '$dateInDays يوم',
      if (safeReceivedProgress != null && restInCash != null)
        'باقي ${restInCash!.toStringAsFixed(0)}\$',
    ];

    return Column(
      children: [
        if (!compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (safeDateProgress != null)
                    const _ProgressLegend(
                      label: 'الأيام',
                      color: AppColors.secondary,
                    ),
                  if (safeDateProgress != null && safeReceivedProgress != null)
                    const SizedBox(width: 10),
                  if (safeReceivedProgress != null)
                    const _ProgressLegend(
                      label: 'المتبقى',
                      color: Color(0xFF22C55E),
                    ),
                ],
              ),
              Text(
                [
                  if (safeDateProgress != null) '$dateInDays يوم',
                  if (safeReceivedProgress != null)
                    'باقي ${restInCash!.toStringAsFixed(2)}\$',
                ].join('  |  '),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        if (compact && compactStats.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  compactStats.join('  |  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        if (compact && compactStats.isNotEmpty) const SizedBox(height: 3),
        if (!compact) const SizedBox(height: 6),
        _DualProgressTrack(
          dateProgress: safeDateProgress,
          receivedProgress: safeReceivedProgress,
          compact: compact,
        ),
      ],
    );
  }
}

class _ProgressLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _ProgressLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DualProgressTrack extends StatelessWidget {
  final double? dateProgress;
  final double? receivedProgress;
  final bool compact;

  const _DualProgressTrack({
    required this.dateProgress,
    required this.receivedProgress,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final segments =
        [
            if (dateProgress != null)
              _ProgressSegment(
                progress: dateProgress!,
                color: AppColors.secondary,
              ),
            if (receivedProgress != null)
              const _ProgressSegment(
                progress: null,
                color: Color(0xFF22C55E),
                usesReceivedProgress: true,
              ),
          ].map((segment) {
            if (segment.usesReceivedProgress) {
              return _ProgressSegment(
                progress: receivedProgress!,
                color: segment.color,
              );
            }
            return segment;
          }).toList()
          ..sort((a, b) => b.progress.compareTo(a.progress));

    return Container(
      height: compact ? 5 : 8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          for (var index = 0; index < segments.length; index++)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: segments[index].progress,
                heightFactor: 1,
                alignment: AlignmentDirectional.centerStart,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: index == 0 && segments.length > 1
                        ? segments[index].color.withOpacity(0.38)
                        : segments[index].color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressSegment {
  final double progress;
  final Color color;
  final bool usesReceivedProgress;

  const _ProgressSegment({
    required double? progress,
    required this.color,
    this.usesReceivedProgress = false,
  }) : progress = progress ?? 0;
}
