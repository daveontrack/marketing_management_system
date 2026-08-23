import '../services/entity_remote_stores.dart';

class Opportunity {
  final int id;
  final String name;
  final String company;
  final double value;
  final String owner;
  final int probability;
  final String stage;
  final DateTime createdAt;

  const Opportunity({
    required this.id,
    required this.name,
    required this.company,
    required this.value,
    required this.owner,
    required this.probability,
    required this.stage,
    required this.createdAt,
  });
}

class OpportunityRepository {
  OpportunityRepository._();

  static final List<Opportunity> _opportunities = [
    Opportunity(
      id: 1,
      name: 'Summer Campaign Package',
      company: 'TechWave Inc.',
      value: 45000,
      owner: 'Hana Tsegaye',
      probability: 80,
      stage: 'Proposal',
      createdAt: DateTime(2026, 4, 15),
    ),
    Opportunity(
      id: 2,
      name: 'Brand Awareness Q3',
      company: 'GreenLeaf Co.',
      value: 28000,
      owner: 'Daniel Girma',
      probability: 60,
      stage: 'Negotiation',
      createdAt: DateTime(2026, 4, 20),
    ),
    Opportunity(
      id: 3,
      name: 'Product Launch Support',
      company: 'NexusTech',
      value: 65000,
      owner: 'Yonas Alemu',
      probability: 40,
      stage: 'Qualified',
      createdAt: DateTime(2026, 5, 1),
    ),
    Opportunity(
      id: 4,
      name: 'Email Automation Suite',
      company: 'BrightStar IO',
      value: 18500,
      owner: 'Meron Tadesse',
      probability: 90,
      stage: 'Negotiation',
      createdAt: DateTime(2026, 5, 3),
    ),
    Opportunity(
      id: 5,
      name: 'Social Media Takeover',
      company: 'Summit Group',
      value: 32000,
      owner: 'Hana Tsegaye',
      probability: 25,
      stage: 'New',
      createdAt: DateTime(2026, 5, 8),
    ),
    Opportunity(
      id: 6,
      name: 'Retargeting Strategy',
      company: 'FreshStart ET',
      value: 12000,
      owner: 'Daniel Girma',
      probability: 70,
      stage: 'Proposal',
      createdAt: DateTime(2026, 5, 5),
    ),
    Opportunity(
      id: 7,
      name: 'Influencer Partnership',
      company: 'Apex Ventures',
      value: 22000,
      owner: 'Yonas Alemu',
      probability: 55,
      stage: 'Qualified',
      createdAt: DateTime(2026, 5, 6),
    ),
    Opportunity(
      id: 8,
      name: 'Holiday Campaign 2026',
      company: 'SpeedLogistics',
      value: 52000,
      owner: 'Hana Tsegaye',
      probability: 15,
      stage: 'New',
      createdAt: DateTime(2026, 5, 10),
    ),
    Opportunity(
      id: 9,
      name: 'SEO Overhaul',
      company: 'BloomDesign Co.',
      value: 15000,
      owner: 'Meron Tadesse',
      probability: 95,
      stage: 'Won',
      createdAt: DateTime(2026, 4, 10),
    ),
    Opportunity(
      id: 10,
      name: 'PPC Management',
      company: 'CoreBuild ET',
      value: 28000,
      owner: 'Daniel Girma',
      probability: 10,
      stage: 'New',
      createdAt: DateTime(2026, 5, 12),
    ),
    Opportunity(
      id: 11,
      name: 'Content Strategy Retainer',
      company: 'TechWave Inc.',
      value: 36000,
      owner: 'Hana Tsegaye',
      probability: 50,
      stage: 'Proposal',
      createdAt: DateTime(2026, 5, 2),
    ),
    Opportunity(
      id: 12,
      name: 'Event Marketing Package',
      company: 'GreenLeaf Co.',
      value: 18000,
      owner: 'Yonas Alemu',
      probability: 30,
      stage: 'Qualified',
      createdAt: DateTime(2026, 5, 7),
    ),
  ];

  static bool _initialized = false;

  /// Loads opportunities from Supabase once at startup (called from
  /// main.dart). Falls back to bundled seed data when the backend is
  /// unreachable; seeds the remote table from local data on first run when
  /// it is empty.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final remote = await OpportunityRemoteStore.fetchAll();
    if (remote == null) return;
    if (remote.isEmpty) {
      await OpportunityRemoteStore.seed(_opportunities);
    } else {
      _opportunities
        ..clear()
        ..addAll(remote);
    }
  }

  static List<Opportunity> getAll() => List.unmodifiable(_opportunities);

  static List<Opportunity> getByStage(String stage) {
    return _opportunities.where((o) => o.stage == stage).toList();
  }

  static Opportunity? findById(int id) {
    try {
      return _opportunities.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static void add(Opportunity opportunity) {
    _opportunities.add(opportunity);
    OpportunityRemoteStore.upsert(opportunity); // fire-and-forget sync
  }

  static void update(Opportunity opportunity) {
    final idx = _opportunities.indexWhere((o) => o.id == opportunity.id);
    if (idx != -1) {
      _opportunities[idx] = opportunity;
      OpportunityRemoteStore.upsert(opportunity); // fire-and-forget sync
    }
  }

  static void remove(int id) {
    _opportunities.removeWhere((o) => o.id == id);
    OpportunityRemoteStore.delete(id); // fire-and-forget sync
  }

  static void updateStage(int id, String newStage) {
    final index = _opportunities.indexWhere((o) => o.id == id);
    if (index != -1) {
      _opportunities[index] = Opportunity(
        id: _opportunities[index].id,
        name: _opportunities[index].name,
        company: _opportunities[index].company,
        value: _opportunities[index].value,
        owner: _opportunities[index].owner,
        probability: _opportunities[index].probability,
        stage: newStage,
        createdAt: _opportunities[index].createdAt,
      );
      OpportunityRemoteStore.upsert(_opportunities[index]); // sync stage move
    }
  }

  static int nextId() {
    return _opportunities.isEmpty ? 1 : _opportunities.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
