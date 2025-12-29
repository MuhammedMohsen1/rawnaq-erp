import 'package:flutter/material.dart';

enum NotificationType {
  projectUpdate,
  newTask,
  financialUpdate,
}

class NotificationActionButton {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const NotificationActionButton({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });
}

class NotificationEntity {
  final String id;
  final NotificationType type;
  final IconData icon;
  final Color iconColor;
  final String message; // Arabic message
  final String timestamp; // e.g., "منذ 30 دقيقة"
  final bool isUnread;
  final List<NotificationActionButton> actionButtons;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.timestamp,
    this.isUnread = false,
    required this.actionButtons,
  });
}

