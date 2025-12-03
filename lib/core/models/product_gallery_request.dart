import 'package:equatable/equatable.dart';

/// Represents the moderation status of a gallery request.
enum GalleryRequestStatus { pending, approved, rejected, unknown }

extension GalleryRequestStatusX on GalleryRequestStatus {
  static GalleryRequestStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return GalleryRequestStatus.pending;
      case 'APPROVED':
        return GalleryRequestStatus.approved;
      case 'REJECTED':
        return GalleryRequestStatus.rejected;
      default:
        return GalleryRequestStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case GalleryRequestStatus.pending:
        return 'قيد المراجعة';
      case GalleryRequestStatus.approved:
        return 'مقبول';
      case GalleryRequestStatus.rejected:
        return 'مرفوض';
      case GalleryRequestStatus.unknown:
        return 'غير معروف';
    }
  }
}

Map<String, dynamic> _extractMapFrom(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  return const {};
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    // Assume value is milliseconds since epoch
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String && value.isNotEmpty) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Basic representation for a gallery request.
class ProductGalleryRequest extends Equatable {
  final String id;
  final String title;
  final GalleryRequestStatus status;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? martId;
  final String? martName;
  final String? submittedById;
  final String? submittedByName;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedByName;
  final String? tempImageUrl;
  final String? finalImageUrl;
  final String? rejectionReason;
  final String? name;
  final String? barcode;
  final double? sellPrice;
  final double? costPrice;
  final int? quantity;
  final String? quantityType;
  final String? unitType;
  final String? unitLabel;
  final int? unitPrecision;
  final double? minimumWeight;
  final double? incrementStep;
  final int? packSizeValue;
  final String? packSizeUnit;
  final Map<String, dynamic>? measurementInfo;
  final Map<String, dynamic>? weightInfo;
  final String? approvedMartProductId;
  final Map<String, dynamic>? approvedMartProduct;
  final Map<String, dynamic>? raw;

  const ProductGalleryRequest({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.categoryId,
    this.categoryName,
    this.martId,
    this.martName,
    this.submittedById,
    this.submittedByName,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedByName,
    this.tempImageUrl,
    this.finalImageUrl,
    this.rejectionReason,
    this.name,
    this.barcode,
    this.sellPrice,
    this.costPrice,
    this.quantity,
    this.quantityType,
    this.unitType,
    this.unitLabel,
    this.unitPrecision,
    this.minimumWeight,
    this.incrementStep,
    this.packSizeValue,
    this.packSizeUnit,
    this.measurementInfo,
    this.weightInfo,
    this.approvedMartProductId,
    this.approvedMartProduct,
    this.raw,
  });

  factory ProductGalleryRequest.fromJson(Map<String, dynamic> json) {
    final category = _extractMapFrom(json, 'category');
    final mart = _extractMapFrom(json, 'mart');
    final martAdmin = _extractMapFrom(json, 'martAdmin');
    final submittedBy = _extractMapFrom(json, 'submittedBy');
    final reviewedBy = _extractMapFrom(json, 'reviewedBy');
    final approvedProduct = _extractMapFrom(json, 'approvedMartProduct');

    final status = GalleryRequestStatusX.fromString(json['status']?.toString());

    // Use 'name' as title if 'title' is not provided
    final title = json['title']?.toString() ?? json['name']?.toString() ?? '';

    // Build full category path from nested structure
    String? categoryPath;
    if (category.isNotEmpty) {
      final categoryNames = <String>[];

      // Start with the deepest category
      var currentCategory = category;
      while (currentCategory.isNotEmpty && currentCategory['name'] != null) {
        categoryNames.insert(0, currentCategory['name'].toString());
        currentCategory = _extractMapFrom(currentCategory, 'parentCategory');
      }

      if (categoryNames.isNotEmpty) {
        categoryPath = categoryNames.join(' > ');
      }
    }

    return ProductGalleryRequest(
      id: json['id']?.toString() ?? '',
      title: title,
      status: status,
      description: json['description']?.toString(),
      categoryId: category['id']?.toString() ?? json['categoryId']?.toString(),
      categoryName:
          categoryPath ??
          category['name']?.toString() ??
          json['categoryName']?.toString(),
      martId: mart['id']?.toString() ?? json['martId']?.toString(),
      martName: mart['name']?.toString() ?? json['martName']?.toString(),
      submittedById:
          martAdmin['id']?.toString() ??
          submittedBy['id']?.toString() ??
          json['martAdminId']?.toString() ??
          json['submittedById']?.toString(),
      submittedByName:
          martAdmin['name']?.toString() ??
          submittedBy['name']?.toString() ??
          json['submittedByName']?.toString(),
      submittedAt: _parseDate(json['submittedAt'] ?? json['createdAt']),
      reviewedAt: _parseDate(json['reviewedAt'] ?? json['updatedAt']),
      reviewedByName:
          reviewedBy['name']?.toString() ?? json['reviewedByName']?.toString(),
      tempImageUrl:
          json['tempImageUrl']?.toString() ?? json['imageUrl']?.toString(),
      finalImageUrl:
          json['finalImageUrl']?.toString() ??
          json['approvedImageUrl']?.toString() ??
          _extractMapFrom(json, 'approvedGalleryItem')['imageUrl']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      name: json['name']?.toString(),
      barcode: json['barcode']?.toString(),
      sellPrice: _toDouble(json['sellPrice'] ?? json['price']),
      costPrice: _toDouble(json['costPrice']),
      quantity: _toInt(json['quantity'] ?? json['stockQuantity']),
      quantityType: json['quantityType']?.toString(),
      unitType: json['unitType']?.toString(),
      unitLabel: json['unitLabel']?.toString(),
      unitPrecision: _toInt(json['unitPrecision']),
      minimumWeight: _toDouble(json['minimumWeight']),
      incrementStep: _toDouble(json['incrementStep']),
      packSizeValue: _toInt(json['packSizeValue']),
      packSizeUnit: json['packSizeUnit']?.toString(),
      measurementInfo: json['measurementInfo'] != null
          ? Map<String, dynamic>.from(json['measurementInfo'])
          : null,
      weightInfo: json['weightInfo'] != null
          ? Map<String, dynamic>.from(json['weightInfo'])
          : null,
      approvedMartProductId:
          json['approvedMartProductId']?.toString() ??
          approvedProduct['id']?.toString(),
      approvedMartProduct: approvedProduct.isEmpty ? null : approvedProduct,
      raw: json,
    );
  }

  ProductGalleryRequest copyWith({
    GalleryRequestStatus? status,
    String? rejectionReason,
    String? finalImageUrl,
    String? reviewedByName,
    DateTime? reviewedAt,
    String? approvedMartProductId,
    Map<String, dynamic>? approvedMartProduct,
    String? unitType,
    String? unitLabel,
    int? unitPrecision,
    double? minimumWeight,
    double? incrementStep,
    int? packSizeValue,
    String? packSizeUnit,
    Map<String, dynamic>? measurementInfo,
    Map<String, dynamic>? weightInfo,
  }) => ProductGalleryRequest(
    id: id,
    title: title,
    status: status ?? this.status,
    description: description,
    categoryId: categoryId,
    categoryName: categoryName,
    martId: martId,
    martName: martName,
    submittedById: submittedById,
    submittedByName: submittedByName,
    submittedAt: submittedAt,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    reviewedByName: reviewedByName ?? this.reviewedByName,
    tempImageUrl: tempImageUrl,
    finalImageUrl: finalImageUrl ?? this.finalImageUrl,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    name: name,
    barcode: barcode,
    sellPrice: sellPrice,
    costPrice: costPrice,
    quantity: quantity,
    quantityType: quantityType,
    unitType: unitType ?? this.unitType,
    unitLabel: unitLabel ?? this.unitLabel,
    unitPrecision: unitPrecision ?? this.unitPrecision,
    minimumWeight: minimumWeight ?? this.minimumWeight,
    incrementStep: incrementStep ?? this.incrementStep,
    packSizeValue: packSizeValue ?? this.packSizeValue,
    packSizeUnit: packSizeUnit ?? this.packSizeUnit,
    measurementInfo: measurementInfo ?? this.measurementInfo,
    weightInfo: weightInfo ?? this.weightInfo,
    approvedMartProductId: approvedMartProductId ?? this.approvedMartProductId,
    approvedMartProduct: approvedMartProduct ?? this.approvedMartProduct,
    raw: raw,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    description,
    categoryId,
    categoryName,
    martId,
    martName,
    submittedById,
    submittedByName,
    submittedAt,
    reviewedAt,
    reviewedByName,
    tempImageUrl,
    finalImageUrl,
    rejectionReason,
    name,
    barcode,
    sellPrice,
    costPrice,
    quantity,
    quantityType,
    unitType,
    unitLabel,
    unitPrecision,
    minimumWeight,
    incrementStep,
    packSizeValue,
    packSizeUnit,
    measurementInfo,
    weightInfo,
    approvedMartProductId,
    approvedMartProduct,
  ];
}

/// Container for paginated results.
class GalleryRequestListResult extends Equatable {
  final List<ProductGalleryRequest> items;
  final int? total;
  final int? page;
  final int? pageSize;

  const GalleryRequestListResult({
    required this.items,
    this.total,
    this.page,
    this.pageSize,
  });

  factory GalleryRequestListResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;

    // Handle case where data is directly an array
    final itemsJson = json['data'] ?? root['items'] ?? root['requests'];
    final List<ProductGalleryRequest> items = (itemsJson is List)
        ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(ProductGalleryRequest.fromJson)
              .toList()
        : [];

    // Extract pagination info from separate pagination object or root
    final pagination = _extractMapFrom(json, 'pagination');
    final meta = _extractMapFrom(json, 'meta');

    final total = pagination['total'] ?? meta['total'] ?? root['total'];
    final page = pagination['page'] ?? meta['page'] ?? root['page'];
    final pageSize =
        pagination['pageSize'] ?? meta['pageSize'] ?? root['pageSize'];

    return GalleryRequestListResult(
      items: items,
      total: _toInt(total),
      page: _toInt(page),
      pageSize: _toInt(pageSize),
    );
  }

  GalleryRequestListResult copyWith({
    List<ProductGalleryRequest>? items,
    int? total,
    int? page,
    int? pageSize,
  }) => GalleryRequestListResult(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [items, total, page, pageSize];
}
