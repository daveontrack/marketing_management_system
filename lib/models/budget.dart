import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import '../services/entity_remote_stores.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BUDGET — canonical model for the Budget module.
//
// Shape mirrors what the budget screen displays (previously a private
// _BudgetItem class inside the screen). Persisted in the Supabase `budgets`
// table; see BudgetRepository below for sync behaviour.
// ═══════════════════════════════════════════════════════════════════════════

class Budget {
  final String id;
  final String name;
  final String category;
  final double allocated;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String status;
  final DateTime lastUpdated;

  const Budget({
    required this.id,
    required this.name,
    required this.category,
    required this.allocated,
    required this.spent,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.status,
    required this.lastUpdated,
  });

  double get remaining => (allocated - spent).clamp(0, double.infinity);
  double get utilization => allocated > 0 ? (spent / allocated).clamp(0, 1) : 0;

  String get utilizationStatus {
    if (utilization >= 1.0) return 'Over Budget';
    if (utilization >= 0.85) return 'Near Limit';
    return 'Healthy';
  }

  Color get utilizationColor {
    if (utilization >= 1.0) return AppColors.danger;
    if (utilization >= 0.85) return AppColors.warning;
    return AppColors.success;
  }
}

class BudgetRepository {
  BudgetRepository._();

  static final List<Budget> _budgets = [
    Budget(id: 'B001', name: 'Digital Advertising', category: 'Advertising',
        allocated: 320000, spent: 272000, startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31), description: 'Google Ads, Facebook Ads, and display campaigns.',
        status: AppConstants.statusActive, lastUpdated: DateTime(2026, 8, 10)),
    Budget(id: 'B002', name: 'Blog & Video Content', category: 'Content',
        allocated: 150000, spent: 68000, startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31), description: 'Blog posts, videos, and infographic production.',
        status: AppConstants.statusActive, lastUpdated: DateTime(2026, 8, 8)),
    Budget(id: 'B003', name: 'Influencer Partnerships', category: 'Influencer Marketing',
        allocated: 180000, spent: 178500, startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 9, 30), description: 'Sponsored posts and collaboration fees.',
        status: AppConstants.statusActive, lastUpdated: DateTime(2026, 8, 12)),
    Budget(id: 'B004', name: 'Annual Conference', category: 'Events',
        allocated: 220000, spent: 238000, startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 8, 31), description: 'Addis Ababa marketing summit — venue, catering, AV.',
        status: AppConstants.statusActive, lastUpdated: DateTime(2026, 8, 14)),
    Budget(id: 'B005', name: 'Email & SMS Campaigns', category: 'Email/SMS',
        allocated: 80000, spent: 42000, startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31), description: 'Bulk email platform, SMS gateway, automation tools.',
        status: AppConstants.statusActive, lastUpdated: DateTime(2026, 8, 7)),
    Budget(id: 'B006', name: 'Market Research', category: 'Other',
        allocated: 50000, spent: 12500, startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 30), description: 'Consumer surveys, competitor analysis, reports.',
        status: AppConstants.statusPaused, lastUpdated: DateTime(2026, 7, 15)),
  ];

  static bool _initialized = false;

  /// Loads budgets from Supabase once at startup (called from main.dart).
  /// Falls back to bundled seed data when the backend is unreachable; seeds
  /// the remote table from local data on first run when it is empty.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final remote = await BudgetRemoteStore.fetchAll();
    if (remote == null) return;
    if (remote.isEmpty) {
      await BudgetRemoteStore.seed(_budgets);
    } else {
      _budgets
        ..clear()
        ..addAll(remote);
    }
  }

  static List<Budget> getAll() => List.unmodifiable(_budgets);

  static Budget? findById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static void add(Budget budget) {
    _budgets.add(budget);
    BudgetRemoteStore.upsert(budget); // fire-and-forget sync
  }

  static void update(Budget budget) {
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) {
      _budgets[idx] = budget;
      BudgetRemoteStore.upsert(budget); // fire-and-forget sync
    }
  }

  static void remove(String id) {
    _budgets.removeWhere((b) => b.id == id);
    BudgetRemoteStore.delete(id); // fire-and-forget sync
  }

  static String nextId() {
    if (_budgets.isEmpty) return 'B001';
    final maxNum = _budgets
        .map((b) => int.tryParse(b.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return 'B${(maxNum + 1).toString().padLeft(3, '0')}';
  }
}
