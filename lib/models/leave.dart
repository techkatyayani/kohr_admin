class Leave {
  final double accrued;
  final double used;
  final double requested;
  final String accruedDisplay;

  Leave({
    required this.accrued,
    required this.used,
    required this.requested,
    required this.accruedDisplay,
  });

  factory Leave.fromMap(Map<String, dynamic> map) {
    return Leave(
      accrued: (map['accrued'] ?? 0.0).toDouble(),
      used: (map['used'] ?? 0.0).toDouble(),
      requested: (map['requested'] ?? 0.0).toDouble(),
      accruedDisplay: map['accruedDisplay'] ?? '0.0',
    );
  }
}
