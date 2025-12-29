import 'wall_pricing.dart';
import 'expense_group.dart';

class PricingData {
  final String projectId;
  final String projectName;
  final String clientName;
  final String startDate;
  final List<ExpenseGroup> expenseGroups; // Groups without images
  final List<WallPricing> walls; // Groups with images
  final double grandTotal;
  final String? lastSaveTime;

  PricingData({
    required this.projectId,
    required this.projectName,
    required this.clientName,
    required this.startDate,
    required this.expenseGroups,
    required this.walls,
    required this.grandTotal,
    this.lastSaveTime,
  });

  PricingData copyWith({
    String? projectId,
    String? projectName,
    String? clientName,
    String? startDate,
    List<ExpenseGroup>? expenseGroups,
    List<WallPricing>? walls,
    double? grandTotal,
    String? lastSaveTime,
  }) {
    return PricingData(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      startDate: startDate ?? this.startDate,
      expenseGroups: expenseGroups ?? this.expenseGroups,
      walls: walls ?? this.walls,
      grandTotal: grandTotal ?? this.grandTotal,
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
    );
  }

  double calculateGrandTotal() {
    final expenseGroupsTotal = expenseGroups.fold(0.0, (sum, group) => sum + group.subtotal);
    final wallsTotal = walls.fold(0.0, (sum, wall) => sum + wall.subtotal);
    return expenseGroupsTotal + wallsTotal;
  }
}

