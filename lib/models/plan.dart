class PlanModel {
  final int id;
  final String name;
  final String description;
  final double priceInr;
  final int durationDays;
  final List<String> features;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInr,
    required this.durationDays,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceInr: (json['price_inr'] as num).toDouble(),
      durationDays: json['duration_days'] ?? 30,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}
