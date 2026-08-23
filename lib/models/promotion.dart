class Promotion {
  final int id;
  final String title;
  final String description;
  final double discount;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}