import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/enums/task_type.dart';
import '../../../tasks/domain/enums/task_status.dart' show TaskStatusExtension;

/// Tooltip content for appointment hover
class AppointmentTooltip extends StatelessWidget {
  final TaskEntity task;

  const AppointmentTooltip({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.of(context).border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: TaskType.appointment.color(context),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.name,
                  style: AppTextStyles.of(context).tableCellBold.copyWith(
                    color: AppColors.of(context).textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.of(context).divider, height: 1),
          const SizedBox(height: 8),

          // Customer info
          if (task.customerName != null) ...[
            _buildInfoRow(context, Icons.person_outline, task.customerName!),
            const SizedBox(height: 6),
          ],
          if (task.customerPhone != null) ...[
            _buildInfoRow(context, Icons.phone_outlined, task.customerPhone!),
            const SizedBox(height: 6),
          ],
          if (task.formattedAppointmentTime != null) ...[
            _buildInfoRow(
              context,
              Icons.access_time,
              task.formattedAppointmentTime!,
            ),
            const SizedBox(height: 6),
          ],
          if (task.locationLink != null) ...[
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              'عرض الموقع',
              isLink: true,
            ),
          ],

          const SizedBox(height: 8),
          Text(
            'اضغط لعرض التفاصيل',
            style: AppTextStyles.of(context).caption.copyWith(
              color: AppColors.of(context).textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text, {
    bool isLink = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.of(context).textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.of(context).caption.copyWith(
              color: isLink
                  ? AppColors.of(context).primary
                  : AppColors.of(context).textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Full details dialog for appointment click
class AppointmentDetailsDialog extends StatelessWidget {
  final TaskEntity task;

  const AppointmentDetailsDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.of(context).cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TaskType.appointment
                        .color(context)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: TaskType.appointment.color(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.name, style: AppTextStyles.of(context).h5),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: task.status
                              .color(context)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.status.arabicName,
                          style: TextStyle(
                            color: task.status.color(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.of(context).textMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: AppColors.of(context).divider),
            const SizedBox(height: 16),

            // Customer Details Section
            Text(
              'بيانات العميل',
              style: AppTextStyles.of(
                context,
              ).inputLabel.copyWith(color: AppColors.of(context).textMuted),
            ),
            const SizedBox(height: 12),

            if (task.customerName != null)
              _buildDetailRow(
                context,
                icon: Icons.person,
                label: 'الاسم',
                value: task.customerName!,
              ),

            if (task.customerPhone != null)
              _buildDetailRow(
                context,
                icon: Icons.phone,
                label: 'الهاتف',
                value: task.customerPhone!,
                isPhone: true,
              ),

            const SizedBox(height: 16),

            // Appointment Details Section
            Text(
              'تفاصيل الموعد',
              style: AppTextStyles.of(
                context,
              ).inputLabel.copyWith(color: AppColors.of(context).textMuted),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'التاريخ',
              value: _formatDate(task.startDate),
            ),

            if (task.formattedAppointmentTime != null)
              _buildDetailRow(
                context,
                icon: Icons.access_time,
                label: 'الوقت',
                value: task.formattedAppointmentTime!,
              ),

            if (task.assignee != null)
              _buildDetailRow(
                context,
                icon: Icons.person_pin,
                label: 'المسؤول',
                value: task.assignee!.name,
              ),

            if (task.locationLink != null) ...[
              const SizedBox(height: 16),
              _buildLocationButton(context),
            ],

            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'ملاحظات',
                style: AppTextStyles.of(
                  context,
                ).inputLabel.copyWith(color: AppColors.of(context).textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.notes!,
                  style: AppTextStyles.of(context).bodyMedium,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (task.customerPhone != null)
                  OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(task.customerPhone!),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.of(context).statusActive,
                      side: BorderSide(
                        color: AppColors.of(context).statusActive,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primary,
                    foregroundColor: AppColors.of(context).scaffoldBackground,
                  ),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.of(context).surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.of(context).textMuted),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.of(
                  context,
                ).caption.copyWith(color: AppColors.of(context).textMuted),
              ),
              const SizedBox(height: 2),
              isPhone
                  ? InkWell(
                      onTap: () => _makePhoneCall(value),
                      child: Text(
                        value,
                        style: AppTextStyles.of(context).bodyMedium.copyWith(
                          color: AppColors.of(context).statusActive,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  : Text(value, style: AppTextStyles.of(context).bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context) {
    return InkWell(
      onTap: () => _openLocation(task.locationLink!),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.of(context).statusActive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.of(context).statusActive.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.of(
                  context,
                ).statusActive.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.of(context).statusActive,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'موقع الموعد',
                    style: AppTextStyles.of(context).inputLabel.copyWith(
                      color: AppColors.of(context).statusActive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.locationLink!.length > 40
                        ? '${task.locationLink!.substring(0, 40)}...'
                        : task.locationLink!,
                    style: AppTextStyles.of(
                      context,
                    ).caption.copyWith(color: AppColors.of(context).textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: AppColors.of(context).statusActive,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${days[date.weekday % 7]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openLocation(String location) async {
    Uri uri;

    // Check if it's already a URL
    if (location.startsWith('http://') || location.startsWith('https://')) {
      uri = Uri.parse(location);
    } else {
      // Treat as address, open in Google Maps
      final encoded = Uri.encodeComponent(location);
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Circle widget for appointment display on Gantt chart
/// Supports: tap for details, double-tap for edit, drag to reschedule
class AppointmentCircle extends StatefulWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  const AppointmentCircle({
    super.key,
    required this.task,
    required this.onTap,
    this.onDoubleTap,
  });

  @override
  State<AppointmentCircle> createState() => _AppointmentCircleState();
}

class _AppointmentCircleState extends State<AppointmentCircle> {
  bool _isHovered = false;
  OverlayEntry? _tooltipOverlay;

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  void _showTooltip(BuildContext context) {
    _removeTooltip();

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 100,
        top: offset.dy + 45,
        child: Material(
          color: Colors.transparent,
          child: AppointmentTooltip(task: widget.task),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipOverlay!);
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _showTooltip(context);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _removeTooltip();
      },
      child: GestureDetector(
        onTap: () {
          _removeTooltip();
          widget.onTap();
        },
        onDoubleTap: widget.onDoubleTap != null
            ? () {
                _removeTooltip();
                widget.onDoubleTap!();
              }
            : null,
        child: Draggable<TaskEntity>(
          data: widget.task,
          feedback: Material(
            elevation: 8,
            shape: const CircleBorder(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.task.status.color(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.task.status
                        .color(context)
                        .withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: _buildCircle()),
          child: Tooltip(message: 'انقر مرتين للتعديل', child: _buildCircle()),
        ),
      ),
    );
  }

  Widget _buildCircle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isHovered ? 38 : 32,
      height: _isHovered ? 38 : 32,
      decoration: BoxDecoration(
        color: widget.task.status.color(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.task.status
                .color(context)
                .withValues(alpha: _isHovered ? 0.5 : 0.3),
            blurRadius: _isHovered ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: _isHovered ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Center(
        child: Icon(
          Icons.calendar_today,
          color: Colors.white,
          size: _isHovered ? 18 : 14,
        ),
      ),
    );
  }
}
