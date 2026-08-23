import '../models/campaign.dart';
import '../models/customer.dart';
import '../models/budget.dart';
import '../models/promotion.dart';



class DataService {
  DataService._();

  static final DataService instance = DataService._();

  // ===========================
  // Campaign Data
  // ===========================

  final List<Campaign> campaigns = [
    Campaign(
      id: 'C001',
      name: "Summer Sale",
      description: "Promote summer products",
      objective: CampaignObjective.salesConversion,
      channels: [CampaignChannel.socialMedia, CampaignChannel.email],
      status: "Active",
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
      budget: 5000,
      spent: 3200,
      leads: 420,
      conversions: 98,
      impressions: 12500,
      roi: 2.8,
      activities: [],
      coupons: [],
    ),
    Campaign(
      id: 'C002',
      name: "Back to School",
      description: "Student promotion campaign",
      objective: CampaignObjective.brandAwareness,
      channels: [CampaignChannel.email, CampaignChannel.webPush],
      status: "Pending",
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 30),
      budget: 8000,
      spent: 0,
      leads: 0,
      conversions: 0,
      impressions: 0,
      roi: 0,
      activities: [],
      coupons: [],
    ),
  ];

  // ===========================
  // Customer Data
  // ===========================

  final List<Customer> customers = [
    Customer(
      id: 1,
      name: 'Abebe Kebede',
      email: 'abebe@gmail.com',
      phone: '0911000000',
      segment: 'Retail',
      status: 'Active',
      lastActivity: DateTime(2026, 5, 1),
      joinedAt: DateTime(2023, 1, 10),
    ),
    Customer(
      id: 2,
      name: 'Sara Ahmed',
      email: 'sara@gmail.com',
      phone: '0922000000',
      segment: 'Corporate',
      status: 'Active',
      lastActivity: DateTime(2026, 5, 2),
      joinedAt: DateTime(2023, 4, 22),
    ),
  ];

  // ===========================
  // Budget Data
  // ===========================

  final List<Budget> budgets = [
    Budget(
      id: 1,
      campaignId: 1,
      allocatedAmount: 10000,
      spentAmount: 3500,
      date: DateTime.now(),
    ),
  ];

  // ===========================
  // Promotion Data
  // ===========================

  final List<Promotion> promotions = [
    Promotion(
      id: 1,
      title: "Summer Discount",
      description: "20% discount",
      discount: 20,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      status: "Active",
    ),
  ];

  // ===========================
  // Report Data
  // ===========================
  // Reports are managed by ReportRepository in lib/models/report.dart.

  // ===========================
  // Campaign Methods
  // ===========================

  List<Campaign> getCampaigns() => campaigns;

  void addCampaign(Campaign campaign) {
    campaigns.add(campaign);
  }

  void updateCampaign(int index, Campaign campaign) {
    campaigns[index] = campaign;
  }

  void deleteCampaign(int index) {
    campaigns.removeAt(index);
  }

  // ===========================
  // Customer Methods
  // ===========================

  List<Customer> getCustomers() => customers;

  void addCustomer(Customer customer) {
    customers.add(customer);
  }

  void updateCustomer(int index, Customer customer) {
    customers[index] = customer;
  }

  void deleteCustomer(int index) {
    customers.removeAt(index);
  }

  // ===========================
  // Budget Methods
  // ===========================

  List<Budget> getBudgets() => budgets;

  void addBudget(Budget budget) {
    budgets.add(budget);
  }

  // ===========================
  // Promotion Methods
  // ===========================

  List<Promotion> getPromotions() => promotions;

  void addPromotion(Promotion promotion) {
    promotions.add(promotion);
  }

  // ===========================
  // Report Methods
  // ===========================
  // Use ReportRepository.getAll() from lib/models/report.dart instead.
}