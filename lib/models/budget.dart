class Budget {
  final int id;
  final int campaignId;
  final double allocatedAmount;
  final double spentAmount;
  final DateTime date;

  Budget({
    required this.id,
    required this.campaignId,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.date,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
}