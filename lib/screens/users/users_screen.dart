// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/user_role_models.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UsersScreen — Users & Roles
// selfScrolling: true in routes.dart — owns its own CustomScrollView.
// Scroll architecture:
//   CustomScrollView
//     ├─ SliverPersistentHeader (pinned) → sticky _UsersPageHeaderBar
//     └─ SliverToBoxAdapter             → KPI row, tabs, tab content
// ─────────────────────────────────────────────────────────────────────────────

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final TextEditingController _searchCtrl = TextEditingController();
  String _roleFilter   = 'All';
  String _deptFilter   = 'All';
  String _statusFilter = 'All';
  String _sortBy       = 'Name';
  List<AppUser> _users = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() { if (!_tab.indexIsChanging) setState(() {}); });
    _users = UserRoleRepository.getAll();
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── computed ──────────────────────────────────────────────────────────────
  List<AppUser> get _filtered {
    var list = List<AppUser>.from(_users);
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) =>
          u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.department.toLowerCase().contains(q)).toList();
    }
    if (_roleFilter != 'All')   list = list.where((u) => u.role == _roleFilter).toList();
    if (_deptFilter != 'All')   list = list.where((u) => u.department == _deptFilter).toList();
    if (_statusFilter != 'All') {
      final s = _statusStringToEnum(_statusFilter);
      list = list.where((u) => u.status == s).toList();
    }
    switch (_sortBy) {
      case 'Name':       list.sort((a, b) => a.fullName.compareTo(b.fullName));     break;
      case 'Role':       list.sort((a, b) => a.role.compareTo(b.role));             break;
      case 'Department': list.sort((a, b) => a.department.compareTo(b.department)); break;
      case 'Status':     list.sort((a, b) => a.status.index.compareTo(b.status.index)); break;
    }
    return list;
  }

  UserStatus _statusStringToEnum(String s) {
    switch (s) {
      case 'Active':   return UserStatus.active;
      case 'Inactive': return UserStatus.inactive;
      default:         return UserStatus.pending;
    }
  }

  int get _totalUsers  => _users.length;
  int get _activeUsers => _users.where((u) => u.status == UserStatus.active).length;
  int get _admins      => _users.where((u) => u.role == 'Administrator').length;
  int get _pending     => _users.where((u) => u.status == UserStatus.pending).length;

  List<String> get _allDepts {
    final d = _users.map((u) => u.department).toSet().toList()..sort();
    return ['All', ...d];
  }

  // ── snackbar ──────────────────────────────────────────────────────────────
  void _snack(String msg,
      {IconData icon = Icons.check_circle_rounded,
      Color color = AppColors.success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── invite dialog ─────────────────────────────────────────────────────────
  void _showInviteDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl  = TextEditingController();
    String role   = 'Marketing Staff';
    String status = 'Pending';
    final formKey = GlobalKey<FormState>();
    final roles    = ['Administrator', 'Marketing Manager', 'Marketing Staff', 'Analyst', 'Viewer'];
    final statuses = ['Active', 'Pending'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final br = Theme.of(ctx).brightness;
          return Dialog(
            backgroundColor: AppTheme.surfaceColor(br),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dialogHeader(ctx, Icons.person_add_rounded, 'Invite User', AppColors.primary),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: nameCtrl, label: 'Full Name *',
                          hint: 'e.g. Abebe Kebede',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: emailCtrl, label: 'Email Address *',
                          hint: 'user@marketflow.et',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(ctx, 'Role *', role, roles,
                            (v) => setLocal(() => role = v!)),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: deptCtrl, label: 'Department',
                          hint: 'e.g. Marketing',
                          prefixIcon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(ctx, 'Status', status, statuses,
                            (v) => setLocal(() => status = v!)),
                        const SizedBox(height: 24),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          CustomButton(
                            text: 'Send Invitation',
                            fullWidth: false,
                            size: ButtonSize.small,
                            prefixIcon: Icons.send_rounded,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final newUser = AppUser(
                                id: 'u${DateTime.now().millisecondsSinceEpoch}',
                                fullName: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                role: role,
                                department: deptCtrl.text.trim().isEmpty
                                    ? 'General' : deptCtrl.text.trim(),
                                status: status == 'Active'
                                    ? UserStatus.active : UserStatus.pending,
                                lastActive: 'Never',
                                accountCreated: 'Aug 15, 2026',
                              );
                              setState(() {
                                _users.add(newUser);
                                UserRoleRepository.addUser(newUser);
                              });
                              Navigator.pop(ctx);
                              _snack('Invitation sent to ${newUser.fullName}');
                            },
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── view user dialog ──────────────────────────────────────────────────────
  void _showViewDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) {
        final br          = Theme.of(ctx).brightness;
        final textPrimary = AppTheme.textPrimary(br);
        final textSec     = AppTheme.textSecondary(br);
        final borderColor = AppTheme.border(br);
        final surfColor   = AppTheme.surfaceColor(br);
        return Dialog(
          backgroundColor: surfColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dialogHeader(ctx, Icons.person_outlined, 'User Details', AppColors.primary),
                    const SizedBox(height: 20),
                    Row(children: [
                      _avatar(user, radius: 28),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                          const SizedBox(height: 2),
                          Text(user.role,
                              style: TextStyle(fontSize: 13, color: textSec)),
                        ],
                      )),
                      _statusBadge(user.status, br),
                    ]),
                    const SizedBox(height: 16),
                    Divider(color: borderColor),
                    const SizedBox(height: 16),
                    _detailRow(ctx, Icons.email_outlined, 'Email', user.email),
                    _detailRow(ctx, Icons.business_outlined, 'Department', user.department),
                    _detailRow(ctx, Icons.access_time_rounded, 'Last Active', user.lastActive),
                    _detailRow(ctx, Icons.calendar_today_outlined, 'Account Created', user.accountCreated),
                    if (user.recentActivity.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Recent Activity',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                      const SizedBox(height: 8),
                      ...user.recentActivity.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          const Icon(Icons.circle, size: 6, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(a,
                              style: TextStyle(fontSize: 13, color: textSec))),
                        ]),
                      )),
                    ],
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── edit user dialog ──────────────────────────────────────────────────────
  void _showEditDialog(AppUser user) {
    final nameCtrl  = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final deptCtrl  = TextEditingController(text: user.department);
    String role   = user.role;
    final formKey = GlobalKey<FormState>();
    final roles   = ['Administrator', 'Marketing Manager', 'Marketing Staff', 'Analyst', 'Viewer'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final br = Theme.of(ctx).brightness;
          return Dialog(
            backgroundColor: AppTheme.surfaceColor(br),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dialogHeader(ctx, Icons.edit_rounded, 'Edit User', AppColors.primary),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: nameCtrl, label: 'Full Name *',
                          hint: 'Full name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: emailCtrl, label: 'Email Address *',
                          hint: 'email@marketflow.et',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(ctx, 'Role *', role, roles,
                            (v) => setLocal(() => role = v!)),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: deptCtrl, label: 'Department',
                          hint: 'e.g. Marketing',
                          prefixIcon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 24),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          CustomButton(
                            text: 'Save Changes',
                            fullWidth: false,
                            size: ButtonSize.small,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final updated = user.copyWith(
                                fullName:   nameCtrl.text.trim(),
                                email:      emailCtrl.text.trim(),
                                role:       role,
                                department: deptCtrl.text.trim().isEmpty
                                    ? user.department : deptCtrl.text.trim(),
                              );
                              setState(() {
                                final idx = _users.indexWhere((u) => u.id == user.id);
                                if (idx != -1) _users[idx] = updated;
                              });
                              Navigator.pop(ctx);
                              _snack('${updated.fullName} updated successfully');
                            },
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── toggle active / inactive ──────────────────────────────────────────────
  void _toggleStatus(AppUser user) {
    final newStatus = user.status == UserStatus.active
        ? UserStatus.inactive
        : UserStatus.active;
    final label = newStatus == UserStatus.active ? 'activated' : 'deactivated';
    setState(() {
      final idx = _users.indexWhere((u) => u.id == user.id);
      if (idx != -1) _users[idx] = user.copyWith(status: newStatus);
    });
    _snack(
      '${user.fullName} has been $label',
      icon: newStatus == UserStatus.active
          ? Icons.check_circle_rounded : Icons.cancel_rounded,
      color: newStatus == UserStatus.active
          ? AppColors.success : AppColors.warning,
    );
  }

  // ── delete user ───────────────────────────────────────────────────────────
  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) {
        final br = Theme.of(ctx).brightness;
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor(br),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.dangerBg(br),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete User',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.danger)),
          ]),
          content: Text(
            'Are you sure you want to delete ${user.fullName}? '
            'This action cannot be undone.',
            style: TextStyle(color: AppTheme.textPrimary(br)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _users.removeWhere((u) => u.id == user.id));
                Navigator.pop(ctx);
                _snack('${user.fullName} deleted',
                    icon: Icons.delete_rounded, color: AppColors.danger);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ── roles & permissions dialog ────────────────────────────────────────────
  void _showRolePermissionsDialog(AppRole role) {
    List<ModulePermission> perms;
    if (role.name == 'Administrator')   { perms = UserRoleRepository.getAdminPermissions(); }
    else if (role.name == 'Viewer')     { perms = UserRoleRepository.getViewerPermissions(); }
    else                                { perms = UserRoleRepository.getManagerPermissions(); }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final br      = Theme.of(ctx).brightness;
          final textSec = AppTheme.textSecondary(br);
          return Dialog(
            backgroundColor: AppTheme.surfaceColor(br),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dialogHeader(ctx, Icons.security_rounded,
                        '${role.name} — Permissions', role.color),
                    const SizedBox(height: 8),
                    Text(role.description,
                        style: TextStyle(fontSize: 13, color: textSec)),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _PermissionMatrix(
                          permissions: perms,
                          onChanged: (p) => setLocal(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        text: 'Save Changes',
                        fullWidth: false,
                        size: ButtonSize.small,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _snack('Permissions for ${role.name} updated');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────
  // CustomScrollView so the page header is pinned via SliverPersistentHeader
  // while the body content scrolls underneath it.
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor    = AppTheme.backgroundFill(brightness);

    return CustomScrollView(
      slivers: [
        // ── Pinned page header ──────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _UsersStickyHeaderDelegate(
            brightness: brightness,
            bgColor: bgColor,
            onInvite: _showInviteDialog,
          ),
        ),

        // ── Scrollable body ─────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiRow(),
                const SizedBox(height: AppConstants.sectionSpacing),
                _buildTabBar(),
                const SizedBox(height: 16),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── KPI row ───────────────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    final kpis = [
      _KpiData('Total Users',         '$_totalUsers',  Icons.group_outlined,                AppColors.primary),
      _KpiData('Active Users',        '$_activeUsers', Icons.check_circle_outline,           AppColors.success),
      _KpiData('Administrators',      '$_admins',      Icons.admin_panel_settings_outlined,  AppColors.info),
      _KpiData('Pending Invitations', '$_pending',     Icons.schedule_outlined,              AppColors.warning),
    ];
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth >= 800 ? 4 : (c.maxWidth >= 500 ? 2 : 1);
      final w = (c.maxWidth - (cols - 1) * AppConstants.itemSpacing) / cols;
      return Wrap(
        spacing: AppConstants.itemSpacing,
        runSpacing: AppConstants.itemSpacing,
        children: kpis.map((k) => SizedBox(width: w, child: _KpiCard(data: k))).toList(),
      );
    });
  }

  // ── tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    return Container(
      decoration: BoxDecoration(
        color: surfColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: TabBar(
        controller: _tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppTheme.textSecondary(br),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: br == Brightness.dark ? 0.18 : 1.0),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'User Management'),
          Tab(text: 'Roles & Permissions'),
          Tab(text: 'Recent Activity'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return [
      _buildUserManagement(),
      _buildRolesAndPermissions(),
      _buildRecentActivity(),
    ][_tab.index];
  }

  // ── user management tab ───────────────────────────────────────────────────
  Widget _buildUserManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToolbar(),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth >= AppConstants.tabletBreakpoint - 240) {
            return _buildDesktopTable();
          }
          return _buildMobileCardList();
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    final roles    = ['All', 'Administrator', 'Marketing Manager', 'Marketing Staff', 'Analyst', 'Viewer'];
    final statuses = ['All', 'Active', 'Inactive', 'Pending'];
    final sorts    = ['Name', 'Role', 'Department', 'Status'];

    final filters = [
      _FilterChip(label: 'Role',   value: _roleFilter,   items: roles,    onChanged: (v) => setState(() { _roleFilter   = v; })),
      _FilterChip(label: 'Dept',   value: _deptFilter,   items: _allDepts, onChanged: (v) => setState(() { _deptFilter   = v; })),
      _FilterChip(label: 'Status', value: _statusFilter, items: statuses, onChanged: (v) => setState(() { _statusFilter = v; })),
      _FilterChip(label: 'Sort',   value: _sortBy,       items: sorts,    onChanged: (v) => setState(() { _sortBy       = v; })),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _searchCtrl,
          hint: 'Search users by name, email, or department...',
          prefixIcon: Icons.search_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: filters),
      ],
    );
  }

  // ── desktop table ─────────────────────────────────────────────────────────
  Widget _buildDesktopTable() {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final tableHeader = AppTheme.tableHeaderColor(br);
    final textSec     = AppTheme.textSecondary(br);
    final users       = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: surfColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tableHeader,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusLarge)),
            ),
            child: Row(children: [
              Expanded(flex: 3, child: _ColHeader('User',        textSec)),
              Expanded(flex: 3, child: _ColHeader('Email',       textSec)),
              Expanded(flex: 2, child: _ColHeader('Role',        textSec)),
              Expanded(flex: 2, child: _ColHeader('Department',  textSec)),
              Expanded(flex: 2, child: _ColHeader('Status',      textSec)),
              Expanded(flex: 2, child: _ColHeader('Last Active', textSec)),
              SizedBox(width: 120, child: _ColHeader('Actions',  textSec)),
            ]),
          ),
          Divider(height: 1, color: borderColor),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(
                'No users match the current filters.',
                style: TextStyle(color: textSec),
              )),
            )
          else
            ...users.asMap().entries.map((e) {
              final u = e.value;
              return _DesktopUserRow(
                user: u,
                isLast: e.key == users.length - 1,
                onView:   () => _showViewDialog(u),
                onEdit:   () => _showEditDialog(u),
                onToggle: () => _toggleStatus(u),
                onDelete: () => _confirmDelete(u),
              );
            }),
        ],
      ),
    );
  }

  // ── mobile card list ──────────────────────────────────────────────────────
  Widget _buildMobileCardList() {
    final br    = Theme.of(context).brightness;
    final users = _filtered;
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('No users match the current filters.',
              style: TextStyle(color: AppTheme.textSecondary(br))),
        ),
      );
    }
    return Column(
      children: users.map((u) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _MobileUserCard(
          user: u,
          onView:   () => _showViewDialog(u),
          onEdit:   () => _showEditDialog(u),
          onToggle: () => _toggleStatus(u),
          onDelete: () => _confirmDelete(u),
        ),
      )).toList(),
    );
  }

  // ── roles & permissions tab ───────────────────────────────────────────────
  Widget _buildRolesAndPermissions() {
    final br          = Theme.of(context).brightness;
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final roles       = UserRoleRepository.roles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Roles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: textPrimary)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth >= 800 ? 2 : 1;
          final w = (c.maxWidth - (cols - 1) * AppConstants.itemSpacing) / cols;
          return Wrap(
            spacing: AppConstants.itemSpacing,
            runSpacing: AppConstants.itemSpacing,
            children: roles.map((r) => SizedBox(
              width: w,
              child: _RoleCard(
                role: r,
                userCount: _users.where((u) => u.role == r.name).length,
                onView: () => _showRolePermissionsDialog(r),
                onEdit: () => _showRolePermissionsDialog(r),
              ),
            )).toList(),
          );
        }),
        const SizedBox(height: 24),
        Text('Permission Matrix — Administrator (demo)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: textPrimary)),
        const SizedBox(height: 4),
        Text('Select a role above to view and edit its permissions.',
            style: TextStyle(fontSize: 13, color: textSec)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: surfColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: _PermissionMatrix(
            permissions: UserRoleRepository.getAdminPermissions(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }

  // ── recent activity tab ───────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final divColor    = AppTheme.divider(br);
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    final entries     = UserRoleRepository.recentActivity;

    return Container(
      decoration: BoxDecoration(
        color: surfColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final entry  = e.value;
          final isLast = e.key == entries.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: entry.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(entry.icon, color: entry.iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.description,
                        style: TextStyle(fontSize: 14, color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(entry.timestamp,
                        style: TextStyle(fontSize: 12, color: textSec)),
                  ],
                )),
              ]),
            ),
            if (!isLast) Divider(height: 1, color: divColor),
          ]);
        }).toList(),
      ),
    );
  }

  // ── shared dialog helpers ─────────────────────────────────────────────────
  Widget _dialogHeader(BuildContext ctx, IconData icon, String title, Color color) {
    final textPrimary = AppTheme.textPrimary(Theme.of(ctx).brightness);
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 12),
      Text(title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              color: textPrimary)),
    ]);
  }

  Widget _dropdownField(
    BuildContext ctx,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final br          = Theme.of(ctx).brightness;
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    final inputFill   = AppTheme.inputFill(br);
    final borderColor = AppTheme.border(br);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          dropdownColor: AppTheme.surfaceColor(br),
          style: TextStyle(fontSize: 14, color: textPrimary),
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(i, style: TextStyle(color: textPrimary)),
          )).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.8)),
            hintStyle: TextStyle(color: textSec),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(BuildContext ctx, IconData icon, String label, String value) {
    final br          = Theme.of(ctx).brightness;
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 16, color: textSec),
        const SizedBox(width: 10),
        SizedBox(width: 110,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: textSec))),
        Expanded(child: Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: textPrimary))),
      ]),
    );
  }

  Widget _avatar(AppUser u, {double radius = 20}) {
    final color = _roleColor(u.role);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(u.initials,
          style: TextStyle(color: color, fontWeight: FontWeight.w700,
              fontSize: radius * 0.6)),
    );
  }

  Widget _statusBadge(UserStatus s, Brightness br) {
    switch (s) {
      case UserStatus.active:
        return _badge('Active', AppColors.success, AppTheme.successBg(br));
      case UserStatus.inactive:
        return _badge('Inactive', AppTheme.textSecondary(br),
            AppTheme.surfaceVariant(br));
      case UserStatus.pending:
        return _badge('Pending', AppColors.warning, AppTheme.warningBg(br));
    }
  }

  Widget _badge(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: text)),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Administrator':     return AppColors.primary;
      case 'Marketing Manager': return AppColors.info;
      case 'Marketing Staff':   return AppColors.success;
      case 'Analyst':           return AppColors.warning;
      default:                  return AppColors.textSecondary;
    }
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _UsersStickyHeaderDelegate — pinned page header (matches CampaignListScreen)
// ─────────────────────────────────────────────────────────────────────────────

class _UsersStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Brightness brightness;
  final Color bgColor;
  final VoidCallback onInvite;

  static const double _height = 80.0;

  const _UsersStickyHeaderDelegate({
    required this.brightness,
    required this.bgColor,
    required this.onInvite,
  });

  @override double get minExtent => _height;
  @override double get maxExtent => _height;

  @override
  bool shouldRebuild(_UsersStickyHeaderDelegate old) =>
      old.brightness != brightness ||
      old.bgColor != bgColor ||
      old.onInvite != onInvite;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      color: bgColor,
      child: Container(
        height: _height,
        decoration: BoxDecoration(
          color: bgColor,
          border: overlapsContent
              ? Border(bottom: BorderSide(
                  color: AppTheme.border(brightness), width: 1))
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.pagePadding,
          vertical: 12,
        ),
        child: _UsersPageHeaderBar(onInvite: onInvite),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UsersPageHeaderBar — icon badge + title + subtitle + Invite User button
// ─────────────────────────────────────────────────────────────────────────────

class _UsersPageHeaderBar extends StatelessWidget {
  final VoidCallback onInvite;
  const _UsersPageHeaderBar({required this.onInvite});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textSec    = AppTheme.textSecondary(brightness);

    return LayoutBuilder(builder: (context, cst) {
      final narrow = cst.maxWidth < 500;

      final titleBlock = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Icon(Icons.manage_accounts_outlined,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Users & Roles',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage team members, roles, and access permissions.',
                  style: TextStyle(fontSize: 12, color: textSec),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      );

      final inviteButton = ElevatedButton.icon(
        onPressed: onInvite,
        icon: const Icon(Icons.person_add_outlined, size: 15),
        label: narrow ? const Text('Invite') : const Text('Invite User'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium)),
          textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 12),
          inviteButton,
        ],
      );
    });
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _KpiData + _KpiCard
// ─────────────────────────────────────────────────────────────────────────────

class _KpiData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: surfColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Icon(data.icon, size: 22, color: data.color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 2),
            Text(data.label,
                style: TextStyle(fontSize: 12, color: textSec)),
          ],
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ColHeader
// ─────────────────────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  final Color color;
  const _ColHeader(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: color));
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _FilterChip — inline dropdown filter label
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _FilterChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    final isActive    = value != 'All';

    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: AppTheme.surfaceColor(br),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        side: BorderSide(color: borderColor),
      ),
      itemBuilder: (_) => items.map((i) => PopupMenuItem(
        value: i,
        child: Text(i, style: TextStyle(
            fontSize: 13, color: textPrimary)),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight.withValues(
                  alpha: br == Brightness.dark ? 0.18 : 1.0)
              : surfColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.4)
                : borderColor,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$label: $value', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : textPrimary,
          )),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 18,
              color: isActive ? AppColors.primary : textSec),
        ]),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _DesktopUserRow
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopUserRow extends StatefulWidget {
  final AppUser user;
  final bool isLast;
  final VoidCallback onView, onEdit, onToggle, onDelete;
  const _DesktopUserRow({
    required this.user,
    required this.isLast,
    required this.onView,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  @override
  State<_DesktopUserRow> createState() => _DesktopUserRowState();
}

class _DesktopUserRowState extends State<_DesktopUserRow> {
  bool _hovered = false;

  Color _roleColor(String role) {
    switch (role) {
      case 'Administrator':     return AppColors.primary;
      case 'Marketing Manager': return AppColors.info;
      case 'Marketing Staff':   return AppColors.success;
      case 'Analyst':           return AppColors.warning;
      default:                  return AppColors.textSecondary;
    }
  }

  Widget _statusBadge(UserStatus s, Brightness br) {
    switch (s) {
      case UserStatus.active:
        return _badge('Active', AppColors.success,
            AppTheme.successBg(br), Icons.check_circle_outline);
      case UserStatus.inactive:
        return _badge('Inactive', AppTheme.textSecondary(br),
            AppTheme.surfaceVariant(br), Icons.remove_circle_outline);
      case UserStatus.pending:
        return _badge('Pending', AppColors.warning,
            AppTheme.warningBg(br), Icons.schedule_outlined);
    }
  }

  Widget _badge(String label, Color text, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: text),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: text)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    final divColor    = AppTheme.divider(br);
    final hoverColor  = AppTheme.tableRowHover(br);
    final u           = widget.user;
    final rc          = _roleColor(u.role);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        color: _hovered ? hoverColor : Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(flex: 3, child: Row(children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: rc.withValues(alpha: 0.15),
                  child: Text(u.initials,
                      style: TextStyle(color: rc,
                          fontWeight: FontWeight.w700, fontSize: 10)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(u.fullName,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: textPrimary),
                    overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(flex: 3, child: Text(u.email,
                  style: TextStyle(fontSize: 13, color: textSec),
                  overflow: TextOverflow.ellipsis)),
              Expanded(flex: 2, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: rc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(u.role,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: rc),
                    overflow: TextOverflow.ellipsis),
              )),
              Expanded(flex: 2, child: Text(u.department,
                  style: TextStyle(fontSize: 13, color: textPrimary),
                  overflow: TextOverflow.ellipsis)),
              Expanded(flex: 2, child: _statusBadge(u.status, br)),
              Expanded(flex: 2, child: Text(u.lastActive,
                  style: TextStyle(fontSize: 12, color: textSec),
                  overflow: TextOverflow.ellipsis)),
              SizedBox(width: 120, child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(Icons.visibility_outlined, 'View',
                      AppColors.primary, widget.onView),
                  _iconBtn(Icons.edit_outlined, 'Edit',
                      AppColors.info, widget.onEdit),
                  _iconBtn(
                    u.status == UserStatus.active
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                    u.status == UserStatus.active ? 'Deactivate' : 'Activate',
                    u.status == UserStatus.active
                        ? AppColors.warning : AppColors.success,
                    widget.onToggle,
                  ),
                  _iconBtn(Icons.delete_outline_rounded, 'Delete',
                      AppColors.danger, widget.onDelete),
                ],
              )),
            ]),
          ),
          if (!widget.isLast) Divider(height: 1, color: divColor),
        ]),
      ),
    );
  }

  Widget _iconBtn(
      IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _MobileUserCard
// ─────────────────────────────────────────────────────────────────────────────

class _MobileUserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onView, onEdit, onToggle, onDelete;
  const _MobileUserCard({
    required this.user,
    required this.onView,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  Color _rc(String role) {
    switch (role) {
      case 'Administrator':     return AppColors.primary;
      case 'Marketing Manager': return AppColors.info;
      case 'Marketing Staff':   return AppColors.success;
      case 'Analyst':           return AppColors.warning;
      default:                  return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final divColor    = AppTheme.divider(br);
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);
    final u           = user;
    final rc          = _rc(u.role);

    Widget statusBadge(UserStatus s) {
      switch (s) {
        case UserStatus.active:
          return _badge('Active', AppColors.success, AppTheme.successBg(br));
        case UserStatus.inactive:
          return _badge('Inactive', AppTheme.textSecondary(br),
              AppTheme.surfaceVariant(br));
        case UserStatus.pending:
          return _badge('Pending', AppColors.warning, AppTheme.warningBg(br));
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: rc.withValues(alpha: 0.15),
            child: Text(u.initials,
                style: TextStyle(color: rc,
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(u.fullName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: textPrimary)),
              Text(u.email,
                  style: TextStyle(fontSize: 12, color: textSec),
                  overflow: TextOverflow.ellipsis),
            ],
          )),
          statusBadge(u.status),
        ]),
        const SizedBox(height: 12),
        Divider(height: 1, color: divColor),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _infoChip(Icons.work_outline_rounded, u.role, rc)),
          const SizedBox(width: 8),
          Expanded(child: _infoChip(Icons.business_outlined,
              u.department, textSec)),
        ]),
        const SizedBox(height: 8),
        _infoChip(Icons.access_time_rounded,
            'Last active: ${u.lastActive}', textSec),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.visibility_outlined, size: 14),
            label: const Text('View'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.info,
              side: BorderSide(color: AppColors.info.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: onToggle,
            icon: Icon(
              u.status == UserStatus.active
                  ? Icons.block_outlined : Icons.check_circle_outline,
              size: 14),
            label: Text(u.status == UserStatus.active
                ? 'Deactivate' : 'Activate'),
            style: OutlinedButton.styleFrom(
              foregroundColor: u.status == UserStatus.active
                  ? AppColors.warning : AppColors.success,
              side: BorderSide(
                color: (u.status == UserStatus.active
                    ? AppColors.warning : AppColors.success)
                    .withValues(alpha: 0.4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(44, 38),
            ),
            child: const Icon(Icons.delete_outline_rounded, size: 16),
          ),
        ]),
      ]),
    );
  }

  Widget _badge(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: text)),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Expanded(child: Text(label,
          style: TextStyle(fontSize: 12, color: color),
          overflow: TextOverflow.ellipsis)),
    ]);
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _RoleCard
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final AppRole role;
  final int userCount;
  final VoidCallback onView, onEdit;
  const _RoleCard({
    required this.role,
    required this.userCount,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final surfColor   = AppTheme.surfaceColor(br);
    final borderColor = AppTheme.border(br);
    final textPrimary = AppTheme.textPrimary(br);
    final textSec     = AppTheme.textSecondary(br);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: role.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shield_outlined, color: role.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: textPrimary)),
              Text('$userCount user${userCount != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: textSec)),
            ],
          )),
        ]),
        const SizedBox(height: 10),
        Text(role.description,
            style: TextStyle(fontSize: 13, color: textSec)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: role.color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(role.permissionSummary,
              style: TextStyle(fontSize: 12, color: role.color,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.visibility_outlined, size: 14),
            label: const Text('View'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Edit Permissions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.info,
              side: BorderSide(color: AppColors.info.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )),
        ]),
      ]),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _PermissionMatrix — responsive, never overflows
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionMatrix extends StatefulWidget {
  final List<ModulePermission> permissions;
  final ValueChanged<ModulePermission> onChanged;
  const _PermissionMatrix({
    required this.permissions,
    required this.onChanged,
  });
  @override
  State<_PermissionMatrix> createState() => _PermissionMatrixState();
}

class _PermissionMatrixState extends State<_PermissionMatrix> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final narrow = c.maxWidth < 500;
      return narrow ? _buildCards(ctx) : _buildTable(ctx);
    });
  }

  Widget _buildTable(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final surfVar     = AppTheme.surfaceVariant(br);
    final textSec     = AppTheme.textSecondary(br);
    final textPrimary = AppTheme.textPrimary(br);

    return Column(children: [
      // header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: surfVar,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Expanded(flex: 4, child: Text('Module',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: textSec))),
          Expanded(child: Center(child: Text('View',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: textSec)))),
          Expanded(child: Center(child: Text('Create',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: textSec)))),
          Expanded(child: Center(child: Text('Edit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: textSec)))),
          Expanded(child: Center(child: Text('Delete',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: textSec)))),
        ]),
      ),
      const SizedBox(height: 4),
      ...widget.permissions.asMap().entries.map((e) {
        final p    = e.value;
        final even = e.key.isEven;
        return Container(
          color: even
              ? Colors.transparent
              : surfVar.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            Expanded(flex: 4, child: Text(p.module,
                style: TextStyle(fontSize: 13, color: textPrimary))),
            Expanded(child: Center(child: _perm(p.view,
                (v) => setState(() { p.view   = v; widget.onChanged(p); })))),
            Expanded(child: Center(child: _perm(p.create,
                (v) => setState(() { p.create = v; widget.onChanged(p); })))),
            Expanded(child: Center(child: _perm(p.edit,
                (v) => setState(() { p.edit   = v; widget.onChanged(p); })))),
            Expanded(child: Center(child: _perm(p.delete,
                (v) => setState(() { p.delete = v; widget.onChanged(p); })))),
          ]),
        );
      }),
    ]);
  }

  Widget _buildCards(BuildContext context) {
    final br          = Theme.of(context).brightness;
    final surfVar     = AppTheme.surfaceVariant(br);
    final textPrimary = AppTheme.textPrimary(br);
    final textDark    = AppTheme.textPrimary(br);

    return Column(children: widget.permissions.map((p) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfVar,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.module,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: textPrimary)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, children: [
            _permLabel('View',   p.view,
                (v) => setState(() { p.view   = v; widget.onChanged(p); }), textDark),
            _permLabel('Create', p.create,
                (v) => setState(() { p.create = v; widget.onChanged(p); }), textDark),
            _permLabel('Edit',   p.edit,
                (v) => setState(() { p.edit   = v; widget.onChanged(p); }), textDark),
            _permLabel('Delete', p.delete,
                (v) => setState(() { p.delete = v; widget.onChanged(p); }), textDark),
          ]),
        ]),
      ),
    )).toList());
  }

  Widget _perm(bool val, ValueChanged<bool> onChanged) {
    return Checkbox(
      value: val,
      onChanged: (v) => onChanged(v ?? false),
      activeColor: AppColors.primary,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  Widget _permLabel(
      String label, bool val, ValueChanged<bool> onChanged, Color textColor) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(
        value: val,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: AppColors.primary,
      ),
      Text(label, style: TextStyle(fontSize: 12, color: textColor)),
    ]);
  }
}
