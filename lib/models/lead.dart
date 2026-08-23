import '../core/constants.dart';
import '../services/entity_remote_stores.dart';

class Lead {
  final int id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String source;
  final int score;
  final String assignedTo;
  final String status;
  final String priority;
  final DateTime createdAt;

  const Lead({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.source,
    required this.score,
    required this.assignedTo,
    required this.status,
    required this.priority,
    required this.createdAt,
  });
}

class LeadRepository {
  LeadRepository._();

  static final List<Lead> _leads = [
    Lead(
      id: 1,
      name: 'Abebe Kebede',
      company: 'TechWave Inc.',
      email: 'abebe@techwave.com',
      phone: '+251 911 234 567',
      source: 'Website',
      score: 85,
      assignedTo: 'Hana Tsegaye',
      status: AppConstants.leadQualified,
      priority: 'High',
      createdAt: DateTime(2026, 5, 1),
    ),
    Lead(
      id: 2,
      name: 'Sara Ahmed',
      company: 'GreenLeaf Co.',
      email: 'sara@greenleaf.co',
      phone: '+251 922 345 678',
      source: 'Social Media',
      score: 72,
      assignedTo: 'Daniel Girma',
      status: AppConstants.leadNew,
      priority: 'Medium',
      createdAt: DateTime(2026, 5, 3),
    ),
    Lead(
      id: 3,
      name: 'John Smith',
      company: 'Global Retail',
      email: 'john@globalretail.com',
      phone: '+251 933 456 789',
      source: 'Email',
      score: 45,
      assignedTo: 'Meron Tadesse',
      status: AppConstants.leadContacted,
      priority: 'Low',
      createdAt: DateTime(2026, 5, 5),
    ),
    Lead(
      id: 4,
      name: 'Meron Tadesse',
      company: 'Innovate ET',
      email: 'meron@innovate.et',
      phone: '+251 944 567 890',
      source: 'Referrals',
      score: 91,
      assignedTo: 'Hana Tsegaye',
      status: AppConstants.leadQualified,
      priority: 'High',
      createdAt: DateTime(2026, 5, 2),
    ),
    Lead(
      id: 5,
      name: 'Daniel Girma',
      company: 'NexusTech',
      email: 'daniel@nexustech.com',
      phone: '+251 955 678 901',
      source: 'Paid Ads',
      score: 38,
      assignedTo: 'Yonas Alemu',
      status: AppConstants.leadUnqualified,
      priority: 'Low',
      createdAt: DateTime(2026, 5, 4),
    ),
    Lead(
      id: 6,
      name: 'Hana Bekele',
      company: 'BrightStar IO',
      email: 'hana@brightstar.io',
      phone: '+251 966 789 012',
      source: 'Website',
      score: 68,
      assignedTo: 'Daniel Girma',
      status: AppConstants.leadNew,
      priority: 'Medium',
      createdAt: DateTime(2026, 5, 6),
    ),
    Lead(
      id: 7,
      name: 'Yonas Alemu',
      company: 'Summit Group',
      email: 'yonas@summitgroup.com',
      phone: '+251 977 890 123',
      source: 'Social Media',
      score: 55,
      assignedTo: 'Meron Tadesse',
      status: AppConstants.leadContacted,
      priority: 'Medium',
      createdAt: DateTime(2026, 5, 7),
    ),
    Lead(
      id: 8,
      name: 'Lidya Haile',
      company: 'FreshStart ET',
      email: 'lidya@freshstart.et',
      phone: '+251 988 901 234',
      source: 'Referrals',
      score: 95,
      assignedTo: 'Hana Tsegaye',
      status: AppConstants.leadConverted,
      priority: 'High',
      createdAt: DateTime(2026, 4, 28),
    ),
    Lead(
      id: 9,
      name: 'Samuel Tesfaye',
      company: 'Apex Ventures',
      email: 'samuel@apexventures.com',
      phone: '+251 999 012 345',
      source: 'Website',
      score: 60,
      assignedTo: 'Yonas Alemu',
      status: AppConstants.leadNew,
      priority: 'Medium',
      createdAt: DateTime(2026, 5, 8),
    ),
    Lead(
      id: 10,
      name: 'Kenenisa Bekele',
      company: 'SpeedLogistics',
      email: 'kenenisa@speedlogistics.com',
      phone: '+251 910 123 456',
      source: 'Paid Ads',
      score: 78,
      assignedTo: 'Daniel Girma',
      status: AppConstants.leadQualified,
      priority: 'High',
      createdAt: DateTime(2026, 5, 9),
    ),
    Lead(
      id: 11,
      name: 'Rahel Tesfaye',
      company: 'BloomDesign Co.',
      email: 'rahel@bloomdesign.co',
      phone: '+251 921 234 567',
      source: 'Email',
      score: 42,
      assignedTo: 'Meron Tadesse',
      status: AppConstants.leadContacted,
      priority: 'Low',
      createdAt: DateTime(2026, 5, 10),
    ),
    Lead(
      id: 12,
      name: 'Bereket Yohannes',
      company: 'CoreBuild ET',
      email: 'bereket@corebuild.et',
      phone: '+251 932 345 678',
      source: 'Website',
      score: 88,
      assignedTo: 'Hana Tsegaye',
      status: AppConstants.leadQualified,
      priority: 'High',
      createdAt: DateTime(2026, 5, 11),
    ),
  ];

  static bool _initialized = false;

  /// Loads leads from Supabase once at startup (called from main.dart).
  /// Falls back to bundled seed data when the backend is unreachable; seeds
  /// the remote table from local data on first run when it is empty.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final remote = await LeadRemoteStore.fetchAll();
    if (remote == null) return;
    if (remote.isEmpty) {
      await LeadRemoteStore.seed(_leads);
    } else {
      _leads
        ..clear()
        ..addAll(remote);
    }
  }

  static List<Lead> getAll() => List.unmodifiable(_leads);

  static Lead? findById(int id) {
    try {
      return _leads.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  static void add(Lead lead) {
    _leads.add(lead);
    LeadRemoteStore.upsert(lead); // fire-and-forget sync
  }

  static void update(Lead lead) {
    final idx = _leads.indexWhere((l) => l.id == lead.id);
    if (idx != -1) {
      _leads[idx] = lead;
      LeadRemoteStore.upsert(lead); // fire-and-forget sync
    }
  }

  static void remove(int id) {
    _leads.removeWhere((l) => l.id == id);
    LeadRemoteStore.delete(id); // fire-and-forget sync
  }

  static int nextId() {
    return _leads.isEmpty ? 1 : _leads.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
