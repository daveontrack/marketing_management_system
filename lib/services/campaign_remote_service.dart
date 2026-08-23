import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import '../models/campaign.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CampaignRemoteService
//
// Thin data-access layer between CampaignRepository and Supabase.
//
//   CampaignRepository (sync, in-memory)  ← UI keeps working unchanged
//            │  fire-and-forget writes / awaited initial load
//            ▼
//   CampaignRemoteService (async)  ← this file
//            ▼
//   Supabase table `campaigns`
//
// Every method fails soft: when Supabase is not configured or unreachable
// the calls return null/false instead of throwing, so the app degrades to
// local-only mode automatically.
// ─────────────────────────────────────────────────────────────────────────────

class CampaignRemoteService {
  CampaignRemoteService._();

  static const String _table = 'campaigns';

  /// Returns null when the backend is unavailable (not configured / offline /
  /// error). Returns an empty list when the table exists but has no rows.
  static Future<List<Campaign>?> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      final rows = await Supabase.instance.client
          .from(_table)
          .select()
          .order('id', ascending: true)
          .timeout(const Duration(seconds: 6));
      return rows.map<Campaign>(_fromRow).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> upsert(Campaign c) async {
    if (!SupabaseConfig.isConfigured) return false;
    try {
      await Supabase.instance.client
          .from(_table)
          .upsert(_toRow(c))
          .timeout(const Duration(seconds: 6));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> delete(String id) async {
    if (!SupabaseConfig.isConfigured) return false;
    try {
      await Supabase.instance.client
          .from(_table)
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 6));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Inserts the given campaigns in one batch. Used on first run when the
  /// remote table is empty so the database starts out with sample content.
  static Future<bool> seed(List<Campaign> campaigns) async {
    if (!SupabaseConfig.isConfigured || campaigns.isEmpty) return false;
    try {
      await Supabase.instance.client
          .from(_table)
          .upsert(campaigns.map(_toRow).toList())
          .timeout(const Duration(seconds: 8));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Row mapping ────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toRow(Campaign c) => {
        'id': c.id,
        'name': c.name,
        'description': c.description,
        'target_audience': c.targetAudience,
        'notes': c.notes,
        'objective': c.objective.name,
        'channels': c.channels.map((ch) => ch.name).toList(),
        'status': c.status,
        'start_date': _dateToDb(c.startDate),
        'end_date': _dateToDb(c.endDate),
        'budget': c.budget,
        'spent': c.spent,
        'leads': c.leads,
        'conversions': c.conversions,
        'impressions': c.impressions,
        'roi': c.roi,
        'activities': c.activities.map(_activityToJson).toList(),
        'coupons': c.coupons.map(_couponToJson).toList(),
      };

  static Campaign _fromRow(Map<String, dynamic> row) {
    return Campaign(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      targetAudience: row['target_audience']?.toString() ?? '',
      notes: row['notes']?.toString() ?? '',
      objective: _objectiveFromDb(row['objective']),
      channels: ((row['channels'] as List?) ?? const [])
          .map((ch) => _channelFromDb(ch.toString()))
          .toList(),
      status: row['status']?.toString() ?? AppConstants.statusDraft,
      startDate: _dateFromDb(row['start_date']),
      endDate: _dateFromDb(row['end_date']),
      budget: _toDouble(row['budget']),
      spent: _toDouble(row['spent']),
      leads: _toInt(row['leads']),
      conversions: _toInt(row['conversions']),
      impressions: _toInt(row['impressions']),
      roi: _toDouble(row['roi']),
      activities: ((row['activities'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_activityFromJson)
          .toList(),
      coupons: ((row['coupons'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_couponFromJson)
          .toList(),
    );
  }

  // ── Enum helpers ──────────────────────────────────────────────────────────

  static CampaignChannel _channelFromDb(String value) {
    for (final ch in CampaignChannel.values) {
      if (ch.name == value) return ch;
    }
    // Tolerate human-readable labels ('Social Media') written by hand in SQL.
    for (final ch in CampaignChannel.values) {
      if (ch.label.toLowerCase() == value.toLowerCase()) return ch;
    }
    return CampaignChannel.email;
  }

  static CampaignObjective _objectiveFromDb(dynamic value) {
    final v = value?.toString() ?? '';
    for (final o in CampaignObjective.values) {
      if (o.name == v) return o;
    }
    for (final o in CampaignObjective.values) {
      if (o.label.toLowerCase() == v.toLowerCase()) return o;
    }
    return CampaignObjective.brandAwareness;
  }

  // ── Activities ────────────────────────────────────────────────────────────

  static Map<String, dynamic> _activityToJson(CampaignActivity a) => {
        'description': a.description,
        'date': a.date,
        'iconCode': a.icon.codePoint,
        'iconColorValue': a.iconColor.value,
      };

  static CampaignActivity _activityFromJson(Map<String, dynamic> json) {
    final code = _toInt(json['iconCode']);
    final colorValue = _toInt(json['iconColorValue']);
    return CampaignActivity(
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      icon: code != 0
          ? IconData(code, fontFamily: 'MaterialIcons')
          : Icons.flag_outlined,
      iconColor: colorValue != 0 ? Color(colorValue) : AppColors.primary,
    );
  }

  // ── Coupons ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _couponToJson(CampaignCoupon cpn) => {
        'code': cpn.code,
        'discount': cpn.discount,
        'usageLimit': cpn.usageLimit,
        'usedCount': cpn.usedCount,
        'expiryDate': cpn.expiryDate,
      };

  static CampaignCoupon _couponFromJson(Map<String, dynamic> json) {
    return CampaignCoupon(
      code: json['code']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      usageLimit: _toInt(json['usageLimit']),
      usedCount: _toInt(json['usedCount']),
      expiryDate: json['expiryDate']?.toString() ?? '',
    );
  }

  // ── Primitive coercion helpers (PostgREST may deliver numeric/date types
  //    as int, double, String or null depending on column type) ─────────────

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _dateFromDb(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return DateTime.tryParse(s.isEmpty ? '' : s);
  }

  static String? _dateToDb(DateTime? d) =>
      d == null ? null : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
