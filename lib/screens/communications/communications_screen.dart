import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local mutable message model
// ─────────────────────────────────────────────────────────────────────────────

class _CommItem {
  String id;
  String recipient;
  String channel;
  String subject;
  String message;
  DateTime date;
  String status;
  String engagement;
  String priority;

  _CommItem({
    required this.id,
    required this.recipient,
    required this.channel,
    required this.subject,
    required this.message,
    required this.date,
    required this.status,
    required this.engagement,
    required this.priority,
  });
}

// Seed data
final List<_CommItem> _seedMessages = [
  _CommItem(id: 'C001', recipient: 'All Subscribers (9,800)', channel: 'Email',
      subject: 'Newsletter #12 — May 2026',
      message: 'Monthly newsletter with product updates and tips for May 2026.',
      date: DateTime(2026, 5, 8, 9, 0), status: 'Delivered',
      engagement: '43% open rate', priority: 'Normal'),
  _CommItem(id: 'C002', recipient: 'Active Customers (8,200)', channel: 'SMS',
      subject: 'Summer Sale Flash Alert',
      message: 'Flash sale: Up to 30% off today only! Use code SUMMER30.',
      date: DateTime(2026, 5, 10, 10, 0), status: 'Delivered',
      engagement: '68% click rate', priority: 'High'),
  _CommItem(id: 'C003', recipient: 'App Users (15,400)', channel: 'Notification',
      subject: 'New Feature: Analytics Dashboard',
      message: 'Discover the new analytics dashboard in your MarketFlow app.',
      date: DateTime(2026, 5, 12, 14, 0), status: 'Sent',
      engagement: '40% open rate', priority: 'Normal'),
  _CommItem(id: 'C004', recipient: 'Recent Buyers (312)', channel: 'Email',
      subject: 'Your Order is Confirmed',
      message: 'Thank you for your purchase. Your order has been confirmed.',
      date: DateTime(2026, 5, 9, 11, 0), status: 'Delivered',
      engagement: '96% open rate', priority: 'High'),
  _CommItem(id: 'C005', recipient: 'Inactive Users (4,500)', channel: 'Email',
      subject: 'Re-engagement: We miss you!',
      message: 'We noticed you have been away. Here is a special offer just for you.',
      date: DateTime(2026, 4, 18, 9, 0), status: 'Scheduled',
      engagement: '27% open rate', priority: 'Low'),
  _CommItem(id: 'C006', recipient: 'Registered Users (320)', channel: 'Notification',
      subject: 'Webinar Reminder — June 5',
      message: 'Your webinar starts in 24 hours. Join us at 2PM EAT on June 5.',
      date: DateTime(2026, 6, 4, 8, 0), status: 'Draft',
      engagement: '—', priority: 'Normal'),
  _CommItem(id: 'C007', recipient: 'VIP Segment (245)', channel: 'Email',
      subject: 'Exclusive VIP Offer Inside',
      message: 'As a valued VIP member, enjoy 40% off your next purchase.',
      date: DateTime(2026, 5, 14, 10, 0), status: 'Sent',
      engagement: '81% open rate', priority: 'High'),
  _CommItem(id: 'C008', recipient: 'New Leads (128)', channel: 'SMS',
      subject: 'Welcome to MarketFlow',
      message: 'Welcome! Your account is ready. Reply STOP to opt out.',
      date: DateTime(2026, 5, 15, 8, 0), status: 'Failed',
      engagement: '—', priority: 'Normal'),
];

int _nextCommId = 9;

// ─────────────────────────────────────────────────────────────────────────────
// CommunicationsScreen
// ─────────────────────────────────────────────────────────────────────────────

class CommunicationsScreen extends StatefulWidget {
  const CommunicationsScreen({super.key});
  @override
  State<CommunicationsScreen> createState() => _CommunicationsScreenState();
}

class _CommunicationsScreenState extends State<CommunicationsScreen> {
  final List<_CommItem> _messages = List.from(_seedMessages);
  String _searchQuery = '';
  String _channelFilter = 'All';
  String _statusFilter = 'All';

  static const _channels = ['All', 'Email', 'SMS', 'Notification'];
  static const _statuses = ['All', 'Sent', 'Delivered', 'Scheduled', 'Failed', 'Draft'];

  List<_CommItem> get _filtered => _messages.where((m) {
    final q = _searchQuery.toLowerCase();
    final matchQ = q.isEmpty ||
        m.subject.toLowerCase().contains(q) ||
        m.recipient.toLowerCase().contains(q) ||
        m.channel.toLowerCase().contains(q);
    final matchC = _channelFilter == 'All' || m.channel == _channelFilter;
    final matchS = _statusFilter == 'All' || m.status == _statusFilter;
    return matchQ && matchC && matchS;
  }).toList();

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _openComposer({_CommItem? existing}) {
    final isEdit = existing != null;
    String channel = existing?.channel ?? 'Email';
    final recipientCtrl = TextEditingController(text: existing?.recipient ?? '');
    final subjectCtrl   = TextEditingController(text: existing?.subject ?? '');
    final messageCtrl   = TextEditingController(text: existing?.message ?? '');
    String priority = existing?.priority ?? 'Normal';
    String status   = existing?.status   ?? 'Draft';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final brightness = Theme.of(ctx).brightness;
        final dialogBg   = AppTheme.surfaceColor(brightness);
        final inputFill  = AppTheme.inputFill(brightness);
        final borderCol  = AppTheme.border(brightness);
        final textPri    = AppTheme.textPrimary(brightness);
        final textSec    = AppTheme.textSecondary(brightness);
        final dropBg     = AppTheme.surfaceColor(brightness);
        final headerBg   = brightness == Brightness.dark
            ? const Color(0xFF2A2650)
            : AppColors.primaryLight;

        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              side: BorderSide(color: AppTheme.border(brightness))),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Dialog header
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: headerBg,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                        child: Icon(isEdit ? Icons.edit_outlined : Icons.edit_note_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(isEdit ? 'Edit Message' : 'New Message',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: textPri)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: textSec, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ]),
                  ),

                  // Channel chips
                  _CommFormLabel('Channel', textPri),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: _channels
                      .where((c) => c != 'All')
                      .map((c) => ChoiceChip(
                            label: Text(c),
                            selected: channel == c,
                            onSelected: (_) => setLocal(() => channel = c),
                            selectedColor: brightness == Brightness.dark
                                ? const Color(0xFF2A2650)
                                : AppColors.primaryLight,
                            labelStyle: TextStyle(
                              color: channel == c ? AppColors.primary : textSec,
                              fontSize: 13, fontWeight: FontWeight.w500,
                            ),
                            backgroundColor: AppTheme.surfaceVariant(brightness),
                            side: BorderSide(
                                color: channel == c ? AppColors.primary : borderCol),
                          ))
                      .toList()),
                  const SizedBox(height: 14),

                  _CommFormLabel('Recipient *', textPri),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: recipientCtrl,
                    style: TextStyle(fontSize: 13, color: textPri),
                    decoration: _commInputDec('e.g. All Subscribers (9,800)',
                        inputFill, borderCol, textSec),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  _CommFormLabel('Subject *', textPri),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: subjectCtrl,
                    style: TextStyle(fontSize: 13, color: textPri),
                    decoration: _commInputDec('Message subject or title',
                        inputFill, borderCol, textSec),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  _CommFormLabel('Message *', textPri),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: messageCtrl,
                    style: TextStyle(fontSize: 13, color: textPri),
                    decoration: _commInputDec('Write your message here…',
                        inputFill, borderCol, textSec),
                    maxLines: 5,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Priority + Status
                  LayoutBuilder(builder: (_, bc) {
                    final narrow = bc.maxWidth < 400;
                    final priorityField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CommFormLabel('Priority', textPri),
                        const SizedBox(height: 6),
                        _CommDropdown(
                          value: priority,
                          items: const ['Low', 'Normal', 'High'],
                          onChanged: (v) => setLocal(() => priority = v),
                          fillColor: inputFill,
                          borderColor: borderCol,
                          dropColor: dropBg,
                          textColor: textPri,
                          iconColor: textSec,
                        ),
                      ],
                    );
                    final statusField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CommFormLabel('Status', textPri),
                        const SizedBox(height: 6),
                        _CommDropdown(
                          value: status,
                          items: _statuses.where((s) => s != 'All').toList(),
                          onChanged: (v) => setLocal(() => status = v),
                          fillColor: inputFill,
                          borderColor: borderCol,
                          dropColor: dropBg,
                          textColor: textPri,
                          iconColor: textSec,
                        ),
                      ],
                    );
                    if (narrow) {
                      return Column(children: [
                        priorityField, const SizedBox(height: 14), statusField,
                      ]);
                    }
                    return Row(children: [
                      Expanded(child: priorityField),
                      const SizedBox(width: 12),
                      Expanded(child: statusField),
                    ]);
                  }),
                  const SizedBox(height: 24),

                  // Action buttons
                  LayoutBuilder(builder: (_, bc) {
                    void save(String saveStatus) {
                      if (!formKey.currentState!.validate()) return;
                      final item = _CommItem(
                        id: isEdit
                            ? existing.id
                            : 'C${(_nextCommId++).toString().padLeft(3, '0')}',
                        recipient: recipientCtrl.text.trim(),
                        channel: channel,
                        subject: subjectCtrl.text.trim(),
                        message: messageCtrl.text.trim(),
                        date: DateTime.now(),
                        status: saveStatus,
                        engagement: '—',
                        priority: priority,
                      );
                      setState(() {
                        if (isEdit) {
                          final idx = _messages.indexWhere((m) => m.id == item.id);
                          if (idx != -1) _messages[idx] = item;
                        } else {
                          _messages.add(item);
                        }
                      });
                      Navigator.pop(ctx);
                      _showSnack(saveStatus == 'Draft'
                          ? 'Draft saved.'
                          : saveStatus == 'Scheduled'
                              ? 'Message scheduled.'
                              : 'Message sent.');
                    }

                    return Wrap(spacing: 8, runSpacing: 8, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      OutlinedButton.icon(
                        onPressed: () => save('Draft'),
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Save Draft'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => save('Scheduled'),
                        icon: const Icon(Icons.schedule_outlined, size: 16),
                        label: const Text('Schedule'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => save('Sent'),
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const Text('Send'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white),
                      ),
                    ]);
                  }),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _confirmDelete(_CommItem m) {
    showDialog(
      context: context,
      builder: (ctx) {
        final brightness = Theme.of(ctx).brightness;
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor(brightness),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              side: BorderSide(color: AppTheme.border(brightness))),
          title: const Text('Delete Message',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          content: Text('Delete "${m.subject}"?',
              style: TextStyle(color: AppTheme.textSecondary(brightness))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white),
              onPressed: () {
                setState(() => _messages.removeWhere((item) => item.id == m.id));
                Navigator.pop(ctx);
                _showSnack('Message deleted.');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final filtered = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Plain sticky header (no SliverPersistentHeader) ───────────────
        _CommHeaderSurface(
          brightness: brightness,
          onNewMessage: () => _openComposer(),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Stats
              _CommStatsRow(messages: _messages),
              const SizedBox(height: AppConstants.sectionSpacing),

              // Filters + table
              _CommTableSection(
                items: filtered,
                searchQuery: _searchQuery,
                channelFilter: _channelFilter,
                statusFilter: _statusFilter,
                channels: _channels,
                statuses: _statuses,
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                onChannelChanged: (v) => setState(() => _channelFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onEdit: (m) => _openComposer(existing: m),
                onDelete: _confirmDelete,
                onResend: (m) {
                  setState(() {
                    final idx = _messages.indexWhere((item) => item.id == m.id);
                    if (idx != -1) _messages[idx].status = 'Sent';
                  });
                  _showSnack('Message resent.');
                },
              ),
              const SizedBox(height: AppConstants.sectionSpacing),

              // Activity timeline
              _ActivityTimeline(messages: _messages),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CommHeaderSurface — replaces _CommHeaderDelegate + SliverPersistentHeader
// Plain StatelessWidget; no sliver geometry constraints.
// ─────────────────────────────────────────────────────────────────────────────

class _CommHeaderSurface extends StatelessWidget {
  final VoidCallback onNewMessage;
  final Brightness brightness;

  const _CommHeaderSurface({
    required this.onNewMessage,
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
          child: _CommPageHeader(onNewMessage: onNewMessage),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Header
// ─────────────────────────────────────────────────────────────────────────────

class _CommPageHeader extends StatelessWidget {
  final VoidCallback onNewMessage;
  const _CommPageHeader({required this.onNewMessage});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textSec    = AppTheme.textSecondary(brightness);

    return LayoutBuilder(builder: (_, constraints) {
      final narrow = constraints.maxWidth < 600;

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
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Communications',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                'Manage conversations and marketing communication activities from one place.',
                style: TextStyle(color: textSec, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      );

      final actions = ElevatedButton.icon(
        onPressed: onNewMessage,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('New Message'),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      );

      if (narrow) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock,
            const SizedBox(height: 8),
            actions,
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
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _CommStatsRow extends StatelessWidget {
  final List<_CommItem> messages;
  const _CommStatsRow({required this.messages});

  @override
  Widget build(BuildContext context) {
    final brightness  = Theme.of(context).brightness;
    final sent        = messages.where((m) => m.status == 'Sent' || m.status == 'Delivered').length;
    final emails      = messages.where((m) => m.channel == 'Email').length;
    final sms         = messages.where((m) => m.channel == 'SMS').length;
    final delivered   = messages.where((m) => m.status == 'Delivered').length;
    final responsePct = messages.isEmpty ? 0.0 : delivered / messages.length * 100;

    final cards = [
      _CommStatCard(label: 'Messages Sent',   value: '$sent',
          icon: Icons.send_outlined,      iconColor: AppColors.primary,
          iconBg: AppTheme.primaryLighter(brightness)),
      _CommStatCard(label: 'Email Campaigns', value: '$emails',
          icon: Icons.email_outlined,     iconColor: AppColors.info,
          iconBg: AppTheme.infoBg(brightness)),
      _CommStatCard(label: 'SMS Sent',        value: '$sms',
          icon: Icons.sms_outlined,       iconColor: AppColors.warning,
          iconBg: AppTheme.warningBg(brightness)),
      _CommStatCard(label: 'Response Rate',   value: '${responsePct.toStringAsFixed(0)}%',
          icon: Icons.bar_chart_outlined, iconColor: AppColors.success,
          iconBg: AppTheme.successBg(brightness)),
    ];

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final cols = w >= 900 ? 4 : w >= 600 ? 2 : 1;
      final cardWidth = (w - (cols - 1) * AppConstants.itemSpacing) / cols;
      return Wrap(
        spacing: AppConstants.itemSpacing,
        runSpacing: AppConstants.itemSpacing,
        children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
      );
    });
  }
}

class _CommStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _CommStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

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
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(brightness))),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(brightness))),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Communications Table Section
// ─────────────────────────────────────────────────────────────────────────────

class _CommTableSection extends StatelessWidget {
  final List<_CommItem> items;
  final String searchQuery;
  final String channelFilter;
  final String statusFilter;
  final List<String> channels;
  final List<String> statuses;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onChannelChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<_CommItem> onEdit;
  final ValueChanged<_CommItem> onDelete;
  final ValueChanged<_CommItem> onResend;

  const _CommTableSection({
    required this.items,
    required this.searchQuery,
    required this.channelFilter,
    required this.statusFilter,
    required this.channels,
    required this.statuses,
    required this.onSearchChanged,
    required this.onChannelChanged,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardBg     = AppTheme.cardColor(brightness);
    final borderCol  = AppTheme.border(brightness);
    final textPri    = AppTheme.textPrimary(brightness);
    final textSec    = AppTheme.textSecondary(brightness);
    final inputFill  = AppTheme.inputFill(brightness);
    final headerBg   = AppTheme.tableHeaderColor(brightness);
    final dividerCol = AppTheme.divider(brightness);

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderCol),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recent Communications',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textPri)),
        const SizedBox(height: 12),

        // Filters
        LayoutBuilder(builder: (_, bc) {
          final narrow = bc.maxWidth < 560;
          final searchField = SizedBox(
            height: 38,
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(fontSize: 13, color: textPri),
              decoration: InputDecoration(
                hintText: 'Search messages…',
                hintStyle: TextStyle(fontSize: 13, color: textSec),
                prefixIcon: Icon(Icons.search, size: 18, color: textSec),
                filled: true,
                fillColor: inputFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    borderSide: BorderSide(color: borderCol)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    borderSide: BorderSide(color: borderCol)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          );
          final chanFilter = _CommFilterDrop(
              value: channelFilter, items: channels,
              onChanged: onChannelChanged, hint: 'Channel',
              fillColor: inputFill, borderColor: borderCol,
              dropColor: cardBg, textColor: textPri, iconColor: textSec);
          final statFilter = _CommFilterDrop(
              value: statusFilter, items: statuses,
              onChanged: onStatusChanged, hint: 'Status',
              fillColor: inputFill, borderColor: borderCol,
              dropColor: cardBg, textColor: textPri, iconColor: textSec);

          if (narrow) {
            return Column(children: [
              searchField, const SizedBox(height: 8),
              Row(children: [
                Expanded(child: chanFilter),
                const SizedBox(width: 8),
                Expanded(child: statFilter),
              ]),
            ]);
          }
          return Row(children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 8),
            SizedBox(width: 130, child: chanFilter),
            const SizedBox(width: 8),
            SizedBox(width: 130, child: statFilter),
          ]);
        }),
        const SizedBox(height: 12),

        // Table / cards
        LayoutBuilder(builder: (_, bc) {
          if (items.isEmpty) return _CommEmptyState();
          if (bc.maxWidth < 700) {
            return Column(
              children: items
                  .map((m) => _CommCard(
                        item: m,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onResend: onResend,
                      ))
                  .toList(),
            );
          }
          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 64,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(headerBg),
                border: TableBorder(
                  horizontalInside: BorderSide(color: dividerCol, width: 1),
                ),
                columns: [
                  DataColumn(label: _CommColHeader('Recipient', textSec)),
                  DataColumn(label: _CommColHeader('Channel', textSec)),
                  DataColumn(label: _CommColHeader('Subject', textSec)),
                  DataColumn(label: _CommColHeader('Date', textSec)),
                  DataColumn(label: _CommColHeader('Status', textSec)),
                  DataColumn(label: _CommColHeader('Engagement', textSec)),
                  DataColumn(label: _CommColHeader('Actions', textSec)),
                ],
                rows: items
                    .map((m) => _commRow(m, textPri, textSec, onEdit, onDelete, onResend))
                    .toList(),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

DataRow _commRow(
  _CommItem m,
  Color textPri,
  Color textSec,
  ValueChanged<_CommItem> onEdit,
  ValueChanged<_CommItem> onDelete,
  ValueChanged<_CommItem> onResend,
) {
  return DataRow(cells: [
    DataCell(ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Text(m.recipient,
          style: TextStyle(fontSize: 12, color: textPri),
          overflow: TextOverflow.ellipsis),
    )),
    DataCell(_ChannelBadge(channel: m.channel)),
    DataCell(ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Text(m.subject,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPri),
          overflow: TextOverflow.ellipsis),
    )),
    DataCell(Text(
        '${m.date.day}/${m.date.month}/${m.date.year}',
        style: TextStyle(fontSize: 12, color: textSec))),
    DataCell(_CommStatusBadge(status: m.status)),
    DataCell(Text(m.engagement,
        style: TextStyle(fontSize: 12, color: textSec))),
    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
      _CommActionBtn(icon: Icons.edit_outlined,    tooltip: 'Edit',   onTap: () => onEdit(m)),
      const SizedBox(width: 4),
      _CommActionBtn(icon: Icons.refresh_outlined, tooltip: 'Resend', onTap: () => onResend(m)),
      const SizedBox(width: 4),
      _CommActionBtn(icon: Icons.delete_outline,   tooltip: 'Delete', onTap: () => onDelete(m),
          color: AppColors.danger),
    ])),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity Timeline
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityTimeline extends StatelessWidget {
  final List<_CommItem> messages;
  const _ActivityTimeline({required this.messages});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardBg     = AppTheme.cardColor(brightness);
    final borderCol  = AppTheme.border(brightness);
    final textPri    = AppTheme.textPrimary(brightness);
    final textSec    = AppTheme.textSecondary(brightness);
    final dividerCol = AppTheme.divider(brightness);
    final recent     = messages.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderCol),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.timeline_outlined, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text('Recent Activity',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPri)),
        ]),
        const SizedBox(height: 16),
        ...List.generate(recent.length, (i) {
          final m      = recent[i];
          final isLast = i == recent.length - 1;
          return IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: _commStatusColor(m.status),
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBg, width: 2),
                    boxShadow: [BoxShadow(
                      color: _commStatusColor(m.status).withValues(alpha: 0.3),
                      blurRadius: 4,
                    )],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: dividerCol,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      _ChannelBadge(channel: m.channel),
                      const Spacer(),
                      Text(
                        '${m.date.day}/${m.date.month} '
                        '${m.date.hour.toString().padLeft(2, '0')}:'
                        '${m.date.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11, color: textSec),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(m.subject,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textPri),
                        overflow: TextOverflow.ellipsis),
                    Text('To: ${m.recipient} — ${m.status}',
                        style: TextStyle(fontSize: 11, color: textSec)),
                  ]),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared comm helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _commStatusColor(String status) {
  switch (status) {
    case 'Delivered': return AppColors.success;
    case 'Sent':      return AppColors.info;
    case 'Scheduled': return AppColors.warning;
    case 'Failed':    return AppColors.danger;
    case 'Draft':     return AppColors.textSecondary;
    default:          return AppColors.textSecondary;
  }
}

class _ChannelBadge extends StatelessWidget {
  final String channel;
  const _ChannelBadge({required this.channel});

  Color get _color {
    switch (channel) {
      case 'Email':        return AppColors.primary;
      case 'SMS':          return AppColors.warning;
      case 'Notification': return AppColors.info;
      default:             return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (channel) {
      case 'Email':        return Icons.email_outlined;
      case 'SMS':          return Icons.sms_outlined;
      case 'Notification': return Icons.notifications_outlined;
      default:             return Icons.message_outlined;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(_icon, size: 12, color: _color),
      const SizedBox(width: 4),
      Text(channel,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
    ]),
  );
}

class _CommStatusBadge extends StatelessWidget {
  final String status;
  const _CommStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _commStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _CommCard extends StatelessWidget {
  final _CommItem item;
  final ValueChanged<_CommItem> onEdit;
  final ValueChanged<_CommItem> onDelete;
  final ValueChanged<_CommItem> onResend;

  const _CommCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cardBg     = AppTheme.surfaceVariant(brightness);
    final borderCol  = AppTheme.border(brightness);
    final textPri    = AppTheme.textPrimary(brightness);
    final textSec    = AppTheme.textSecondary(brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: borderCol),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _ChannelBadge(channel: item.channel),
          const Spacer(),
          _CommStatusBadge(status: item.status),
        ]),
        const SizedBox(height: 8),
        Text(item.subject,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPri),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(item.recipient,
            style: TextStyle(fontSize: 11, color: textSec),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Row(children: [
          Text('${item.date.day}/${item.date.month}/${item.date.year}',
              style: TextStyle(fontSize: 11, color: textSec)),
          const Spacer(),
          Text(item.engagement,
              style: TextStyle(fontSize: 11, color: textSec)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Spacer(),
          _CommActionBtn(
              icon: Icons.edit_outlined, tooltip: 'Edit',
              onTap: () => onEdit(item)),
          const SizedBox(width: 4),
          _CommActionBtn(
              icon: Icons.refresh_outlined, tooltip: 'Resend',
              onTap: () => onResend(item)),
          const SizedBox(width: 4),
          _CommActionBtn(
              icon: Icons.delete_outline, tooltip: 'Delete',
              onTap: () => onDelete(item), color: AppColors.danger),
        ]),
      ]),
    );
  }
}

class _CommEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textSec    = AppTheme.textSecondary(brightness);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(children: [
        Icon(Icons.chat_bubble_outline, size: 40,
            color: textSec.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Text('No messages found',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSec)),
        const SizedBox(height: 4),
        Text('Try a different search or filter.',
            style: TextStyle(fontSize: 12, color: textSec)),
      ]),
    );
  }
}

class _CommColHeader extends StatelessWidget {
  final String text;
  final Color color;
  const _CommColHeader(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: color));
}

class _CommFilterDrop extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String hint;
  final Color fillColor;
  final Color borderColor;
  final Color dropColor;
  final Color textColor;
  final Color iconColor;

  const _CommFilterDrop({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.fillColor,
    required this.borderColor,
    required this.dropColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: dropColor,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        filled: true,
        fillColor: fillColor,
      ),
      style: TextStyle(fontSize: 13, color: textColor),
      icon: Icon(Icons.keyboard_arrow_down, size: 18, color: iconColor),
      items: items
          .map((i) => DropdownMenuItem(
                value: i,
                child: Text(i, style: TextStyle(color: textColor)),
              ))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    ),
  );
}

class _CommActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _CommActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final iconCol    = color == AppColors.textSecondary
        ? AppTheme.iconColor(brightness)
        : color;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 17, color: iconCol),
        ),
      ),
    );
  }
}

class _CommFormLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _CommFormLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: color));
}

class _CommDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Color fillColor;
  final Color borderColor;
  final Color dropColor;
  final Color textColor;
  final Color iconColor;

  const _CommDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.fillColor,
    required this.borderColor,
    required this.dropColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    dropdownColor: dropColor,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      filled: true,
      fillColor: fillColor,
    ),
    style: TextStyle(fontSize: 13, color: textColor),
    icon: Icon(Icons.keyboard_arrow_down, size: 18, color: iconColor),
    items: items
        .map((i) => DropdownMenuItem(
              value: i,
              child: Text(i, style: TextStyle(color: textColor)),
            ))
        .toList(),
    onChanged: (v) { if (v != null) onChanged(v); },
  );
}

InputDecoration _commInputDec(
  String hint,
  Color fillColor,
  Color borderColor,
  Color hintColor,
) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: hintColor),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      filled: true,
      fillColor: fillColor,
    );
