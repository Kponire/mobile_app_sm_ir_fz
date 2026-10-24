import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/schedule/schedule_bloc.dart';
import '../../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Demo notifications
  final _notifications = [
    NotificationModel(
      id: '1',
      title: 'Low Water Level Detected',
      body: 'Tank level is at 18%. Please refill soon.',
      category: 'critical',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Irrigation Completed Successfully',
      body: 'Zone A irrigation ran for 15 mins. 45L used.',
      category: 'success',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'Pump Failure: No Water Flow',
      body: 'Pump activated but no flow detected. Check valve.',
      category: 'critical',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Rain Detected, Irrigation Disabled',
      body: 'Rainfall detected. Scheduled irrigation skipped.',
      category: 'warning',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Fertigation Completed Successfully',
      body: 'NPK nutrient delivery completed for Zone B.',
      category: 'success',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '6',
      title: 'Soil Moisture Extremely Low',
      body: 'Zone C moisture: 12%. Immediate irrigation recommended.',
      category: 'critical',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
    ),
    NotificationModel(
      id: '7',
      title: 'Device Offline',
      body: 'ESP8266 controller lost connection. Check WiFi.',
      category: 'warning',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: '8',
      title: 'Fertilizer Tank A Empty',
      body: 'Fertilizer tank A is empty. Refill to continue fertigation.',
      category: 'warning',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppMainBar(
        title: 'Alerts & Notifications',
        showBack: true,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => setState(() {
                for (var n in _notifications) {
                  // Mark all as read in real app via bloc
                }
              }),
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Unread count banner
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              /* padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ), */
              /* decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ), */
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$unread unread notification${unread > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _NotificationCard(
                notification: _notifications[i],
                onTap: () => setState(() {
                  _notifications[i] = _notifications[i].copyWith(isRead: true);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  Color get _categoryColor {
    switch (notification.category) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.accentBlue;
    }
  }

  IconData get _categoryIcon {
    switch (notification.category) {
      case 'critical':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String get _categoryLabel {
    switch (notification.category) {
      case 'critical':
        return 'Critical';
      case 'warning':
        return 'Warning';
      case 'success':
        return 'Success';
      default:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        /* decoration: BoxDecoration(
          color: notification.isRead ? AppColors.cardBg : AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderColor
                : color.withOpacity(0.35),
            width: notification.isRead ? 1 : 1.5,
          ),
        ), */
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                //padding: const EdgeInsets.all(8),
                /* decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ), */
                child: Icon(_categoryIcon, color: color, size: 18),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        //StatusBadge(label: _categoryLabel, color: AppColors.textMuted),
                        Text(
                          notification.title,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: notification.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(notification.createdAt),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    /* const SizedBox(height: 6),
                    Text(
                      notification.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: notification.isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ), */
                    /* const SizedBox(height: 2),
                    Text(notification.body, style: AppTextStyles.bodyMedium), */
                  ],
                ),
              ),

              // Unread dot
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }
}
