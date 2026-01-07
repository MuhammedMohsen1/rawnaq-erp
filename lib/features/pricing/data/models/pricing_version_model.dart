/// Model for Pricing Version
class PricingVersionModel {
  final String id;
  final String projectId;
  final int version;
  final String
  status; // DRAFT, PENDING_SIGNATURE, PENDING_APPROVAL, APPROVED, REJECTED
  final double totalCost;
  final double totalProfit;
  final double totalPrice;
  final String? notes;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PricingItemModel>? items;

  PricingVersionModel({
    required this.id,
    required this.projectId,
    required this.version,
    required this.status,
    required this.totalCost,
    required this.totalProfit,
    required this.totalPrice,
    this.notes,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory PricingVersionModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double _toDoubleOrZero(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return PricingVersionModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      version: json['version'] is int
          ? json['version'] as int
          : int.tryParse(json['version'].toString()) ?? 0,
      status: json['status'] as String,
      totalCost: _toDoubleOrZero(json['totalCost']),
      totalProfit: _toDoubleOrZero(json['totalProfit']),
      totalPrice: _toDoubleOrZero(json['totalPrice']),
      notes: json['notes'] as String?,
      createdById: json['createdById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
                .map(
                  (item) =>
                      PricingItemModel.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'version': version,
      'status': status,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
      'totalPrice': totalPrice,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model for Pricing Item
class PricingItemModel {
  final String id;
  final String pricingVersionId;
  final String name;
  final String? description;
  final double profitMargin;
  final double profitAmount;
  final double totalCost;
  final double totalPrice;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PricingSubItemModel>? subItems;

  PricingItemModel({
    required this.id,
    required this.pricingVersionId,
    required this.name,
    this.description,
    required this.profitMargin,
    required this.profitAmount,
    required this.totalCost,
    required this.totalPrice,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.subItems,
  });

  factory PricingItemModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double _toDoubleOrZero(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    int _toIntOrZero(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return PricingItemModel(
      id: json['id'] as String,
      pricingVersionId: json['pricingVersionId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      profitMargin: _toDoubleOrZero(json['profitMargin']),
      profitAmount: _toDoubleOrZero(json['profitAmount']),
      totalCost: _toDoubleOrZero(json['totalCost']),
      totalPrice: _toDoubleOrZero(json['totalPrice']),
      order: _toIntOrZero(json['order']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      subItems: json['subItems'] != null
          ? (json['subItems'] as List)
                .map(
                  (subItem) => PricingSubItemModel.fromJson(
                    subItem as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pricingVersionId': pricingVersionId,
      'name': name,
      'description': description,
      'profitMargin': profitMargin,
      'profitAmount': profitAmount,
      'totalCost': totalCost,
      'totalPrice': totalPrice,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subItems': subItems?.map((subItem) => subItem.toJson()).toList(),
    };
  }
}

/// Model for Pricing Sub Item
class PricingSubItemModel {
  final String id;
  final String pricingItemId;
  final String name;
  final String? description;
  final String? notes;
  final List<String> images;
  final double profitMargin;
  final double profitAmount;
  final double totalCost;
  final double totalPrice;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PricingElementModel>? elements;

  PricingSubItemModel({
    required this.id,
    required this.pricingItemId,
    required this.name,
    this.description,
    this.notes,
    this.images = const [],
    this.profitMargin = 0.0,
    this.profitAmount = 0.0,
    this.totalCost = 0.0,
    this.totalPrice = 0.0,
    required this.order,
    required this.createdAt,
    this.updatedAt,
    this.elements,
  });

  factory PricingSubItemModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int _toIntOrZero(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    // Helper function to safely convert to double
    double _toDoubleOrZero(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return PricingSubItemModel(
      id: json['id'] as String,
      pricingItemId: json['pricingItemId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : [],
      profitMargin: _toDoubleOrZero(json['profitMargin']),
      profitAmount: _toDoubleOrZero(json['profitAmount']),
      totalCost: _toDoubleOrZero(json['totalCost']),
      totalPrice: _toDoubleOrZero(json['totalPrice']),
      order: _toIntOrZero(json['order']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      elements: json['elements'] != null
          ? (json['elements'] as List)
                .map(
                  (element) => PricingElementModel.fromJson(
                    element as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pricingItemId': pricingItemId,
      'name': name,
      'description': description,
      'notes': notes,
      'images': images,
      'profitMargin': profitMargin,
      'profitAmount': profitAmount,
      'totalCost': totalCost,
      'totalPrice': totalPrice,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'elements': elements?.map((element) => element.toJson()).toList(),
    };
  }
}

/// Model for Pricing Element
class PricingElementModel {
  final String id;
  final String pricingSubItemId;
  final String name;
  final String? description;
  final String costType; // TOTAL or UNIT_BASED
  final double? totalCost;
  final double? unitCost;
  final double? quantity;
  final double calculatedCost;
  final DateTime createdAt;
  final DateTime updatedAt;

  PricingElementModel({
    required this.id,
    required this.pricingSubItemId,
    required this.name,
    this.description,
    required this.costType,
    this.totalCost,
    this.unitCost,
    this.quantity,
    required this.calculatedCost,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PricingElementModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    double _toDoubleOrZero(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return PricingElementModel(
      id: json['id'] as String,
      pricingSubItemId: json['pricingSubItemId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      costType: json['costType'] as String,
      totalCost: _toDouble(json['totalCost']),
      unitCost: _toDouble(json['unitCost']),
      quantity: _toDouble(json['quantity']),
      calculatedCost: _toDoubleOrZero(json['calculatedCost']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pricingSubItemId': pricingSubItemId,
      'name': name,
      'description': description,
      'costType': costType,
      'totalCost': totalCost,
      'unitCost': unitCost,
      'quantity': quantity,
      'calculatedCost': calculatedCost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
