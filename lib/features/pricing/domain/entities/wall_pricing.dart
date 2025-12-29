import 'pricing_item.dart';

enum WallStatus {
  inProgress,
  completed,
  underPricing,
}

class WallPricing {
  final String id;
  final String name;
  final WallStatus status;
  final List<PricingItem> items;
  final List<String> imageUrls;
  final double subtotal;
  final bool isExpanded;

  WallPricing({
    required this.id,
    required this.name,
    required this.status,
    required this.items,
    required this.imageUrls,
    required this.subtotal,
    this.isExpanded = true,
  });

  WallPricing copyWith({
    String? id,
    String? name,
    WallStatus? status,
    List<PricingItem>? items,
    List<String>? imageUrls,
    double? subtotal,
    bool? isExpanded,
  }) {
    return WallPricing(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      items: items ?? this.items,
      imageUrls: imageUrls ?? this.imageUrls,
      subtotal: subtotal ?? this.subtotal,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  double calculateSubtotal() {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }
}

