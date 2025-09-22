class Incident {
  final String title;
  final String riskLevel;
  final RiskLevel risk;

  Incident({
    required this.title,
    required this.riskLevel,
    required this.risk,
  });
}

enum RiskLevel {
  high,
  medium,
  low,
}
