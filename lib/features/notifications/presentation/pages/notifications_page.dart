import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Mock notifications data matching the image
  static final List<NotificationEntity> _mockNotifications = [
    NotificationEntity(
      id: 'notif-1',
      type: NotificationType.projectUpdate,
      icon: Icons.folder,
      iconColor: const Color(0xFF3B82F6), // Blue
      message:
          'تم تغيير حالة مشروع "مكتب شركة التقنية" من معلق إلى قيد التنفيذ.',
      timestamp: 'منذ 30 دقيقة',
      isUnread: true,
      actionButtons: [
        NotificationActionButton(
          label: 'المشاريع',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض التفاصيل', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-2',
      type: NotificationType.newTask,
      icon: Icons.person,
      iconColor: const Color(0xFFF59E0B), // Brown/Orange
      message: 'قام أحمد محمد بتعيينك لمهمة "مراجعة مخططات الطابق الأول".',
      timestamp: 'منذ ساعتين',
      isUnread: true,
      actionButtons: [
        NotificationActionButton(
          label: 'المهام',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'قبول', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-3',
      type: NotificationType.financialUpdate,
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF22C55E), // Green
      message:
          'تم استلام دفعة مقدمة لمشروع "فندق الملك عبد العزيز" بقيمة 50,000 ريال.',
      timestamp: 'منذ ساعتين',
      isUnread: true,
      actionButtons: [
        NotificationActionButton(
          label: 'المالية',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض الفاتورة', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-4',
      type: NotificationType.projectUpdate,
      icon: Icons.folder,
      iconColor: const Color(0xFF3B82F6),
      message: 'تم تغيير حالة مشروع "برج التجارة" من قيد التنفيذ إلى مكتمل.',
      timestamp: 'منذ 3 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المشاريع',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض التفاصيل', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-5',
      type: NotificationType.newTask,
      icon: Icons.person,
      iconColor: const Color(0xFFF59E0B),
      message: 'قام محمد علي بتعيينك لمهمة "فحص المواد المستلمة".',
      timestamp: 'منذ 4 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المهام',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'قبول', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-6',
      type: NotificationType.financialUpdate,
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF22C55E),
      message: 'تم استلام دفعة لمشروع "شقة جدة" بقيمة 25,000 ريال.',
      timestamp: 'منذ 5 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المالية',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض الفاتورة', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-7',
      type: NotificationType.projectUpdate,
      icon: Icons.folder,
      iconColor: const Color(0xFF3B82F6),
      message: 'تم إضافة مشروع جديد "مجمع سكني الرياض" إلى النظام.',
      timestamp: 'منذ 6 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المشاريع',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض التفاصيل', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-8',
      type: NotificationType.newTask,
      icon: Icons.person,
      iconColor: const Color(0xFFF59E0B),
      message: 'تم تعيينك كمدير مشروع لمشروع "مستشفى الخليج".',
      timestamp: 'منذ 7 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المهام',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'قبول', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-9',
      type: NotificationType.financialUpdate,
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF22C55E),
      message: 'تم دفع فاتورة لمشروع "مركز تسوق النخيل" بقيمة 75,000 ريال.',
      timestamp: 'منذ 8 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المالية',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض الفاتورة', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-10',
      type: NotificationType.projectUpdate,
      icon: Icons.folder,
      iconColor: const Color(0xFF3B82F6),
      message: 'تم تحديث المخططات لمشروع "مدرسة الأمل" بنجاح.',
      timestamp: 'منذ 9 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المشاريع',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض التفاصيل', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-11',
      type: NotificationType.newTask,
      icon: Icons.person,
      iconColor: const Color(0xFFF59E0B),
      message: 'تم تعيينك لمهمة "إعداد تقرير شهري" للمشروع الحالي.',
      timestamp: 'منذ 10 ساعات',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المهام',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'قبول', onPressed: () {}),
      ],
    ),
    NotificationEntity(
      id: 'notif-12',
      type: NotificationType.financialUpdate,
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF22C55E),
      message:
          'تم استلام دفعة نهائية لمشروع "مبنى المكاتب الإداري" بقيمة 100,000 ريال.',
      timestamp: 'منذ 11 ساعة',
      isUnread: false,
      actionButtons: [
        NotificationActionButton(
          label: 'المالية',
          isPrimary: true,
          onPressed: () {},
        ),
        NotificationActionButton(label: 'عرض الفاتورة', onPressed: () {}),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._mockNotifications.map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NotificationCard(notification: notification),
            ),
          ),
        ],
      ),
    );
  }
}
