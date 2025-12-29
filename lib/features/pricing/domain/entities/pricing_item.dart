class PricingItem {
  final String id;
  final String description;
  final double? quantity;
  final double? unitPrice;
  final double total;

  PricingItem({
    required this.id,
    required this.description,
    this.quantity,
    this.unitPrice,
    required this.total,
  });

  PricingItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? total,
  }) {
    return PricingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
    );
  }

  double calculateTotal() {
    if (quantity == null || unitPrice == null) return 0.0;
    return quantity! * unitPrice!;
  }
}

