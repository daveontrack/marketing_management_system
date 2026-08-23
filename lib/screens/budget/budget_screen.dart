import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/budget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data source: BudgetRepository (Supabase-backed). The former local
// Budget model and seed list moved into lib/models/budget.dart.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// BudgetScreen
// ─────────────────────────────────────────────────────────────────────────────

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  /// Working copy of the repository data, refreshed after every mutation so
  /// setState picks up changes made through [BudgetRepository].
  List<Budget> _budgets = List.from(BudgetRepository.getAll());

  void _reload() => _budgets = List.from(BudgetRepository.getAll());

  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _statusFilter = 'All';
  String _selectedPeriod = 'This Year';
  int _currentPage = 1;
  static const int _pageSize = 6;

  static const List<String> _categories = [
    'All', 'Advertising', 'Content', 'Influencer Marketing', 'Events', 'Email/SMS', 'Other',
  ];
  static const List<String> _statusOptions = [
    'All', 'Active', 'Paused', 'Completed', 'Draft',
  ];
  static const List<String> _periods = [
    'This Month', 'Last Month', 'This Quarter', 'This Year', 'Custom Range',
  ];

  List<Budget> get _filtered => _budgets.where((b) {
    final q = _searchQuery.toLowerCase();
    final matchQ = q.isEmpty || b.name.toLowerCase().contains(q) ||
        b.category.toLowerCase().contains(q) || b.description.toLowerCase().contains(q);
    final matchC = _categoryFilter == 'All' || b.category == _categoryFilter;
    final matchS = _statusFilter == 'All' || b.status == _statusFilter;
    return matchQ && matchC && matchS;
  }).toList();

  double get _totalAllocated => _budgets.fold(0, (s, b) => s + b.allocated);
  double get _totalSpent => _budgets.fold(0, (s, b) => s + b.spent);
  double get _totalRemaining => _budgets.fold(0, (s, b) => s + b.remaining);

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  void _openForm({Budget? existing}) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final allocatedCtrl = TextEditingController(
        text: existing != null ? existing.allocated.toStringAsFixed(0) : '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String category = existing?.category ?? 'Advertising';
    String status = existing?.status ?? AppConstants.statusActive;
    DateTime startDate = existing?.startDate ?? DateTime(2026, 1, 1);
    DateTime endDate = existing?.endDate ?? DateTime(2026, 12, 31);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final brightness = Theme.of(ctx).brightness;
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppTheme.primaryLighter(brightness),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                        child: Icon(
                            isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(isEdit ? 'Edit Budget' : 'Add Budget',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(brightness))),
                    ]),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    _formLabel('Budget Name *', brightness),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: _inputDec('e.g. Digital Advertising Q3', brightness),
                      style: _inputStyle(brightness),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(builder: (_, bc) {
                      final narrow = bc.maxWidth < 420;
                      final categoryField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _formLabel('Category', brightness),
                          const SizedBox(height: 6),
                          _DropdownInput(value: category,
                              items: _categories.where((c) => c != 'All').toList(),
                              onChanged: (v) => setLocal(() => category = v)),
                        ],
                      );
                      final statusField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _formLabel('Status', brightness),
                          const SizedBox(height: 6),
                          _DropdownInput(value: status,
                              items: _statusOptions.where((s) => s != 'All').toList(),
                              onChanged: (v) => setLocal(() => status = v)),
                        ],
                      );
                      if (narrow) {
                        return Column(children: [categoryField, const SizedBox(height: 14), statusField]);
                      }
                      return Row(children: [
                        Expanded(child: categoryField), const SizedBox(width: 12), Expanded(child: statusField),
                      ]);
                    }),
                    const SizedBox(height: 14),
                    _formLabel('Allocated Amount (ETB) *', brightness),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: allocatedCtrl,
                      decoration: _inputDec('e.g. 250000', brightness),
                      style: _inputStyle(brightness),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(builder: (_, bc) {
                      final narrow = bc.maxWidth < 420;
                      Future<void> pickDate(bool isStart) async {
                        final picked = await showDatePicker(
                          context: ctx, initialDate: isStart ? startDate : endDate,
                          firstDate: DateTime(2025), lastDate: DateTime(2030),
                        );
                        if (picked != null) setLocal(() { if (isStart) { startDate = picked; } else { endDate = picked; } });
                      }
                      final startField = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _formLabel('Start Date', brightness), const SizedBox(height: 6),
                        _DatePickerButton(date: startDate, onTap: () => pickDate(true)),
                      ]);
                      final endField = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _formLabel('End Date', brightness), const SizedBox(height: 6),
                        _DatePickerButton(date: endDate, onTap: () => pickDate(false)),
                      ]);
                      if (narrow) return Column(children: [startField, const SizedBox(height: 14), endField]);
                      return Row(children: [Expanded(child: startField), const SizedBox(width: 12), Expanded(child: endField)]);
                    }),
                    const SizedBox(height: 14),
                    _formLabel('Description', brightness),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: descCtrl,
                      decoration: _inputDec('Brief description of this budget…', brightness),
                      style: _inputStyle(brightness),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final item = Budget(
                            id: isEdit ? existing.id : BudgetRepository.nextId(),
                            name: nameCtrl.text.trim(), category: category,
                            allocated: double.parse(allocatedCtrl.text.trim()),
                            spent: isEdit ? existing.spent : 0,
                            startDate: startDate, endDate: endDate,
                            description: descCtrl.text.trim(), status: status,
                            lastUpdated: DateTime.now(),
                          );
                          setState(() {
                            if (isEdit) {
                              BudgetRepository.update(item);
                            } else {
                              BudgetRepository.add(item);
                            }
                            _reload();
                          });
                          Navigator.pop(ctx);
                          _showSnack(isEdit ? 'Budget updated.' : 'Budget added.');
                        },
                        child: Text(isEdit ? 'Save Changes' : 'Add Budget'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _confirmDelete(Budget b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
        title: const Text('Delete Budget', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
        content: Text('Delete "${b.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                BudgetRepository.remove(b.id);
                _reload();
              });
              Navigator.pop(ctx); _showSnack('Budget deleted.');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final filtered = _filtered;
    final pageCount = (filtered.length / _pageSize).ceil().clamp(1, 9999);
    final page = _currentPage.clamp(1, pageCount);
    final pageItems = filtered.skip((page - 1) * _pageSize).take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Plain sticky header (no SliverPersistentHeader) ───────────────
        _BudgetHeaderSurface(
          brightness: brightness,
          selectedPeriod: _selectedPeriod,
          onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
          onAddBudget: () => _openForm(),
          onExport: () => _showSnack('Exporting budget data…'),
          periods: _periods,
        ),

        // ── Scrollable content ────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              AppConstants.sectionSpacing,
              AppConstants.pagePadding,
              AppConstants.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KpiCardsRow(totalAllocated: _totalAllocated, totalSpent: _totalSpent, totalRemaining: _totalRemaining),
                const SizedBox(height: AppConstants.sectionSpacing),
                _ChartsSection(budgets: _budgets),
                const SizedBox(height: AppConstants.sectionSpacing),
                _UtilizationSection(budgets: _budgets),
                const SizedBox(height: AppConstants.sectionSpacing),
                _AlertsSection(budgets: _budgets),
                const SizedBox(height: AppConstants.sectionSpacing),
                _BudgetTableSection(
                  items: pageItems, allFiltered: filtered,
                  searchQuery: _searchQuery, categoryFilter: _categoryFilter, statusFilter: _statusFilter,
                  currentPage: page, pageCount: pageCount,
                  categories: _categories, statusOptions: _statusOptions,
                  onSearchChanged: (v) => setState(() { _searchQuery = v; _currentPage = 1; }),
                  onCategoryChanged: (v) => setState(() { _categoryFilter = v; _currentPage = 1; }),
                  onStatusChanged: (v) => setState(() { _statusFilter = v; _currentPage = 1; }),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  onEdit: (b) => _openForm(existing: b),
                  onDelete: _confirmDelete,
                  onView: (b) => _openForm(existing: b),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BudgetHeaderSurface — replaces _BudgetHeaderDelegate + SliverPersistentHeader
// Plain StatelessWidget; no sliver geometry constraints.
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetHeaderSurface extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onAddBudget;
  final VoidCallback onExport;
  final List<String> periods;
  final Brightness brightness;

  const _BudgetHeaderSurface({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onAddBudget,
    required this.onExport,
    required this.periods,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor(brightness),
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(brightness),
          border: Border(
            bottom: BorderSide(color: AppTheme.border(brightness), width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pagePadding,
            vertical: 12,
          ),
          child: _BudgetPageHeader(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
            onAddBudget: onAddBudget,
            onExport: onExport,
            periods: periods,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Header
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetPageHeader extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onAddBudget;
  final VoidCallback onExport;
  final List<String> periods;

  const _BudgetPageHeader({
    required this.selectedPeriod, required this.onPeriodChanged,
    required this.onAddBudget, required this.onExport, required this.periods,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textSec    = AppTheme.textSecondary(brightness);

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 640;

      final titleBlock = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('Monitor marketing spending, allocation, and financial performance.',
                  style: TextStyle(color: textSec, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ],
          ),
        ],
      );

      final actions = Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border(brightness)),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            color: AppTheme.surfaceColor(brightness),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedPeriod,
              dropdownColor: AppTheme.surfaceColor(brightness),
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness)),
              icon: Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.iconColor(brightness)),
              items: periods.map((p) => DropdownMenuItem(value: p,
                  child: Text(p, style: TextStyle(color: AppTheme.textPrimary(brightness))))).toList(),
              onChanged: (v) { if (v != null) onPeriodChanged(v); },
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(onPressed: onExport,
            icon: const Icon(Icons.download_outlined, size: 16), label: const Text('Export')),
        const SizedBox(width: 8),
        ElevatedButton.icon(onPressed: onAddBudget,
            icon: const Icon(Icons.add, size: 16), label: const Text('Add Budget'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
      ]);

      if (narrow) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock,
            const SizedBox(height: 8),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: actions),
          ],
        );
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Flexible(child: titleBlock),
        const SizedBox(width: 8),
        actions,
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Cards Row
// ─────────────────────────────────────────────────────────────────────────────

class _KpiCardsRow extends StatelessWidget {
  final double totalAllocated, totalSpent, totalRemaining;
  const _KpiCardsRow({required this.totalAllocated, required this.totalSpent, required this.totalRemaining});

  @override
  Widget build(BuildContext context) {
    final utilPct = totalAllocated > 0 ? (totalSpent / totalAllocated * 100).toStringAsFixed(1) : '0.0';
    final remPct = totalAllocated > 0 ? (totalRemaining / totalAllocated * 100).toStringAsFixed(1) : '0.0';
    final brightness = Theme.of(context).brightness;

    final cards = [
      _KpiCard(label: 'Total Budget', value: _etb(totalAllocated), subtitle: 'FY 2026 allocation',
          icon: Icons.account_balance_wallet_outlined, iconColor: AppColors.primary,
          iconBg: AppTheme.primaryLighter(brightness), badge: null),
      _KpiCard(label: 'Total Spent', value: _etb(totalSpent), subtitle: '$utilPct% of total budget used',
          icon: Icons.trending_up_outlined, iconColor: AppColors.warning,
          iconBg: AppTheme.warningBg(brightness), badge: '$utilPct%',
          badgeColor: double.parse(utilPct) >= 85 ? AppColors.danger : AppColors.warning),
      _KpiCard(label: 'Remaining', value: _etb(totalRemaining), subtitle: '$remPct% remaining',
          icon: Icons.savings_outlined, iconColor: AppColors.success,
          iconBg: AppTheme.successBg(brightness), badge: '$remPct%', badgeColor: AppColors.success),
      _KpiCard(label: 'ROI (Avg)', value: '3.8x', subtitle: '+0.4x vs last period',
          icon: Icons.auto_graph_outlined, iconColor: AppColors.info,
          iconBg: AppTheme.infoBg(brightness), badge: '+0.4x', badgeColor: AppColors.success),
    ];

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final cols = w >= 900 ? 4 : w >= 600 ? 2 : 1;
      final cardWidth = (w - (cols - 1) * AppConstants.itemSpacing) / cols;
      return Wrap(
        spacing: AppConstants.itemSpacing, runSpacing: AppConstants.itemSpacing,
        children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color iconColor, iconBg;
  final String? badge;
  final Color? badgeColor;

  const _KpiCard({required this.label, required this.value, required this.subtitle,
      required this.icon, required this.iconColor, required this.iconBg,
      this.badge, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(brightness),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppTheme.border(brightness)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
              child: Icon(icon, color: iconColor, size: 18)),
          const Spacer(),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: badgeColor!.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(badge!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor)),
            ),
        ]),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(brightness))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary(brightness))),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(brightness))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Charts Section
// ─────────────────────────────────────────────────────────────────────────────

class _ChartsSection extends StatelessWidget {
  final List<Budget> budgets;
  const _ChartsSection({required this.budgets});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      if (w >= 1100) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 5, child: _MonthlySpendingChart()),
          const SizedBox(width: AppConstants.itemSpacing),
          Expanded(flex: 4, child: _SpendingTrendChart()),
        ]);
      }
      return Column(children: [
        _MonthlySpendingChart(),
        const SizedBox(height: AppConstants.itemSpacing),
        _SpendingTrendChart(),
      ]);
    });
  }
}

class _MonthlySpendingChart extends StatelessWidget {
  const _MonthlySpendingChart();

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const List<double> _allocated = [180000.0, 195000, 210000, 220000, 245000, 250000];
  static const List<double> _spent = [145000.0, 162000, 188000, 205000, 231000, 238000];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(brightness),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppTheme.border(brightness)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryLighter(brightness),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
              child: const Icon(Icons.bar_chart_outlined, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Text('Monthly Spending', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(brightness))),
          const Spacer(),
          _LegendDot(color: AppColors.primary, label: 'Allocated'),
          const SizedBox(width: 12),
          _LegendDot(color: AppColors.warning, label: 'Spent'),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 300000,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppTheme.surfaceVariant(brightness),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = _months[group.x];
                  final label = rodIndex == 0 ? 'Allocated' : 'Spent';
                  return BarTooltipItem('$month\n$label: ${_etb(rod.toY)}',
                      TextStyle(color: AppTheme.textPrimary(brightness), fontSize: 11));
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  final i = val.toInt();
                  if (i < 0 || i >= _months.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 6),
                      child: Text(_months[i], style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))));
                },
              )),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 52, interval: 100000,
                getTitlesWidget: (val, meta) => Text(val == 0 ? '0' : '${(val / 1000).toInt()}K',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(brightness))),
              )),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100000,
                getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border(brightness).withValues(alpha: 0.6), strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(_months.length, (i) => BarChartGroupData(x: i, barsSpace: 4, barRods: [
              BarChartRodData(toY: _allocated[i], color: AppColors.primary.withValues(alpha: 0.35), width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
              BarChartRodData(toY: _spent[i], color: AppColors.warning, width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            ])),
          )),
        ),
      ]),
    );
  }
}

class _SpendingTrendChart extends StatelessWidget {
  const _SpendingTrendChart();

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const List<double> _current = [145000.0, 162000, 188000, 205000, 231000, 238000];
  static const List<double> _previous = [120000.0, 135000, 158000, 174000, 198000, 210000];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(brightness),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppTheme.border(brightness)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.infoBg(brightness),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
              child: const Icon(Icons.show_chart_outlined, color: AppColors.info, size: 18)),
          const SizedBox(width: 10),
          Text('Spending Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(brightness))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _LegendDot(color: AppColors.primary, label: 'This Year'),
          const SizedBox(width: 12),
          _LegendDot(color: AppTheme.textSecondary(brightness), label: 'Last Year'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50000,
                getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border(brightness).withValues(alpha: 0.6), strokeWidth: 1)),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, interval: 1,
                getTitlesWidget: (val, meta) {
                  final i = val.toInt();
                  if (i < 0 || i >= _months.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 6),
                      child: Text(_months[i], style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))));
                },
              )),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 52, interval: 50000,
                getTitlesWidget: (val, meta) => Text(val == 0 ? '0' : '${(val / 1000).toInt()}K',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(brightness))),
              )),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: 5, minY: 0, maxY: 280000,
            lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceVariant(brightness),
              getTooltipItems: (spots) => spots.map((spot) {
                final label = spot.barIndex == 0 ? 'This Year' : 'Last Year';
                return LineTooltipItem('$label\n${_etb(spot.y)}',
                    TextStyle(color: AppTheme.textPrimary(brightness), fontSize: 11));
              }).toList(),
            )),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(_current.length, (i) => FlSpot(i.toDouble(), _current[i])),
                isCurved: true, color: AppColors.primary, barWidth: 2.5,
                dotData: FlDotData(getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 3, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white)),
                belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.07)),
              ),
              LineChartBarData(
                spots: List.generate(_previous.length, (i) => FlSpot(i.toDouble(), _previous[i])),
                isCurved: true, color: AppTheme.textSecondary(brightness).withValues(alpha: 0.5),
                barWidth: 2, dashArray: [5, 4],
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          )),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utilization Section
// ─────────────────────────────────────────────────────────────────────────────

class _UtilizationSection extends StatelessWidget {
  final List<Budget> budgets;
  const _UtilizationSection({required this.budgets});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return LayoutBuilder(builder: (_, constraints) {
      final wide = constraints.maxWidth >= 900;
      final utilWidget = Container(
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        decoration: BoxDecoration(color: AppTheme.cardColor(brightness),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: AppTheme.border(brightness))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Budget Utilization', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(brightness))),
          const SizedBox(height: 4),
          Text('Spending vs allocation per category',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(brightness))),
          const SizedBox(height: 16),
          ...budgets.map((b) => _UtilizationRow(budget: b)),
        ]),
      );
      final donutWidget = Container(
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        decoration: BoxDecoration(color: AppTheme.cardColor(brightness),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: AppTheme.border(brightness))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Budget Allocation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(brightness))),
          const SizedBox(height: 4),
          Text('Distribution by category',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(brightness))),
          const SizedBox(height: 16),
          _AllocationDonut(budgets: budgets),
        ]),
      );
      if (wide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 5, child: utilWidget),
          const SizedBox(width: AppConstants.itemSpacing),
          Expanded(flex: 4, child: donutWidget),
        ]);
      }
      return Column(children: [utilWidget, const SizedBox(height: AppConstants.itemSpacing), donutWidget]);
    });
  }
}

class _UtilizationRow extends StatelessWidget {
  final Budget budget;
  const _UtilizationRow({required this.budget});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(budget.name,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary(brightness)),
              overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: budget.utilizationColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20)),
            child: Text(budget.utilizationStatus,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: budget.utilizationColor)),
          ),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: budget.utilization, minHeight: 6,
                backgroundColor: AppTheme.border(brightness),
                valueColor: AlwaysStoppedAnimation<Color>(budget.utilizationColor))),
        const SizedBox(height: 4),
        Row(children: [
          Text('${_etb(budget.spent)} spent',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))),
          const Spacer(),
          Text('${(budget.utilization * 100).toStringAsFixed(0)}% of ${_etb(budget.allocated)}',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))),
        ]),
      ]),
    );
  }
}

class _AllocationDonut extends StatefulWidget {
  final List<Budget> budgets;
  const _AllocationDonut({required this.budgets});
  @override
  State<_AllocationDonut> createState() => _AllocationDonutState();
}

class _AllocationDonutState extends State<_AllocationDonut> {
  int _touchedIndex = -1;

  static const _catColors = <String, Color>{
    'Advertising': AppColors.primary,
    'Content': AppColors.info,
    'Influencer Marketing': Color(0xFFBB5CF8),
    'Events': AppColors.danger,
    'Email/SMS': AppColors.warning,
    'Other': AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final total = widget.budgets.fold<double>(0, (s, b) => s + b.allocated);
    if (total == 0) return const SizedBox(height: 160);

    final catMap = <String, double>{};
    for (final b in widget.budgets) {
      catMap[b.category] = (catMap[b.category] ?? 0) + b.allocated;
    }
    final cats = catMap.entries.toList();

    return LayoutBuilder(builder: (_, bc) {
      final chartSize = (bc.maxWidth * 0.4).clamp(100.0, 180.0);
      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: chartSize, height: chartSize,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: chartSize * 0.28,
            pieTouchData: PieTouchData(touchCallback: (event, response) {
              if (response?.touchedSection != null) {
                setState(() => _touchedIndex = response!.touchedSection!.touchedSectionIndex);
              } else { setState(() => _touchedIndex = -1); }
            }),
            sections: List.generate(cats.length, (i) {
              final isTouched = i == _touchedIndex;
              final color = _catColors[cats[i].key] ?? AppColors.chartPalette[i % 6];
              final pct = cats[i].value / total * 100;
              return PieChartSectionData(
                color: color, value: cats[i].value,
                radius: isTouched ? chartSize * 0.34 : chartSize * 0.30,
                showTitle: isTouched, title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              );
            }),
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(cats.length, (i) {
              final color = _catColors[cats[i].key] ?? AppColors.chartPalette[i % 6];
              final pct = (cats[i].value / total * 100).toStringAsFixed(0);
              return Padding(padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cats[i].key,
                      style: TextStyle(fontSize: 11, color: AppTheme.textPrimary(brightness)),
                      overflow: TextOverflow.ellipsis)),
                  Text('$pct%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(brightness))),
                ]),
              );
            }),
          ),
        ),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget Alerts
// ─────────────────────────────────────────────────────────────────────────────

class _AlertsSection extends StatelessWidget {
  final List<Budget> budgets;
  const _AlertsSection({required this.budgets});

  List<_Alert> _buildAlerts() {
    final alerts = <_Alert>[];
    for (final b in budgets) {
      final pct = b.utilization * 100;
      if (b.spent > b.allocated) {
        alerts.add(_Alert(icon: Icons.warning_amber_rounded, color: AppColors.danger,
            text: '"${b.name}" has exceeded its allocated budget by ${_etb(b.spent - b.allocated)}.'));
      } else if (pct >= 85) {
        alerts.add(_Alert(icon: Icons.info_outline, color: AppColors.warning,
            text: '"${b.name}" is ${pct.toStringAsFixed(0)}% utilized — approaching its limit.'));
      } else if (pct < 20 && b.status == AppConstants.statusActive) {
        alerts.add(_Alert(icon: Icons.lightbulb_outline, color: AppColors.info,
            text: '"${b.name}" is underutilized at ${pct.toStringAsFixed(0)}% — consider reallocation.'));
      }
    }
    return alerts;
  }

  Color _alertBg(Color color, Brightness brightness) {
    if (color == AppColors.danger) return AppTheme.dangerBg(brightness);
    if (color == AppColors.warning) return AppTheme.warningBg(brightness);
    return AppTheme.infoBg(brightness);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final alerts = _buildAlerts();
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(color: AppTheme.cardColor(brightness),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: AppTheme.border(brightness))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Text('Budget Alerts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(brightness))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.warningBg(brightness), borderRadius: BorderRadius.circular(20)),
            child: Text('${alerts.length}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
          ),
        ]),
        const SizedBox(height: 12),
        ...alerts.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: _alertBg(a.color, brightness),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            child: Row(children: [
              Icon(a.icon, color: a.color, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(a.text, style: TextStyle(fontSize: 13, color: a.color))),
            ]),
          ),
        )),
      ]),
    );
  }
}

class _Alert {
  final IconData icon;
  final Color color;
  final String text;
  const _Alert({required this.icon, required this.color, required this.text});
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget Table Section
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetTableSection extends StatelessWidget {
  final List<Budget> items, allFiltered;
  final String searchQuery, categoryFilter, statusFilter;
  final int currentPage, pageCount;
  final List<String> categories, statusOptions;
  final ValueChanged<String> onSearchChanged, onCategoryChanged, onStatusChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Budget> onEdit, onDelete, onView;

  const _BudgetTableSection({
    required this.items, required this.allFiltered,
    required this.searchQuery, required this.categoryFilter, required this.statusFilter,
    required this.currentPage, required this.pageCount,
    required this.categories, required this.statusOptions,
    required this.onSearchChanged, required this.onCategoryChanged, required this.onStatusChanged,
    required this.onPageChanged, required this.onEdit, required this.onDelete, required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(color: AppTheme.cardColor(brightness),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: AppTheme.border(brightness))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Budget Entries', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(brightness))),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (_, bc) {
          final narrow = bc.maxWidth < 600;
          final searchField = SizedBox(
            height: 38,
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness)),
              decoration: InputDecoration(
                hintText: 'Search budgets…',
                hintStyle: TextStyle(fontSize: 13, color: AppTheme.textSecondary(brightness)),
                prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.iconColor(brightness)),
                filled: true, fillColor: AppTheme.inputFill(brightness),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    borderSide: BorderSide(color: AppTheme.border(brightness))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    borderSide: BorderSide(color: AppTheme.border(brightness))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          );
          final catDd = _FilterDropdown(value: categoryFilter, items: categories,
              onChanged: onCategoryChanged, hint: 'Category');
          final statDd = _FilterDropdown(value: statusFilter, items: statusOptions,
              onChanged: onStatusChanged, hint: 'Status');
          if (narrow) {
            return Column(children: [searchField, const SizedBox(height: 8),
              Row(children: [Expanded(child: catDd), const SizedBox(width: 8), Expanded(child: statDd)])]);
          }
          return Row(children: [Expanded(flex: 3, child: searchField), const SizedBox(width: 8),
            SizedBox(width: 150, child: catDd), const SizedBox(width: 8), SizedBox(width: 130, child: statDd)]);
        }),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (_, bc) {
          if (bc.maxWidth < 700) {
            if (items.isEmpty) { return _EmptyState(icon: Icons.account_balance_wallet_outlined,
                message: 'No budget entries found', hint: 'Add a budget or clear your filters.'); }
            return Column(children: items.map((b) => _BudgetCard(budget: b,
                onEdit: onEdit, onDelete: onDelete, onView: onView)).toList());
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (items.isEmpty)
              _EmptyState(icon: Icons.account_balance_wallet_outlined,
                  message: 'No budget entries found', hint: 'Add a budget or clear your filters.')
            else
              SizedBox(width: double.infinity,
                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 40, dataRowMinHeight: 52, dataRowMaxHeight: 72, columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(AppTheme.tableHeaderColor(brightness)),
                    border: TableBorder(horizontalInside: BorderSide(color: AppTheme.divider(brightness), width: 1)),
                    columns: [
                      DataColumn(label: _ColHeader('Category / Name')),
                      DataColumn(label: _ColHeader('Allocated')),
                      DataColumn(label: _ColHeader('Spent')),
                      DataColumn(label: _ColHeader('Remaining')),
                      DataColumn(label: _ColHeader('Utilization')),
                      DataColumn(label: _ColHeader('Status')),
                      DataColumn(label: _ColHeader('Last Updated')),
                      DataColumn(label: _ColHeader('Actions')),
                    ],
                    rows: items.map((b) => _budgetRow(b, onEdit, onDelete, onView, brightness)).toList(),
                  ),
                ),
              ),
          ]);
        }),
        const SizedBox(height: 12),
        Row(children: [
          Text('${allFiltered.length} entries',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(brightness))),
          const Spacer(),
          Flexible(child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(pageCount, (i) => i + 1).map((p) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                onTap: () => onPageChanged(p),
                child: Container(
                  width: 32, height: 32, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p == currentPage ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(color: p == currentPage ? AppColors.primary : AppTheme.border(brightness)),
                  ),
                  child: Text('$p', style: TextStyle(fontSize: 12,
                      color: p == currentPage ? Colors.white : AppTheme.textPrimary(brightness),
                      fontWeight: FontWeight.w500)),
                ),
              ),
            )).toList()),
          )),
        ]),
      ]),
    );
  }
}

DataRow _budgetRow(Budget b, ValueChanged<Budget> onEdit,
    ValueChanged<Budget> onDelete, ValueChanged<Budget> onView, Brightness brightness) {
  return DataRow(cells: [
    DataCell(Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(b.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary(brightness)), overflow: TextOverflow.ellipsis),
      Text(b.category, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))),
    ])),
    DataCell(Text(_etb(b.allocated), style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness)))),
    DataCell(Text(_etb(b.spent), style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness)))),
    DataCell(Text(_etb(b.remaining), style: TextStyle(fontSize: 13,
        color: b.remaining <= 0 ? AppColors.danger : AppTheme.textPrimary(brightness)))),
    DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('${(b.utilization * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: b.utilizationColor)),
      const SizedBox(height: 4),
      SizedBox(width: 80, child: ClipRRect(borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: b.utilization, minHeight: 4,
              backgroundColor: AppTheme.border(brightness),
              valueColor: AlwaysStoppedAnimation<Color>(b.utilizationColor)))),
    ])),
    DataCell(_StatusBadge(status: b.utilizationStatus, color: b.utilizationColor)),
    DataCell(Text('${b.lastUpdated.day}/${b.lastUpdated.month}/${b.lastUpdated.year}',
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(brightness)))),
    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
      _TableActionButton(icon: Icons.visibility_outlined, tooltip: 'View', onTap: () => onView(b)),
      const SizedBox(width: 4),
      _TableActionButton(icon: Icons.edit_outlined, tooltip: 'Edit', onTap: () => onEdit(b)),
      const SizedBox(width: 4),
      _TableActionButton(icon: Icons.delete_outline, tooltip: 'Delete',
          onTap: () => onDelete(b), color: AppColors.danger),
    ])),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget Card (mobile)
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final ValueChanged<Budget> onEdit, onDelete, onView;
  const _BudgetCard({required this.budget, required this.onEdit,
      required this.onDelete, required this.onView});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final b = budget;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundFill(brightness),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppTheme.border(brightness)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(b.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(brightness)))),
          _StatusBadge(status: b.utilizationStatus, color: b.utilizationColor),
        ]),
        const SizedBox(height: 4),
        Text(b.category, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))),
        const SizedBox(height: 10),
        Row(children: [
          _MiniStat('Allocated', _etb(b.allocated)),
          const SizedBox(width: 16),
          _MiniStat('Spent', _etb(b.spent)),
          const SizedBox(width: 16),
          _MiniStat('Remaining', _etb(b.remaining)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: b.utilization, minHeight: 5,
                backgroundColor: AppTheme.border(brightness),
                valueColor: AlwaysStoppedAnimation<Color>(b.utilizationColor))),
        const SizedBox(height: 8),
        Row(children: [
          Text('${(b.utilization * 100).toStringAsFixed(0)}% utilized',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: b.utilizationColor)),
          const Spacer(),
          _TableActionButton(icon: Icons.visibility_outlined, tooltip: 'View', onTap: () => onView(b)),
          const SizedBox(width: 4),
          _TableActionButton(icon: Icons.edit_outlined, tooltip: 'Edit', onTap: () => onEdit(b)),
          const SizedBox(width: 4),
          _TableActionButton(icon: Icons.delete_outline, tooltip: 'Delete',
              onTap: () => onDelete(b), color: AppColors.danger),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(brightness))),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary(brightness))),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary(Theme.of(context).brightness)));
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );
}

class _TableActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  const _TableActionButton({required this.icon, required this.tooltip,
      required this.onTap, this.color = AppColors.textSecondary});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 17, color: color)),
    ),
  );
}

Widget _formLabel(String text, Brightness brightness) => Text(text,
    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary(brightness)));

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(brightness))),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message, hint;
  const _EmptyState({required this.icon, required this.message, required this.hint});
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(children: [
        Icon(icon, size: 40, color: AppTheme.textSecondary(brightness).withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary(brightness))),
        const SizedBox(height: 4),
        Text(hint, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(brightness))),
      ]),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value, hint;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _FilterDropdown({required this.value, required this.items,
      required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      height: 38,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: AppTheme.surfaceColor(brightness),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppTheme.border(brightness))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppTheme.border(brightness))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          filled: true, fillColor: AppTheme.inputFill(brightness),
        ),
        style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness)),
        icon: Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.iconColor(brightness)),
        items: items.map((i) => DropdownMenuItem(value: i,
            child: Text(i, style: TextStyle(color: AppTheme.textPrimary(brightness))))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

class _DropdownInput extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownInput({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppTheme.surfaceColor(brightness),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: AppTheme.border(brightness))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: AppTheme.border(brightness))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        filled: true, fillColor: AppTheme.inputFill(brightness),
      ),
      style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness)),
      icon: Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.iconColor(brightness)),
      items: items.map((i) => DropdownMenuItem(value: i,
          child: Text(i, style: TextStyle(color: AppTheme.textPrimary(brightness))))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickerButton({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        height: 46, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(brightness)),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          color: AppTheme.inputFill(brightness),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('${date.day}/${date.month}/${date.year}',
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness))),
        ]),
      ),
    );
  }
}

TextStyle _inputStyle(Brightness brightness) =>
    TextStyle(fontSize: 13, color: AppTheme.textPrimary(brightness));

InputDecoration _inputDec(String hint, Brightness brightness) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(fontSize: 13, color: AppTheme.textSecondary(brightness)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      borderSide: BorderSide(color: AppTheme.border(brightness))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      borderSide: BorderSide(color: AppTheme.border(brightness))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  filled: true, fillColor: AppTheme.inputFill(brightness),
);

String _etb(double value) {
  if (value >= 1000000) return 'ETB ${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) {
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return 'ETB $formatted';
  }
  return 'ETB ${value.toStringAsFixed(0)}';
}
