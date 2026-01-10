/// Local element that hasn't been saved to backend yet
/// Used for optimistic UI updates before API confirmation
class LocalElement {
  final String tempId;
  final String subItemId;
  String name;
  String? description;
  String costType;
  double? totalCost;
  double? unitCost;
  double? quantity;
  bool isCompleted;
  DateTime? lastModified;

  LocalElement({
    required this.tempId,
    required this.subItemId,
    this.name = '',
    this.description,
    this.costType = 'UNIT_BASED',
    this.totalCost,
    this.unitCost,
    this.quantity,
    this.isCompleted = false,
    this.lastModified,
  });

  /// Check if element has all required data for saving
  bool get hasRequiredData {
    // Name must be non-empty and have at least 2 characters
    if (name.trim().isEmpty || name.trim().length < 2) return false;

    if (costType == 'UNIT_BASED') {
      // Both unitCost and quantity must be valid positive numbers
      return unitCost != null &&
          quantity != null &&
          unitCost! > 0 &&
          quantity! > 0 &&
          unitCost!.isFinite &&
          quantity!.isFinite;
    } else {
      // Total cost must be valid positive number
      return totalCost != null && totalCost! > 0 && totalCost!.isFinite;
    }
  }

  /// Calculate total cost based on cost type
  double? get calculatedTotalCost {
    if (costType == 'UNIT_BASED' && unitCost != null && quantity != null) {
      return unitCost! * quantity!;
    }
    return totalCost;
  }

  LocalElement copyWith({
    String? name,
    String? description,
    String? costType,
    double? totalCost,
    double? unitCost,
    double? quantity,
    bool? isCompleted,
    DateTime? lastModified,
  }) {
    return LocalElement(
      tempId: tempId,
      subItemId: subItemId,
      name: name ?? this.name,
      description: description ?? this.description,
      costType: costType ?? this.costType,
      totalCost: totalCost ?? this.totalCost,
      unitCost: unitCost ?? this.unitCost,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
