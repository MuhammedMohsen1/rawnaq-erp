import 'pricing_item.dart';

enum ExpenseGroupStatus {
  inProgress,
  completed,
  underPricing,
}

class ExpenseGroup {
  final String id;
  final String name;
  final ExpenseGroupStatus status;
  final List<PricingItem> items;
  final double subtotal;
  final bool isExpanded;

  ExpenseGroup({
    required this.id,
    required this.name,
    required this.status,
    required this.items,
    required this.subtotal,
    this.isExpanded = true,
  });

  ExpenseGroup copyWith({
    String? id,
    String? name,
    ExpenseGroupStatus? status,
    List<PricingItem>? items,
    double? subtotal,
    bool? isExpanded,
  }) {
    return ExpenseGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  double calculateSubtotal() {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }
}

