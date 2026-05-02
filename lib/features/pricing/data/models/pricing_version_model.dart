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
  final double originalTotalAmount;
  final double deductionAmount;
  final double totalAmountAfterDeduction;
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
    required this.originalTotalAmount,
    required this.deductionAmount,
    required this.totalAmountAfterDeduction,
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

    final totalPrice = _toDoubleOrZero(json['totalPrice']);
    final originalTotalAmount = json.containsKey('originalTotalAmount')
        ? _toDoubleOrZero(json['originalTotalAmount'])
        : totalPrice;
    final deductionAmount = json.containsKey('deductionAmount')
        ? _toDoubleOrZero(json['deductionAmount'])
        : 0.0;
    final totalAmountAfterDeduction =
        json.containsKey('totalAmountAfterDeduction')
        ? _toDoubleOrZero(json['totalAmountAfterDeduction'])
        : (originalTotalAmount - deductionAmount);

    return PricingVersionModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      version: json['version'] is int
          ? json['version'] as int
          : int.tryParse(json['version'].toString()) ?? 0,
      status: json['status'] as String,
      totalCost: _toDoubleOrZero(json['totalCost']),
      totalProfit: _toDoubleOrZero(json['totalProfit']),
      totalPrice: totalPrice,
      originalTotalAmount: originalTotalAmount,
      deductionAmount: deductionAmount,
      totalAmountAfterDeduction: totalAmountAfterDeduction < 0
          ? 0
          : totalAmountAfterDeduction,
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
      'originalTotalAmount': originalTotalAmount,
      'deductionAmount': deductionAmount,
      'totalAmountAfterDeduction': totalAmountAfterDeduction,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  PricingVersionModel copyWith({
    String? id,
    String? projectId,
    int? version,
    String? status,
    double? totalCost,
    double? totalProfit,
    double? totalPrice,
    double? originalTotalAmount,
    double? deductionAmount,
    double? totalAmountAfterDeduction,
    String? notes,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PricingItemModel>? items,
  }) {
    return PricingVersionModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      version: version ?? this.version,
      status: status ?? this.status,
      totalCost: totalCost ?? this.totalCost,
      totalProfit: totalProfit ?? this.totalProfit,
      totalPrice: totalPrice ?? this.totalPrice,
      originalTotalAmount: originalTotalAmount ?? this.originalTotalAmount,
      deductionAmount: deductionAmount ?? this.deductionAmount,
      totalAmountAfterDeduction:
          totalAmountAfterDeduction ?? this.totalAmountAfterDeduction,
      notes: notes ?? this.notes,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

/// Model for Pricing Item
class PricingItemModel {
  final String id;
  final String pricingVersionId;
  final String name;
  final bool isHidden;

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
    required this.isHidden,
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
      isHidden: json['isHidden'] as bool,
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
      'isHidden': isHidden,
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

  PricingItemModel copyWith({
    String? id,
    String? pricingVersionId,
    String? name,
    bool? isHidden,
    String? description,
    double? profitMargin,
    double? profitAmount,
    double? totalCost,
    double? totalPrice,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PricingSubItemModel>? subItems,
  }) {
    return PricingItemModel(
      id: id ?? this.id,
      pricingVersionId: pricingVersionId ?? this.pricingVersionId,
      name: name ?? this.name,
      description: description ?? this.description,
      isHidden: isHidden ?? this.isHidden,
      profitMargin: profitMargin ?? this.profitMargin,
      profitAmount: profitAmount ?? this.profitAmount,
      totalCost: totalCost ?? this.totalCost,
      totalPrice: totalPrice ?? this.totalPrice,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subItems: subItems ?? this.subItems,
    );
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
  final bool isHidden;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PricingElementModel>? elements;

  PricingSubItemModel({
    required this.id,
    required this.pricingItemId,
    required this.name,
    this.description,
    required this.isHidden,
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
      isHidden: json['isHidden'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pricingItemId': pricingItemId,
      'name': name,
      'description': description,
      'notes': notes,
      'isHidden': isHidden,
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

  PricingSubItemModel copyWith({
    String? id,
    String? pricingItemId,
    String? name,
    String? description,
    String? notes,
    List<String>? images,
    double? profitMargin,
    double? profitAmount,
    double? totalCost,
    double? totalPrice,
    bool? isHidden,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PricingElementModel>? elements,
  }) {
    return PricingSubItemModel(
      id: id ?? this.id,
      pricingItemId: pricingItemId ?? this.pricingItemId,
      name: name ?? this.name,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      profitMargin: profitMargin ?? this.profitMargin,
      profitAmount: profitAmount ?? this.profitAmount,
      totalCost: totalCost ?? this.totalCost,
      totalPrice: totalPrice ?? this.totalPrice,
      isHidden: isHidden ?? this.isHidden,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      elements: elements ?? this.elements,
    );
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
  final bool isHidden;
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
    this.isHidden = false,
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
      isHidden: json['isHidden'] as bool? ?? false,
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
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PricingElementModel copyWith({
    String? id,
    String? pricingSubItemId,
    String? name,
    String? description,
    String? costType,
    double? totalCost,
    double? unitCost,
    double? quantity,
    double? calculatedCost,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PricingElementModel(
      id: id ?? this.id,
      pricingSubItemId: pricingSubItemId ?? this.pricingSubItemId,
      name: name ?? this.name,
      description: description ?? this.description,
      costType: costType ?? this.costType,
      totalCost: totalCost ?? this.totalCost,
      unitCost: unitCost ?? this.unitCost,
      quantity: quantity ?? this.quantity,
      calculatedCost: calculatedCost ?? this.calculatedCost,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
