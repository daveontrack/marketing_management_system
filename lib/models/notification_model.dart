import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification category enum
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationCategory {
  campaign,
  lead,
  customer,
  budget,
  automation,
  report,
  system,
  promotion,
}

extension NotificationCategoryX on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.campaign:
        return 'Campaigns';
      case NotificationCategory.lead:
        return 'Leads';
      case NotificationCategory.customer:
        return 'Customers';
      case NotificationCategory.budget:
        return 'Budget';
      case NotificationCategory.automation:
        return 'Automation';
      case NotificationCategory.report:
        return 'Reports';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.promotion:
        return 'Promotions';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.campaign:
        return Icons.campaign_outlined;
      case NotificationCategory.lead:
        return Icons.person_search_outlined;
      case NotificationCategory.customer:
        return Icons.people_outline;
      case NotificationCategory.budget:
        return Icons.account_balance_wallet_outlined;
      case NotificationCategory.automation:
        return Icons.settings_suggest_outlined;
      case NotificationCategory.report:
        return Icons.bar_chart_outlined;
      case NotificationCategory.system:
        return Icons.info_outline;
      case NotificationCategory.promotion:
        return Icons.local_offer_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.campaign:
        return const Color(0xFF6C4CE8); // primary
      case NotificationCategory.lead:
        return const Color(0xFF0EA5E9); // info
      case NotificationCategory.customer:
        return const Color(0xFF22A06B); // success
      case NotificationCategory.budget:
        return const Color(0xFFF59E0B); // warning
      case NotificationCategory.automation:
        return const Color(0xFFE5484D); // danger
      case NotificationCategory.report:
        return const Color(0xFF22A06B); // success
      case NotificationCategory.system:
        return const Color(0xFF777784); // secondary
      case NotificationCategory.promotion:
        return const Color(0xFFBB5CF8); // chartPalette[5]
    }
  }

  /// The app route to navigate to for this category, if one exists.
  /// Returns null if no matching route is implemented.
  String? get route {
    switch (this) {
      case NotificationCategory.campaign:
        return '/campaigns';
      case NotificationCategory.lead:
        return '/leads';
      case NotificationCategory.customer:
        return '/customers';
      case NotificationCategory.budget:
        return '/budget';
      case NotificationCategory.automation:
        return '/automation';
      case NotificationCategory.report:
        return '/reports';
      case NotificationCategory.promotion:
        return '/promotions';
      case NotificationCategory.system:
        return null; // no dedicated system route
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationModel
// ─────────────────────────────────────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime createdAt;
  bool isRead;

  // Legacy field kept for backward compatibility
  String get date => createdAt.toIso8601String();

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationRepository — in-memory, mutable mock store
// ─────────────────────────────────────────────────────────────────────────────

class NotificationRepository {
  NotificationRepository._();

  static final List<NotificationModel> _items = [
    NotificationModel(
      id: 'n01',
      title: 'Campaign Completed',
      message:
          'Your "Q3 Brand Awareness" campaign has finished running. Final reach: 42,800 impressions.',
      category: NotificationCategory.campaign,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n02',
      title: 'New Lead Assigned',
      message:
          'Tigist Bekele from Addis Tech Solutions has been assigned to you as a qualified lead.',
      category: NotificationCategory.lead,
      createdAt: DateTime.now().subtract(const Duration(minutes: 38)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n03',
      title: 'Budget Threshold Reached',
      message:
          'The "Digital Channels" budget has hit 85% of its monthly limit (ETB 127,500 of 150,000).',
      category: NotificationCategory.budget,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n04',
      title: 'Automation Workflow Failed',
      message:
          '"Welcome Email Sequence" failed at step 3: SMTP connection timed out. 14 contacts were not reached.',
      category: NotificationCategory.automation,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n05',
      title: 'New Customer Added',
      message:
          'Selam Trading PLC has been added as a new customer. Account managed by Hana Tsegaye.',
      category: NotificationCategory.customer,
      createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 44)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n06',
      title: 'Monthly Report Generated',
      message:
          'Your July 2026 marketing performance report is ready. Download or view it in Reports.',
      category: NotificationCategory.report,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n07',
      title: 'Promotion Created',
      message:
          '"Mid-Year Flash Sale" promotion has been created and scheduled to go live on August 20.',
      category: NotificationCategory.promotion,
      createdAt: DateTime.now().subtract(const Duration(hours: 7, minutes: 20)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n08',
      title: 'User Invitation Accepted',
      message:
          'Bereket Haile accepted your invitation and joined as a Marketing Clerk.',
      category: NotificationCategory.system,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n09',
      title: 'Campaign Paused',
      message:
          '"Summer Influencer Push" was paused automatically after exceeding daily spend cap.',
      category: NotificationCategory.campaign,
      createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n10',
      title: 'Lead Status Updated',
      message:
          'Dawit Mekonnen has progressed from "Contacted" to "Qualified" in the sales pipeline.',
      category: NotificationCategory.lead,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n11',
      title: 'System Maintenance Scheduled',
      message:
          'Planned maintenance window on August 17 from 02:00–04:00 EAT. Expect brief downtime.',
      category: NotificationCategory.system,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n12',
      title: 'Budget Approved',
      message:
          'Q4 marketing budget of ETB 600,000 has been approved and is now available for allocation.',
      category: NotificationCategory.budget,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  /// Returns a mutable copy of all notifications, newest first.
  static List<NotificationModel> getAll() =>
      List<NotificationModel>.from(_items);

  static int get unreadCount => _items.where((n) => !n.isRead).length;

  static void markAsRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) _items[idx].isRead = true;
  }

  static void markAsUnread(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) _items[idx].isRead = false;
  }

  static void markAllAsRead() {
    for (final n in _items) {
      n.isRead = true;
    }
  }

  static void delete(String id) {
    _items.removeWhere((n) => n.id == id);
  }
}
