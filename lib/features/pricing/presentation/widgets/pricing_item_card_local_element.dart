/// Local element that hasn't been saved to backend yet
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
    this.costType = 'TOTAL',
    this.totalCost,
    this.unitCost,
    this.quantity,
    this.isCompleted = false,
    this.lastModified,
  });

  bool get hasRequiredData {
    final hasName = name.trim().isNotEmpty;
    final hasTotalCost = costType == 'TOTAL' && (totalCost ?? 0) > 0;
    final hasUnitBasedCost =
        costType == 'UNIT_BASED' && (unitCost ?? 0) > 0 && (quantity ?? 0) > 0;

    return hasName || hasTotalCost || hasUnitBasedCost;
  }

  bool get isEmpty => !hasRequiredData;
}
