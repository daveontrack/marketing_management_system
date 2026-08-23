import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum UserStatus { active, inactive, pending }

enum UserRoleType {
  administrator,
  marketingManager,
  marketingStaff,
  analyst,
  viewer,
}

enum PermissionType { view, create, edit, delete }

// ─────────────────────────────────────────────────────────────────────────────
// AppUser
// ─────────────────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  String fullName;
  String email;
  String role;
  String department;
  UserStatus status;
  String lastActive;
  String accountCreated;
  List<String> recentActivity;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    required this.lastActive,
    required this.accountCreated,
    this.recentActivity = const [],
  });

  AppUser copyWith({
    String? fullName,
    String? email,
    String? role,
    String? department,
    UserStatus? status,
    String? lastActive,
    String? accountCreated,
    List<String>? recentActivity,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      accountCreated: accountCreated ?? this.accountCreated,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role definition
// ─────────────────────────────────────────────────────────────────────────────

class AppRole {
  final String name;
  final String description;
  final String permissionSummary;
  final int userCount;
  final Color color;

  const AppRole({
    required this.name,
    required this.description,
    required this.permissionSummary,
    required this.userCount,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission matrix entry
// ─────────────────────────────────────────────────────────────────────────────

class ModulePermission {
  final String module;
  bool view;
  bool create;
  bool edit;
  bool delete;

  ModulePermission({
    required this.module,
    this.view = false,
    this.create = false,
    this.edit = false,
    this.delete = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity entry
// ─────────────────────────────────────────────────────────────────────────────

class ActivityEntry {
  final String id;
  final String description;
  final String timestamp;
  final IconData icon;
  final Color iconColor;

  const ActivityEntry({
    required this.id,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data repository
// ─────────────────────────────────────────────────────────────────────────────

class UserRoleRepository {
  // --- users ---
  static final List<AppUser> _users = [
    AppUser(
      id: 'u1',
      fullName: 'Hana Tsegaye',
      email: 'hana.tsegaye@marketflow.et',
      role: 'Marketing Manager',
      department: 'Marketing',
      status: UserStatus.active,
      lastActive: '2 minutes ago',
      accountCreated: 'Jan 12, 2024',
      recentActivity: ['Updated campaign settings', 'Reviewed Q2 report', 'Added 3 new leads'],
    ),
    AppUser(
      id: 'u2',
      fullName: 'Biruk Alemu',
      email: 'biruk.alemu@marketflow.et',
      role: 'Administrator',
      department: 'IT',
      status: UserStatus.active,
      lastActive: '1 hour ago',
      accountCreated: 'Nov 3, 2023',
      recentActivity: ['Granted access to Promotions module', 'Changed system settings'],
    ),
    AppUser(
      id: 'u3',
      fullName: 'Tigist Bekele',
      email: 'tigist.bekele@marketflow.et',
      role: 'Analyst',
      department: 'Analytics',
      status: UserStatus.active,
      lastActive: '3 hours ago',
      accountCreated: 'Feb 20, 2024',
      recentActivity: ['Generated revenue report', 'Exported data to CSV'],
    ),
    AppUser(
      id: 'u4',
      fullName: 'Dawit Haile',
      email: 'dawit.haile@marketflow.et',
      role: 'Marketing Staff',
      department: 'Marketing',
      status: UserStatus.inactive,
      lastActive: '5 days ago',
      accountCreated: 'Mar 5, 2024',
      recentActivity: ['Created content draft', 'Assigned to campaign'],
    ),
    AppUser(
      id: 'u5',
      fullName: 'Selamawit Girma',
      email: 'selamawit.girma@marketflow.et',
      role: 'Viewer',
      department: 'Sales',
      status: UserStatus.active,
      lastActive: 'Yesterday',
      accountCreated: 'Apr 10, 2024',
      recentActivity: ['Viewed Q1 summary', 'Accessed leads list'],
    ),
    AppUser(
      id: 'u6',
      fullName: 'Yohannes Tadesse',
      email: 'yohannes.tadesse@marketflow.et',
      role: 'Marketing Manager',
      department: 'Growth',
      status: UserStatus.pending,
      lastActive: 'Never',
      accountCreated: 'Aug 1, 2026',
      recentActivity: [],
    ),
    AppUser(
      id: 'u7',
      fullName: 'Marta Desta',
      email: 'marta.desta@marketflow.et',
      role: 'Analyst',
      department: 'Analytics',
      status: UserStatus.pending,
      lastActive: 'Never',
      accountCreated: 'Aug 14, 2026',
      recentActivity: [],
    ),
    AppUser(
      id: 'u8',
      fullName: 'Robel Tesfaye',
      email: 'robel.tesfaye@marketflow.et',
      role: 'Marketing Staff',
      department: 'Creative',
      status: UserStatus.active,
      lastActive: '30 minutes ago',
      accountCreated: 'May 8, 2024',
      recentActivity: ['Uploaded banner assets', 'Updated promotion copy'],
    ),
  ];

  static List<AppUser> getAll() => List<AppUser>.from(_users);

  static void addUser(AppUser user) => _users.add(user);

  static void updateUser(AppUser updated) {
    final idx = _users.indexWhere((u) => u.id == updated.id);
    if (idx != -1) _users[idx] = updated;
  }

  static void removeUser(String id) => _users.removeWhere((u) => u.id == id);

  // --- roles ---
  static const List<AppRole> roles = [
    AppRole(
      name: 'Administrator',
      description: 'Full system access. Can manage all users, roles, settings, and data.',
      permissionSummary: 'All modules — Full access',
      userCount: 1,
      color: Color(0xFF6C4CE8),
    ),
    AppRole(
      name: 'Marketing Manager',
      description: 'Manages campaigns, leads, and team activities. Can create and edit most content.',
      permissionSummary: 'Campaigns, Leads, Reports — Create/Edit/View',
      userCount: 2,
      color: Color(0xFF0EA5E9),
    ),
    AppRole(
      name: 'Marketing Staff',
      description: 'Executes tasks assigned by managers. Limited create and edit rights.',
      permissionSummary: 'Campaigns, Content — View/Create',
      userCount: 2,
      color: Color(0xFF22A06B),
    ),
    AppRole(
      name: 'Analyst',
      description: 'Read-only access to reports, leads, and campaign data for analysis.',
      permissionSummary: 'Reports, Dashboard, Leads — View only',
      userCount: 2,
      color: Color(0xFFF59E0B),
    ),
    AppRole(
      name: 'Viewer',
      description: 'Can browse summaries and dashboards. No create or edit permissions.',
      permissionSummary: 'Dashboard, Reports — View only',
      userCount: 1,
      color: Color(0xFF777784),
    ),
  ];

  // --- permission matrix for Administrator (demo) ---
  static List<ModulePermission> getAdminPermissions() => [
    ModulePermission(module: 'Dashboard', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Campaigns', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Customers', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Leads', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Opportunities', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Influencers', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Content', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Promotions', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Budget', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Communications', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Automation', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Reports', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Notifications', view: true, create: true, edit: false, delete: true),
    ModulePermission(module: 'Users & Roles', view: true, create: true, edit: true, delete: true),
    ModulePermission(module: 'Profile', view: true, create: false, edit: true, delete: false),
    ModulePermission(module: 'Settings', view: true, create: false, edit: true, delete: false),
  ];

  static List<ModulePermission> getManagerPermissions() => [
    ModulePermission(module: 'Dashboard', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Campaigns', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Customers', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Leads', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Opportunities', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Influencers', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Content', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Promotions', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Budget', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Communications', view: true, create: true, edit: true, delete: false),
    ModulePermission(module: 'Automation', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Reports', view: true, create: true, edit: false, delete: false),
    ModulePermission(module: 'Notifications', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Users & Roles', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Profile', view: true, create: false, edit: true, delete: false),
    ModulePermission(module: 'Settings', view: false, create: false, edit: false, delete: false),
  ];

  static List<ModulePermission> getViewerPermissions() => [
    ModulePermission(module: 'Dashboard', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Campaigns', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Customers', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Leads', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Opportunities', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Influencers', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Content', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Promotions', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Budget', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Communications', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Automation', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Reports', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Notifications', view: true, create: false, edit: false, delete: false),
    ModulePermission(module: 'Users & Roles', view: false, create: false, edit: false, delete: false),
    ModulePermission(module: 'Profile', view: true, create: false, edit: true, delete: false),
    ModulePermission(module: 'Settings', view: false, create: false, edit: false, delete: false),
  ];

  // --- recent activity ---
  static const List<ActivityEntry> recentActivity = [
    ActivityEntry(
      id: 'a1',
      description: 'Yohannes Tadesse was invited to the system.',
      timestamp: 'Aug 14, 2026 · 4:22 PM',
      icon: Icons.person_add_rounded,
      iconColor: Color(0xFF6C4CE8),
    ),
    ActivityEntry(
      id: 'a2',
      description: 'Role of Marta Desta updated to Analyst.',
      timestamp: 'Aug 14, 2026 · 2:05 PM',
      icon: Icons.manage_accounts_rounded,
      iconColor: Color(0xFF0EA5E9),
    ),
    ActivityEntry(
      id: 'a3',
      description: 'Administrator permissions for Campaigns module updated.',
      timestamp: 'Aug 13, 2026 · 11:30 AM',
      icon: Icons.security_rounded,
      iconColor: Color(0xFFF59E0B),
    ),
    ActivityEntry(
      id: 'a4',
      description: 'Dawit Haile account deactivated.',
      timestamp: 'Aug 12, 2026 · 9:15 AM',
      icon: Icons.person_off_rounded,
      iconColor: Color(0xFFE5484D),
    ),
    ActivityEntry(
      id: 'a5',
      description: 'Selamawit Girma account activated.',
      timestamp: 'Aug 11, 2026 · 3:47 PM',
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF22A06B),
    ),
    ActivityEntry(
      id: 'a6',
      description: 'New role "Marketing Staff" created.',
      timestamp: 'Aug 10, 2026 · 10:00 AM',
      icon: Icons.add_circle_rounded,
      iconColor: Color(0xFF22A06B),
    ),
    ActivityEntry(
      id: 'a7',
      description: 'Biruk Alemu role changed to Administrator.',
      timestamp: 'Aug 9, 2026 · 8:30 AM',
      icon: Icons.swap_horiz_rounded,
      iconColor: Color(0xFF6C4CE8),
    ),
  ];
}
