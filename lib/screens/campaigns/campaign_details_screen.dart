import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/campaign.dart';
import '../../widgets/campaign/campaign_status_badge.dart';

/// Campaign details screen.
/// Receives the campaign id via route arguments.
class CampaignDetailsScreen extends StatelessWidget {
  final String campaignId;

  const CampaignDetailsScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final campaign = CampaignRepository.findById(campaignId);

    if (campaign == null) {
      return Center(
        child: Text('Campaign not found.',
            style: TextStyle(color: AppTheme.textSecondary(Theme.of(context).brightness))),
      );
    }

    return _CampaignDetailBody(campaign: campaign);
  }
}

class _CampaignDetailBody extends StatelessWidget {
  final Campaign campaign;
  const _CampaignDetailBody({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailHeader(campaign: campaign),
        const SizedBox(height: AppConstants.sectionSpacing),

        _KpiRow(campaign: campaign),
        const SizedBox(height: AppConstants.sectionSpacing),

        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _OverviewCard(campaign: campaign)),
              const SizedBox(width: AppConstants.itemSpacing),
              Expanded(flex: 2, child: _BudgetCard(campaign: campaign)),
            ],
          )
        else ...[
          _OverviewCard(campaign: campaign),
          const SizedBox(height: AppConstants.itemSpacing),
          _BudgetCard(campaign: campaign),
        ],

        const SizedBox(height: AppConstants.itemSpacing),

        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ActivityCard(campaign: campaign)),
              const SizedBox(width: AppConstants.itemSpacing),
              Expanded(child: _CouponsCard(campaign: campaign)),
            ],
          )
        else ...[
          _ActivityCard(campaign: campaign),
          const SizedBox(height: AppConstants.itemSpacing),
          _CouponsCard(campaign: campaign),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  final Campaign campaign;
  const _DetailHeader({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.campaigns),
              child: const Text('Campaigns',
                  style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
            Text(' / ',
                style: TextStyle(color: AppTheme.textSecondary(brightness), fontSize: 13)),
            Text(campaign.name,
                style: TextStyle(
                    color: AppTheme.textSecondary(brightness), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campaign.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('ID: ${campaign.id}  •  ',
                          style: TextStyle(
                              color: AppTheme.textSecondary(brightness), fontSize: 12)),
                      Text(campaign.objective.label,
                          style: TextStyle(
                              color: AppTheme.textSecondary(brightness), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            CampaignStatusBadge(status: campaign.status),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushNamed(AppRoutes.campaignEdit, arguments: campaign.id),
              icon: const Icon(Icons.edit_outlined, size: 15),
              label: const Text('Edit Campaign'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI row
// ─────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final Campaign campaign;
  const _KpiRow({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 700 ? 4 : 2;
        final itemW = (constraints.maxWidth - (cols - 1) * AppConstants.itemSpacing) / cols;
        final stats = [
          _KpiData('Impressions', _fmt(campaign.impressions), Icons.visibility_outlined, AppColors.primary),
          _KpiData('Leads', _fmt(campaign.leads), Icons.person_search_outlined, AppColors.info),
          _KpiData('Conversions', _fmt(campaign.conversions), Icons.check_circle_outline, AppColors.success),
          _KpiData('ROI', '${campaign.roi}×', Icons.trending_up_outlined, AppColors.warning),
        ];
        return Wrap(
          spacing: AppConstants.itemSpacing,
          runSpacing: AppConstants.itemSpacing,
          children: stats.map((s) => SizedBox(
            width: itemW,
            child: _KpiCard(data: s),
          )).toList(),
        );
      },
    );
  }

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value,
                  style: TextStyle(
                      color: AppTheme.textPrimary(brightness),
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              Text(data.label,
                  style: TextStyle(
                      color: AppTheme.textSecondary(brightness), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview card
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final Campaign campaign;
  const _OverviewCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Campaign Overview',
      child: Column(
        children: [
          _InfoRow('Description', campaign.description),
          _InfoRow('Objective', campaign.objective.label),
          _InfoRow('Status', campaign.status),
          _InfoRow('Start Date', campaign.startDate != null ? _fmtDate(campaign.startDate!) : '-'),
          _InfoRow('End Date', campaign.endDate != null ? _fmtDate(campaign.endDate!) : '-'),
          _InfoRow('Channels',
              campaign.channels.map((c) => c.label).join(', ')),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget card
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Campaign campaign;
  const _BudgetCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final pct = (campaign.budgetUtilization * 100).toStringAsFixed(1);
    final barColor = campaign.budgetUtilization > 0.9
        ? AppColors.danger
        : campaign.budgetUtilization > 0.7
            ? AppColors.warning
            : AppColors.success;

    return _SectionCard(
      title: 'Budget & Spending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BudgetStat('Total Budget',
              'ETB ${_num(campaign.budget)}', AppTheme.textPrimary(brightness)),
          const SizedBox(height: 8),
          _BudgetStat('Amount Spent',
              'ETB ${_num(campaign.spent)}', AppColors.danger),
          const SizedBox(height: 8),
          _BudgetStat('Remaining',
              'ETB ${_num(campaign.remaining)}', AppColors.success),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Utilization',
                  style: TextStyle(
                      color: AppTheme.textSecondary(brightness), fontSize: 12)),
              Text('$pct%',
                  style: TextStyle(
                      color: barColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: campaign.budgetUtilization,
              minHeight: 8,
              backgroundColor: AppTheme.border(brightness),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  String _num(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _BudgetStat(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: AppTheme.textSecondary(brightness), fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity timeline
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final Campaign campaign;
  const _ActivityCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _SectionCard(
      title: 'Activity Timeline',
      child: campaign.activities.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No activities recorded.',
                  style: TextStyle(color: AppTheme.textSecondary(brightness), fontSize: 13)),
            )
          : Column(
              children: campaign.activities.asMap().entries.map((e) {
                final isLast = e.key == campaign.activities.length - 1;
                return _ActivityTile(
                  activity: e.value,
                  showLine: !isLast,
                );
              }).toList(),
            ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final CampaignActivity activity;
  final bool showLine;
  const _ActivityTile({required this.activity, required this.showLine});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: activity.iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(activity.icon, size: 14, color: activity.iconColor),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppTheme.divider(brightness),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 16 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.description,
                      style: TextStyle(
                          color: AppTheme.textPrimary(brightness),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(activity.date,
                      style: TextStyle(
                          color: AppTheme.textSecondary(brightness), fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupons card
// ─────────────────────────────────────────────────────────────────────────────

class _CouponsCard extends StatelessWidget {
  final Campaign campaign;
  const _CouponsCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _SectionCard(
      title: 'Promotions & Coupons',
      child: campaign.coupons.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No coupons for this campaign.',
                  style: TextStyle(color: AppTheme.textSecondary(brightness), fontSize: 13)),
            )
          : Column(
              children: campaign.coupons.map((coupon) {
                final usagePct = coupon.usageLimit > 0
                    ? coupon.usedCount / coupon.usageLimit
                    : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundFill(brightness),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: AppTheme.border(brightness)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLighter(brightness),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusSmall),
                            ),
                            child: Text(coupon.code,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                          ),
                          const SizedBox(width: 8),
                          Text(coupon.discount,
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('Exp: ${coupon.expiryDate}',
                              style: TextStyle(
                                  color: AppTheme.textSecondary(brightness),
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${coupon.usedCount} / ${coupon.usageLimit} used',
                              style: TextStyle(
                                  color: AppTheme.textSecondary(brightness), fontSize: 11)),
                          Text(
                              '${(usagePct * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: usagePct > 0.9
                                      ? AppColors.danger
                                      : AppTheme.textSecondary(brightness),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: usagePct,
                          minHeight: 4,
                          backgroundColor: AppTheme.border(brightness),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usagePct > 0.9
                                ? AppColors.danger
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppTheme.divider(brightness)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic info row
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    color: AppTheme.textSecondary(brightness), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    color: AppTheme.textPrimary(brightness),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
