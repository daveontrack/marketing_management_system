import '../core/constants.dart';

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String segment;
  final String status;
  final DateTime lastActivity;
  final DateTime joinedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.segment,
    required this.status,
    required this.lastActivity,
    required this.joinedAt,
  });

  String get initials => name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();
}

class CustomerRepository {
  CustomerRepository._();

  static final List<Customer> _customers = [
    Customer(
      id: 1,
      name: 'Abebe Kebede',
      email: 'abebe.kebede@techwave.com',
      phone: '+251 911 234 567',
      segment: 'VIP',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 12),
      joinedAt: DateTime(2023, 1, 10),
    ),
    Customer(
      id: 2,
      name: 'Sara Ahmed',
      email: 'sara.ahmed@greenleaf.co',
      phone: '+251 922 345 678',
      segment: 'Corporate',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 11),
      joinedAt: DateTime(2023, 4, 22),
    ),
    Customer(
      id: 3,
      name: 'John Smith',
      email: 'john.smith@globalretail.com',
      phone: '+251 933 456 789',
      segment: 'Retail',
      status: AppConstants.statusDraft,
      lastActivity: DateTime(2026, 4, 28),
      joinedAt: DateTime(2022, 11, 5),
    ),
    Customer(
      id: 4,
      name: 'Meron Tadesse',
      email: 'meron.t@innovate.et',
      phone: '+251 944 567 890',
      segment: 'Retail',
      status: 'Pending',
      lastActivity: DateTime(2026, 5, 10),
      joinedAt: DateTime(2024, 2, 14),
    ),
    Customer(
      id: 5,
      name: 'Daniel Girma',
      email: 'daniel.girma@nexustech.com',
      phone: '+251 955 678 901',
      segment: 'Corporate',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 9),
      joinedAt: DateTime(2023, 8, 3),
    ),
    Customer(
      id: 6,
      name: 'Hana Bekele',
      email: 'hana.b@brightstar.io',
      phone: '+251 966 789 012',
      segment: 'VIP',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 8),
      joinedAt: DateTime(2024, 1, 5),
    ),
    Customer(
      id: 7,
      name: 'Yonas Alemu',
      email: 'yonas.a@summitgroup.com',
      phone: '+251 977 890 123',
      segment: 'Corporate',
      status: AppConstants.statusPaused,
      lastActivity: DateTime(2026, 4, 15),
      joinedAt: DateTime(2023, 6, 20),
    ),
    Customer(
      id: 8,
      name: 'Lidya Haile',
      email: 'lidya.h@freshstart.et',
      phone: '+251 988 901 234',
      segment: 'Retail',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 12),
      joinedAt: DateTime(2024, 3, 1),
    ),
    Customer(
      id: 9,
      name: 'Samuel Tesfaye',
      email: 'samuel.t@apexventures.com',
      phone: '+251 999 012 345',
      segment: 'VIP',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 7),
      joinedAt: DateTime(2022, 9, 18),
    ),
    Customer(
      id: 10,
      name: 'Kenenisa Bekele',
      email: 'kenenisa.b@speedlogistics.com',
      phone: '+251 910 123 456',
      segment: 'Corporate',
      status: 'Pending',
      lastActivity: DateTime(2026, 5, 5),
      joinedAt: DateTime(2024, 11, 22),
    ),
    Customer(
      id: 11,
      name: 'Rahel Tesfaye',
      email: 'rahel.t@bloomdesign.co',
      phone: '+251 921 234 567',
      segment: 'Retail',
      status: AppConstants.statusActive,
      lastActivity: DateTime(2026, 5, 11),
      joinedAt: DateTime(2023, 12, 5),
    ),
    Customer(
      id: 12,
      name: 'Bereket Yohannes',
      email: 'bereket.y@corebuild.et',
      phone: '+251 932 345 678',
      segment: 'Corporate',
      status: AppConstants.statusCompleted,
      lastActivity: DateTime(2026, 3, 30),
      joinedAt: DateTime(2022, 5, 14),
    ),
  ];

  static List<Customer> getAll() => List.unmodifiable(_customers);

  static Customer? findById(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static void add(Customer customer) {
    _customers.add(customer);
  }

  static void update(Customer customer) {
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) _customers[idx] = customer;
  }

  static void remove(int id) {
    _customers.removeWhere((c) => c.id == id);
  }

  static int nextId() {
    return _customers.isEmpty ? 1 : _customers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
