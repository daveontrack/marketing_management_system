import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/constants.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOMER
// ═══════════════════════════════════════════════════════════════════════════

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String segment;
  final String status;
  final String location;
  final double totalSpend;
  final int totalOrders;
  final DateTime joinDate;
  final String avatarInitials;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.segment,
    required this.status,
    required this.location,
    required this.totalSpend,
    required this.totalOrders,
    required this.joinDate,
    required this.avatarInitials,
  });
}

class CustomerRepository {
  static final List<Customer> _data = [
    Customer(id: 'CU001', name: 'Abebe Girma', email: 'abebe@email.com', phone: '+251 911 234 567', segment: 'VIP', status: AppConstants.statusActive, location: 'Addis Ababa', totalSpend: 85000, totalOrders: 24, joinDate: DateTime(2024, 1, 15), avatarInitials: 'AG'),
    Customer(id: 'CU002', name: 'Sara Tadesse', email: 'sara@email.com', phone: '+251 922 345 678', segment: 'Regular', status: AppConstants.statusActive, location: 'Bahir Dar', totalSpend: 32000, totalOrders: 11, joinDate: DateTime(2024, 3, 8), avatarInitials: 'ST'),
    Customer(id: 'CU003', name: 'Yonas Bekele', email: 'yonas@email.com', phone: '+251 933 456 789', segment: 'Premium', status: AppConstants.statusActive, location: 'Hawassa', totalSpend: 61500, totalOrders: 18, joinDate: DateTime(2023, 11, 22), avatarInitials: 'YB'),
    Customer(id: 'CU004', name: 'Hana Mulugeta', email: 'hana@email.com', phone: '+251 944 567 890', segment: 'New', status: AppConstants.statusActive, location: 'Dire Dawa', totalSpend: 9200, totalOrders: 3, joinDate: DateTime(2026, 4, 1), avatarInitials: 'HM'),
    Customer(id: 'CU005', name: 'Dawit Alemu', email: 'dawit@email.com', phone: '+251 955 678 901', segment: 'Regular', status: AppConstants.statusPaused, location: 'Mekelle', totalSpend: 27400, totalOrders: 9, joinDate: DateTime(2024, 7, 14), avatarInitials: 'DA'),
    Customer(id: 'CU006', name: 'Tigist Haile', email: 'tigist@email.com', phone: '+251 966 789 012', segment: 'VIP', status: AppConstants.statusActive, location: 'Addis Ababa', totalSpend: 112000, totalOrders: 31, joinDate: DateTime(2023, 6, 5), avatarInitials: 'TH'),
    Customer(id: 'CU007', name: 'Biruk Tesfaye', email: 'biruk@email.com', phone: '+251 977 890 123', segment: 'Premium', status: AppConstants.statusActive, location: 'Jimma', totalSpend: 54300, totalOrders: 15, joinDate: DateTime(2024, 2, 19), avatarInitials: 'BT'),
    Customer(id: 'CU008', name: 'Meron Getnet', email: 'meron@email.com', phone: '+251 988 901 234', segment: 'New', status: AppConstants.statusActive, location: 'Gondar', totalSpend: 5600, totalOrders: 2, joinDate: DateTime(2026, 5, 3), avatarInitials: 'MG'),
  ];

  static List<Customer> getAll() => List.unmodifiable(_data);
}

// ═══════════════════════════════════════════════════════════════════════════
// LEAD
// ═══════════════════════════════════════════════════════════════════════════

class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String source;
  final String status;
  final int score;
  final String assignedTo;
  final DateTime createdAt;
  final String campaignName;

  const Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.source,
    required this.status,
    required this.score,
    required this.assignedTo,
    required this.createdAt,
    required this.campaignName,
  });
}

class LeadRepository {
  static final List<Lead> _data = [
    Lead(id: 'L001', name: 'Abebe Girma', email: 'abebe@techco.com', phone: '+251 911 111 111', company: 'TechCo Ethiopia', source: 'Website', status: AppConstants.leadQualified, score: 88, assignedTo: 'Sara M.', createdAt: DateTime(2026, 5, 1), campaignName: 'Product Launch 2026'),
    Lead(id: 'L002', name: 'Fatuma Hassan', email: 'fatuma@startup.io', phone: '+251 922 222 222', company: 'StartUp Hub', source: 'Social Media', status: AppConstants.leadNew, score: 54, assignedTo: 'Yonas B.', createdAt: DateTime(2026, 5, 3), campaignName: 'Summer Sale Promo'),
    Lead(id: 'L003', name: 'Solomon Tesfay', email: 's.tesfay@corp.et', phone: '+251 933 333 333', company: 'Corp Solutions', source: 'Email', status: AppConstants.leadContacted, score: 72, assignedTo: 'Sara M.', createdAt: DateTime(2026, 5, 4), campaignName: 'Lead Gen — SME'),
    Lead(id: 'L004', name: 'Marta Kebede', email: 'marta@design.et', phone: '+251 944 444 444', company: 'Design Studio', source: 'Referral', status: AppConstants.leadConverted, score: 95, assignedTo: 'Dawit A.', createdAt: DateTime(2026, 4, 28), campaignName: 'Influencer Collab Q2'),
    Lead(id: 'L005', name: 'Henok Wolde', email: 'henok@finance.et', phone: '+251 955 555 555', company: 'Finance Plus', source: 'Search', status: AppConstants.leadUnqualified, score: 31, assignedTo: 'Yonas B.', createdAt: DateTime(2026, 5, 5), campaignName: 'Brand Awareness Q3'),
    Lead(id: 'L006', name: 'Liya Mengistu', email: 'liya@retail.com', phone: '+251 966 666 666', company: 'Retail World', source: 'Website', status: AppConstants.leadQualified, score: 81, assignedTo: 'Sara M.', createdAt: DateTime(2026, 5, 6), campaignName: 'Product Launch 2026'),
    Lead(id: 'L007', name: 'Natnael Girma', email: 'natnael@media.et', phone: '+251 977 777 777', company: 'Media Group', source: 'Event', status: AppConstants.leadContacted, score: 67, assignedTo: 'Dawit A.', createdAt: DateTime(2026, 5, 7), campaignName: 'Summer Sale Promo'),
    Lead(id: 'L008', name: 'Selam Hailu', email: 'selam@edu.et', phone: '+251 988 888 888', company: 'EduTech ET', source: 'Social Media', status: AppConstants.leadNew, score: 45, assignedTo: 'Yonas B.', createdAt: DateTime(2026, 5, 8), campaignName: 'Lead Gen — SME'),
  ];

  static List<Lead> getAll() => List.unmodifiable(_data);
  static Lead? findById(String id) {
    try { return _data.firstWhere((l) => l.id == id); } catch (_) { return null; }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OPPORTUNITY
// ═══════════════════════════════════════════════════════════════════════════

class Opportunity {
  final String id;
  final String name;
  final String company;
  final String contactName;
  final String stage;
  final double value;
  final double probability;
  final DateTime expectedClose;
  final String assignedTo;
  final String description;

  const Opportunity({
    required this.id,
    required this.name,
    required this.company,
    required this.contactName,
    required this.stage,
    required this.value,
    required this.probability,
    required this.expectedClose,
    required this.assignedTo,
    required this.description,
  });

  Color get stageColor {
    switch (stage) {
      case AppConstants.stageQualification:  return AppColors.info;
      case AppConstants.stageNeedsAnalysis:  return const Color(0xFFBB5CF8);
      case AppConstants.stageProposal:       return AppColors.warning;
      case AppConstants.stageNegotiation:    return AppColors.primary;
      case AppConstants.stageClosedWon:      return AppColors.success;
      case AppConstants.stageClosedLost:     return AppColors.danger;
      default: return AppColors.textSecondary;
    }
  }
}

class OpportunityRepository {
  static final List<Opportunity> _data = [
    Opportunity(id: 'OP001', name: 'Enterprise CRM Deal', company: 'TechCo Ethiopia', contactName: 'Abebe Girma', stage: AppConstants.stageProposal, value: 450000, probability: 0.65, expectedClose: DateTime(2026, 6, 30), assignedTo: 'Sara M.', description: 'Full enterprise CRM suite + onboarding'),
    Opportunity(id: 'OP002', name: 'SME Marketing Package', company: 'StartUp Hub', contactName: 'Fatuma Hassan', stage: AppConstants.stageNegotiation, value: 120000, probability: 0.80, expectedClose: DateTime(2026, 5, 31), assignedTo: 'Yonas B.', description: 'Monthly retainer for digital marketing'),
    Opportunity(id: 'OP003', name: 'Brand Audit Contract', company: 'Retail World', contactName: 'Liya Mengistu', stage: AppConstants.stageQualification, value: 75000, probability: 0.30, expectedClose: DateTime(2026, 7, 15), assignedTo: 'Dawit A.', description: 'One-time brand health audit and report'),
    Opportunity(id: 'OP004', name: 'Social Media Management', company: 'Media Group', contactName: 'Natnael Girma', stage: AppConstants.stageNeedsAnalysis, value: 95000, probability: 0.50, expectedClose: DateTime(2026, 6, 15), assignedTo: 'Sara M.', description: 'Quarterly social media management'),
    Opportunity(id: 'OP005', name: 'SEO & Content Deal', company: 'EduTech ET', contactName: 'Selam Hailu', stage: AppConstants.stageClosedWon, value: 60000, probability: 1.0, expectedClose: DateTime(2026, 4, 30), assignedTo: 'Yonas B.', description: 'SEO audit and 6-month content plan'),
    Opportunity(id: 'OP006', name: 'Ad Campaign Bundle', company: 'Finance Plus', contactName: 'Henok Wolde', stage: AppConstants.stageClosedLost, value: 180000, probability: 0.0, expectedClose: DateTime(2026, 4, 15), assignedTo: 'Dawit A.', description: 'Multi-channel paid advertising bundle'),
    Opportunity(id: 'OP007', name: 'Email Automation Setup', company: 'Corp Solutions', contactName: 'Solomon Tesfay', stage: AppConstants.stageProposal, value: 55000, probability: 0.60, expectedClose: DateTime(2026, 6, 1), assignedTo: 'Sara M.', description: 'Email automation + CRM integration'),
    Opportunity(id: 'OP008', name: 'Influencer Network Access', company: 'Design Studio', contactName: 'Marta Kebede', stage: AppConstants.stageNegotiation, value: 220000, probability: 0.75, expectedClose: DateTime(2026, 5, 20), assignedTo: 'Yonas B.', description: 'Access to our influencer network Q3'),
  ];

  static List<Opportunity> getAll() => List.unmodifiable(_data);
}

// ═══════════════════════════════════════════════════════════════════════════
// INFLUENCER
// ═══════════════════════════════════════════════════════════════════════════

class Influencer {
  final String id;
  final String name;
  final String handle;
  final String platform;
  final int followers;
  final double engagementRate;
  final String category;
  final String status;
  final double costPerPost;
  final String campaignName;
  final String avatarInitials;
  final Color avatarColor;

  const Influencer({
    required this.id,
    required this.name,
    required this.handle,
    required this.platform,
    required this.followers,
    required this.engagementRate,
    required this.category,
    required this.status,
    required this.costPerPost,
    required this.campaignName,
    required this.avatarInitials,
    required this.avatarColor,
  });

  String get followersLabel {
    if (followers >= 1000000) return '${(followers / 1000000).toStringAsFixed(1)}M';
    if (followers >= 1000) return '${(followers / 1000).toStringAsFixed(0)}K';
    return '$followers';
  }
}

class InfluencerRepository {
  static final List<Influencer> _data = [
    Influencer(id: 'INF001', name: 'Abel Tafesse', handle: '@abeltafesse', platform: 'Instagram', followers: 245000, engagementRate: 5.8, category: 'Tech', status: AppConstants.statusActive, costPerPost: 12000, campaignName: 'Product Launch 2026', avatarInitials: 'AT', avatarColor: AppColors.primary),
    Influencer(id: 'INF002', name: 'Tizita Habte', handle: '@tizitah', platform: 'TikTok', followers: 890000, engagementRate: 8.2, category: 'Lifestyle', status: AppConstants.statusActive, costPerPost: 28000, campaignName: 'Summer Sale Promo', avatarInitials: 'TH', avatarColor: AppColors.info),
    Influencer(id: 'INF003', name: 'Kidus Mamo', handle: '@kidusmamo', platform: 'YouTube', followers: 120000, engagementRate: 4.1, category: 'Gaming', status: AppConstants.statusPaused, costPerPost: 8500, campaignName: 'Brand Awareness Q3', avatarInitials: 'KM', avatarColor: AppColors.danger),
    Influencer(id: 'INF004', name: 'Mekdes Alemu', handle: '@mekdesalemu', platform: 'Instagram', followers: 310000, engagementRate: 6.5, category: 'Fashion', status: AppConstants.statusActive, costPerPost: 16000, campaignName: 'Influencer Collab Q2', avatarInitials: 'MA', avatarColor: AppColors.success),
    Influencer(id: 'INF005', name: 'Yonas Getachew', handle: '@yonasgetachew', platform: 'Twitter', followers: 78000, engagementRate: 3.4, category: 'Business', status: AppConstants.statusCompleted, costPerPost: 5500, campaignName: 'Lead Gen — SME', avatarInitials: 'YG', avatarColor: AppColors.warning),
    Influencer(id: 'INF006', name: 'Feven Tadesse', handle: '@feventadesse', platform: 'TikTok', followers: 1200000, engagementRate: 9.1, category: 'Beauty', status: AppConstants.statusActive, costPerPost: 45000, campaignName: 'Product Launch 2026', avatarInitials: 'FT', avatarColor: const Color(0xFFBB5CF8)),
  ];

  static List<Influencer> getAll() => List.unmodifiable(_data);
}

// ═══════════════════════════════════════════════════════════════════════════
// CONTENT
// ═══════════════════════════════════════════════════════════════════════════

class ContentItem {
  final String id;
  final String title;
  final String type;
  final String channel;
  final String creator;
  final String status;
  final DateTime scheduledDate;
  final String campaignName;
  final String description;
  final int views;
  final int clicks;

  const ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.channel,
    required this.creator,
    required this.status,
    required this.scheduledDate,
    required this.campaignName,
    required this.description,
    required this.views,
    required this.clicks,
  });

  IconData get typeIcon {
    switch (type) {
      case 'Blog Post':   return Icons.article_outlined;
      case 'Video':       return Icons.play_circle_outline;
      case 'Social Post': return Icons.share_outlined;
      case 'Email':       return Icons.email_outlined;
      case 'Infographic': return Icons.bar_chart_outlined;
      case 'Webinar':     return Icons.videocam_outlined;
      default:            return Icons.insert_drive_file_outlined;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'Blog Post':   return AppColors.primary;
      case 'Video':       return AppColors.danger;
      case 'Social Post': return AppColors.info;
      case 'Email':       return AppColors.warning;
      case 'Infographic': return AppColors.success;
      case 'Webinar':     return const Color(0xFFBB5CF8);
      default:            return AppColors.textSecondary;
    }
  }
}

class ContentRepository {
  static final List<ContentItem> _data = [
    ContentItem(id: 'CN001', title: 'How to Boost Your Marketing ROI in 2026', type: 'Blog Post', channel: 'Website', creator: 'Sara M.', status: AppConstants.statusActive, scheduledDate: DateTime(2026, 5, 10), campaignName: 'Brand Awareness Q3', description: 'Comprehensive guide on modern marketing ROI tactics.', views: 3240, clicks: 412),
    ContentItem(id: 'CN002', title: 'Product Launch Announcement Video', type: 'Video', channel: 'YouTube', creator: 'Yonas B.', status: AppConstants.statusActive, scheduledDate: DateTime(2026, 5, 1), campaignName: 'Product Launch 2026', description: 'Official product launch video for the mobile app.', views: 18500, clicks: 2100),
    ContentItem(id: 'CN003', title: 'Summer Sale Instagram Carousel', type: 'Social Post', channel: 'Instagram', creator: 'Dawit A.', status: AppConstants.statusDraft, scheduledDate: DateTime(2026, 5, 15), campaignName: 'Summer Sale Promo', description: '5-slide carousel showcasing summer discounts.', views: 0, clicks: 0),
    ContentItem(id: 'CN004', title: 'Newsletter #12 — May 2026', type: 'Email', channel: 'Email', creator: 'Sara M.', status: AppConstants.statusActive, scheduledDate: DateTime(2026, 5, 8), campaignName: 'Re-engagement Campaign', description: 'Monthly newsletter with product updates and tips.', views: 9800, clicks: 1540),
    ContentItem(id: 'CN005', title: 'SME Marketing Guide Infographic', type: 'Infographic', channel: 'LinkedIn', creator: 'Yonas B.', status: AppConstants.statusCompleted, scheduledDate: DateTime(2026, 4, 20), campaignName: 'Lead Gen — SME', description: 'Visual guide to SME marketing best practices.', views: 5600, clicks: 890),
    ContentItem(id: 'CN006', title: 'Live Webinar: Digital Marketing Trends', type: 'Webinar', channel: 'Zoom', creator: 'Dawit A.', status: AppConstants.statusPaused, scheduledDate: DateTime(2026, 6, 5), campaignName: 'Brand Awareness Q3', description: 'Monthly webinar exploring current digital trends.', views: 0, clicks: 320),
    ContentItem(id: 'CN007', title: 'TikTok Brand Story', type: 'Video', channel: 'TikTok', creator: 'Sara M.', status: AppConstants.statusActive, scheduledDate: DateTime(2026, 5, 12), campaignName: 'Influencer Collab Q2', description: 'Short-form brand storytelling video for TikTok.', views: 42000, clicks: 3800),
  ];

  static List<ContentItem> getAll() => List.unmodifiable(_data);
}

// ═══════════════════════════════════════════════════════════════════════════
// PROMOTION / COUPON
// ═══════════════════════════════════════════════════════════════════════════

class Promotion {
  final String id;
  final String name;
  final String type;
  final String discount;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final int usageLimit;
  final int usedCount;
  final String status;
  final String campaignName;
  final List<String> couponCodes;

  const Promotion({
    required this.id,
    required this.name,
    required this.type,
    required this.discount,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.status,
    required this.campaignName,
    required this.couponCodes,
  });

  double get usagePercent => usageLimit > 0 ? usedCount / usageLimit : 0;
}

class PromotionRepository {
  static final List<Promotion> _data = [
    Promotion(id: 'PR001', name: 'Summer Flash Sale', type: 'Percentage', discount: '30% off', discountValue: 30, startDate: DateTime(2026, 5, 10), endDate: DateTime(2026, 6, 30), usageLimit: 1000, usedCount: 512, status: AppConstants.statusActive, campaignName: 'Summer Sale Promo', couponCodes: ['SUMMER30', 'FLASH30']),
    Promotion(id: 'PR002', name: 'Launch Day Offer', type: 'Percentage', discount: '20% off', discountValue: 20, startDate: DateTime(2026, 5, 1), endDate: DateTime(2026, 5, 31), usageLimit: 500, usedCount: 342, status: AppConstants.statusActive, campaignName: 'Product Launch 2026', couponCodes: ['LAUNCH20']),
    Promotion(id: 'PR003', name: 'Early Bird Discount', type: 'Percentage', discount: '15% off', discountValue: 15, startDate: DateTime(2026, 5, 1), endDate: DateTime(2026, 5, 15), usageLimit: 200, usedCount: 198, status: AppConstants.statusCompleted, campaignName: 'Product Launch 2026', couponCodes: ['EARLY15']),
    Promotion(id: 'PR004', name: 'Win-Back Offer', type: 'Percentage', discount: '10% off', discountValue: 10, startDate: DateTime(2026, 4, 1), endDate: DateTime(2026, 4, 30), usageLimit: 300, usedCount: 74, status: AppConstants.statusPaused, campaignName: 'Re-engagement Campaign', couponCodes: ['COMEBACK10']),
    Promotion(id: 'PR005', name: 'Loyalty Reward', type: 'Fixed Amount', discount: 'ETB 500 off', discountValue: 500, startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 8, 31), usageLimit: 150, usedCount: 0, status: AppConstants.statusDraft, campaignName: 'Brand Awareness Q3', couponCodes: ['LOYAL500']),
    Promotion(id: 'PR006', name: 'Referral Bonus', type: 'Percentage', discount: '25% off', discountValue: 25, startDate: DateTime(2026, 5, 15), endDate: DateTime(2026, 7, 15), usageLimit: 400, usedCount: 128, status: AppConstants.statusActive, campaignName: 'Lead Gen — SME', couponCodes: ['REFER25', 'REF25B']),
  ];

  static List<Promotion> getAll() => List.unmodifiable(_data);
}

// ═══════════════════════════════════════════════════════════════════════════
// BUDGET
// ═══════════════════════════════════════════════════════════════════════════

class BudgetEntry {
  final String campaignId;
  final String campaignName;
  final double allocated;
  final double spent;
  final String status;

  const BudgetEntry({
    required this.campaignId,
    required this.campaignName,
    required this.allocated,
    required this.spent,
    required this.status,
  });

  double get remaining => allocated - spent;
  double get utilization => allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
}

class BudgetRepository {
  static const double totalBudget = 1200000;

  static final List<BudgetEntry> entries = [
    BudgetEntry(campaignId: 'C001', campaignName: 'Product Launch 2026', allocated: 250000, spent: 195400, status: AppConstants.statusActive),
    BudgetEntry(campaignId: 'C002', campaignName: 'Summer Sale Promo', allocated: 150000, spent: 135000, status: AppConstants.statusActive),
    BudgetEntry(campaignId: 'C003', campaignName: 'Brand Awareness Q3', allocated: 200000, spent: 60250, status: AppConstants.statusDraft),
    BudgetEntry(campaignId: 'C004', campaignName: 'Re-engagement Campaign', allocated: 100000, spent: 45050, status: AppConstants.statusPaused),
    BudgetEntry(campaignId: 'C005', campaignName: 'Influencer Collab Q2', allocated: 180000, spent: 178500, status: AppConstants.statusCompleted),
    BudgetEntry(campaignId: 'C006', campaignName: 'Lead Gen — SME Segment', allocated: 120000, spent: 44800, status: AppConstants.statusActive),
    BudgetEntry(campaignId: 'C007', campaignName: 'Q3 Reserve', allocated: 200000, spent: 0, status: AppConstants.statusDraft),
  ];

  static double get totalSpent => entries.fold(0, (s, e) => s + e.spent);
  static double get totalRemaining => totalBudget - totalSpent;
  static double get utilization => totalBudget > 0 ? totalSpent / totalBudget : 0;
}

// ═══════════════════════════════════════════════════════════════════════════
// COMMUNICATION / NOTIFICATION
// ═══════════════════════════════════════════════════════════════════════════

class CommMessage {
  final String id;
  final String subject;
  final String type;
  final String recipient;
  final String status;
  final DateTime sentAt;
  final int openCount;
  final int clickCount;

  const CommMessage({
    required this.id,
    required this.subject,
    required this.type,
    required this.recipient,
    required this.status,
    required this.sentAt,
    required this.openCount,
    required this.clickCount,
  });

  IconData get typeIcon {
    switch (type) {
      case 'Email': return Icons.email_outlined;
      case 'SMS':   return Icons.sms_outlined;
      case 'Push':  return Icons.notifications_outlined;
      default:      return Icons.message_outlined;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'Email': return AppColors.primary;
      case 'SMS':   return AppColors.warning;
      case 'Push':  return AppColors.info;
      default:      return AppColors.textSecondary;
    }
  }
}

class CommunicationRepository {
  static final List<CommMessage> _data = [
    CommMessage(id: 'CM001', subject: 'Newsletter #12 — May 2026', type: 'Email', recipient: 'All Subscribers (9,800)', status: AppConstants.statusCompleted, sentAt: DateTime(2026, 5, 8, 9, 0), openCount: 4218, clickCount: 1540),
    CommMessage(id: 'CM002', subject: 'Summer Sale Flash Alert', type: 'SMS', recipient: 'Active Customers (8,200)', status: AppConstants.statusCompleted, sentAt: DateTime(2026, 5, 10, 10, 0), openCount: 8200, clickCount: 2450),
    CommMessage(id: 'CM003', subject: 'New Feature: Analytics Dashboard', type: 'Push', recipient: 'App Users (15,400)', status: AppConstants.statusActive, sentAt: DateTime(2026, 5, 12, 14, 0), openCount: 6200, clickCount: 1820),
    CommMessage(id: 'CM004', subject: 'Your Order is Confirmed', type: 'Email', recipient: 'Recent Buyers (312)', status: AppConstants.statusCompleted, sentAt: DateTime(2026, 5, 9, 11, 0), openCount: 298, clickCount: 245),
    CommMessage(id: 'CM005', subject: 'Re-engagement: We miss you!', type: 'Email', recipient: 'Inactive Users (4,500)', status: AppConstants.statusPaused, sentAt: DateTime(2026, 4, 18, 9, 0), openCount: 1240, clickCount: 380),
    CommMessage(id: 'CM006', subject: 'Webinar Reminder — June 5', type: 'Push', recipient: 'Registered Users (320)', status: AppConstants.statusDraft, sentAt: DateTime(2026, 6, 4, 8, 0), openCount: 0, clickCount: 0),
    CommMessage(id: 'CM007', subject: 'Exclusive VIP Offer Inside', type: 'Email', recipient: 'VIP Segment (245)', status: AppConstants.statusActive, sentAt: DateTime(2026, 5, 14, 10, 0), openCount: 198, clickCount: 145),
  ];

  static List<CommMessage> getAll() => List.unmodifiable(_data);
}

// ═══════════════════════════════════════════════════════════════════════════
// AUTOMATION WORKFLOW
// ═══════════════════════════════════════════════════════════════════════════

class WorkflowStep {
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const WorkflowStep({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AutomationWorkflow {
  final String id;
  final String name;
  final String trigger;
  final String status;
  final int totalRuns;
  final int activeContacts;
  final DateTime createdAt;
  final List<WorkflowStep> steps;

  const AutomationWorkflow({
    required this.id,
    required this.name,
    required this.trigger,
    required this.status,
    required this.totalRuns,
    required this.activeContacts,
    required this.createdAt,
    required this.steps,
  });
}

class AutomationRepository {
  static final List<AutomationWorkflow> _data = [
    AutomationWorkflow(
      id: 'WF001',
      name: 'New Lead Welcome Flow',
      trigger: 'New Lead Created',
      status: AppConstants.statusActive,
      totalRuns: 1248,
      activeContacts: 84,
      createdAt: DateTime(2026, 3, 1),
      steps: [
        WorkflowStep(label: 'New Lead', description: 'Trigger: Lead created in system', icon: Icons.person_add_outlined, color: AppColors.primary),
        WorkflowStep(label: 'Wait 1 Day', description: 'Delay for 24 hours', icon: Icons.hourglass_empty_outlined, color: AppColors.textSecondary),
        WorkflowStep(label: 'Send Welcome Email', description: 'Email: Welcome to MarketFlow', icon: Icons.email_outlined, color: AppColors.info),
        WorkflowStep(label: 'Wait 2 Days', description: 'Delay for 48 hours', icon: Icons.hourglass_empty_outlined, color: AppColors.textSecondary),
        WorkflowStep(label: 'Check Email Opened?', description: 'Condition: email_opened = true', icon: Icons.help_outline, color: AppColors.warning),
        WorkflowStep(label: 'Update Lead Status', description: 'Set status → Contacted', icon: Icons.edit_outlined, color: AppColors.success),
      ],
    ),
    AutomationWorkflow(
      id: 'WF002',
      name: 'Purchase Follow-Up',
      trigger: 'Order Completed',
      status: AppConstants.statusActive,
      totalRuns: 520,
      activeContacts: 31,
      createdAt: DateTime(2026, 4, 10),
      steps: [
        WorkflowStep(label: 'Order Completed', description: 'Trigger: purchase confirmed', icon: Icons.shopping_bag_outlined, color: AppColors.success),
        WorkflowStep(label: 'Send Receipt Email', description: 'Email: Order confirmation', icon: Icons.email_outlined, color: AppColors.info),
        WorkflowStep(label: 'Wait 7 Days', description: 'Delay for 7 days', icon: Icons.hourglass_empty_outlined, color: AppColors.textSecondary),
        WorkflowStep(label: 'Send Review Request', description: 'Email: Please review your order', icon: Icons.star_outline, color: AppColors.warning),
        WorkflowStep(label: 'Tag as Buyer', description: 'Add tag: verified_buyer', icon: Icons.label_outlined, color: AppColors.primary),
      ],
    ),
    AutomationWorkflow(
      id: 'WF003',
      name: 'Re-Engagement Campaign',
      trigger: 'No Activity for 90 Days',
      status: AppConstants.statusPaused,
      totalRuns: 312,
      activeContacts: 0,
      createdAt: DateTime(2026, 2, 15),
      steps: [
        WorkflowStep(label: 'Inactive 90 Days', description: 'Trigger: last_activity > 90 days', icon: Icons.timer_off_outlined, color: AppColors.danger),
        WorkflowStep(label: 'Send Win-Back Email', description: 'Email: We miss you + coupon', icon: Icons.email_outlined, color: AppColors.primary),
        WorkflowStep(label: 'Wait 5 Days', description: 'Delay for 5 days', icon: Icons.hourglass_empty_outlined, color: AppColors.textSecondary),
        WorkflowStep(label: 'Check Responded?', description: 'Condition: email_opened = true', icon: Icons.help_outline, color: AppColors.warning),
        WorkflowStep(label: 'Update Status', description: 'Set status → Re-engaged or Inactive', icon: Icons.edit_outlined, color: AppColors.success),
      ],
    ),
    AutomationWorkflow(
      id: 'WF004',
      name: 'Lead Qualification Score',
      trigger: 'Lead Score Updated',
      status: AppConstants.statusActive,
      totalRuns: 890,
      activeContacts: 145,
      createdAt: DateTime(2026, 4, 1),
      steps: [
        WorkflowStep(label: 'Score Updated', description: 'Trigger: lead_score changes', icon: Icons.trending_up_outlined, color: AppColors.info),
        WorkflowStep(label: 'Check Score ≥ 80?', description: 'Condition: score >= 80', icon: Icons.help_outline, color: AppColors.warning),
        WorkflowStep(label: 'Notify Sales Team', description: 'Internal notification to team', icon: Icons.notifications_outlined, color: AppColors.primary),
        WorkflowStep(label: 'Create Opportunity', description: 'Auto-create opportunity record', icon: Icons.add_circle_outline, color: AppColors.success),
      ],
    ),
  ];

  static List<AutomationWorkflow> getAll() => List.unmodifiable(_data);
  static AutomationWorkflow? findById(String id) {
    try { return _data.firstWhere((w) => w.id == id); } catch (_) { return null; }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// USER
// ═══════════════════════════════════════════════════════════════════════════

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String department;
  final DateTime joinDate;
  final String avatarInitials;
  final Color avatarColor;
  final List<String> permissions;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.department,
    required this.joinDate,
    required this.avatarInitials,
    required this.avatarColor,
    required this.permissions,
  });
}

class UserRepository {
  static final List<AppUser> _data = [
    AppUser(id: 'U001', name: 'Hana Tsegaye', email: 'hana.tsegaye@marketflow.et', role: AppConstants.roleMarketingManager, status: AppConstants.statusActive, department: 'Marketing', joinDate: DateTime(2023, 1, 15), avatarInitials: 'HT', avatarColor: AppColors.primary, permissions: ['campaigns', 'customers', 'leads', 'reports', 'users', 'settings']),
    AppUser(id: 'U002', name: 'Sara Mulugeta', email: 'sara.m@marketflow.et', role: AppConstants.roleMarketingClerk, status: AppConstants.statusActive, department: 'Marketing', joinDate: DateTime(2024, 3, 8), avatarInitials: 'SM', avatarColor: AppColors.info, permissions: ['campaigns', 'customers', 'leads', 'content']),
    AppUser(id: 'U003', name: 'Yonas Bekele', email: 'yonas.b@marketflow.et', role: AppConstants.roleMarketingClerk, status: AppConstants.statusActive, department: 'Marketing', joinDate: DateTime(2024, 6, 1), avatarInitials: 'YB', avatarColor: AppColors.success, permissions: ['leads', 'influencers', 'content']),
    AppUser(id: 'U004', name: 'Dawit Tesfaye', email: 'dawit.t@marketflow.et', role: AppConstants.roleMarketingClerk, status: AppConstants.statusPaused, department: 'Marketing', joinDate: DateTime(2024, 9, 15), avatarInitials: 'DT', avatarColor: AppColors.warning, permissions: ['campaigns', 'budget']),
    AppUser(id: 'U005', name: 'Hana Girma', email: 'hana.g@marketflow.et', role: AppConstants.roleMarketingManager, status: AppConstants.statusActive, department: 'Marketing', joinDate: DateTime(2023, 8, 20), avatarInitials: 'HG', avatarColor: AppColors.danger, permissions: ['campaigns', 'customers', 'leads', 'reports', 'budget', 'users']),
  ];

  static List<AppUser> getAll() => List.unmodifiable(_data);
}
