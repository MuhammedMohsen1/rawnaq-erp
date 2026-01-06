import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';
import '../models/pricing_version_model.dart';

/// API data source for pricing
class PricingApiDataSource {
  final ApiClient _apiClient;

  PricingApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all pricing versions for a project
  Future<List<PricingVersionModel>> getPricingVersions(String projectId) async {
    final response = await _apiClient.get(
      ApiEndpoints.pricingVersions(projectId),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as List;

    return data
        .map(
          (json) => PricingVersionModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get a specific pricing version with all items
  Future<PricingVersionModel> getPricingVersion(
    String projectId,
    int version,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.pricingVersion(projectId, version),
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Create a new pricing version
  Future<PricingVersionModel> createPricingVersion(
    String projectId, {
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.pricingVersions(projectId),
      data: {if (notes != null) 'notes': notes},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Add a pricing item
  Future<PricingItemModel> addPricingItem(
    String projectId,
    int version, {
    required String name,
    String? description,
    int? order,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.pricingItems(projectId, version),
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingItemModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Add a pricing sub-item
  Future<PricingSubItemModel> addPricingSubItem(
    String projectId,
    int version,
    String itemId, {
    required String name,
    String? description,
    int? order,
  }) async {
    final endpoint = ApiEndpoints.pricingSubItems(projectId, version, itemId);
    print('Adding sub-item to endpoint: $endpoint');
    print(
      'Parameters: projectId=$projectId, version=$version, itemId=$itemId, name=$name',
    );

    try {
      final response = await _apiClient.post(
        endpoint,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (order != null) 'order': order,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['data'] == null) {
        throw Exception('Invalid response format: missing data field');
      }

      return PricingSubItemModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error in addPricingSubItem: $e');
      print('Endpoint used: $endpoint');

      // Provide more user-friendly error messages
      if (e.toString().contains('NotFoundException') ||
          e.toString().contains('NOT_FOUND')) {
        throw Exception(
          'لا يمكن إضافة فئة فرعية. يرجى التحقق من أن:\n'
          '1. المشروع موجود\n'
          '2. إصدار التسعير في حالة "مسودة" (DRAFT)\n'
          '3. الفئة موجودة في هذا الإصدار',
        );
      }
      rethrow;
    }
  }

  /// Upload images to a pricing sub-item
  /// imagePaths: List of file paths (for desktop/mobile)
  /// imageBytes: Optional list of (bytes, filename) tuples (for web)
  Future<PricingSubItemModel> uploadSubItemImages(
    String projectId,
    int version,
    String itemId,
    String subItemId,
    List<String> imagePaths, {
    List<MapEntry<String, List<int>>>? imageBytes,
  }) async {
    if (imagePaths.isEmpty && (imageBytes == null || imageBytes.isEmpty)) {
      throw Exception('No image paths or bytes provided');
    }

    final formData = FormData();

    // Add files from paths (desktop/mobile)
    for (var imagePath in imagePaths) {
      print('Adding image to FormData: $imagePath');
      final fileName = imagePath.split('/').last;
      try {
        final multipartFile = await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        );
        formData.files.add(MapEntry('images', multipartFile));
        print('Successfully added image: $fileName');
      } catch (e) {
        print('Error adding image $imagePath: $e');
        throw Exception('Failed to read image file: $imagePath. Error: $e');
      }
    }

    // Add files from bytes (web)
    if (imageBytes != null) {
      for (var entry in imageBytes) {
        final fileName = entry.key;
        final bytes = entry.value;
        print('Adding image from bytes: $fileName (${bytes.length} bytes)');
        try {
          final multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
          formData.files.add(MapEntry('images', multipartFile));
          print('Successfully added image from bytes: $fileName');
        } catch (e) {
          print('Error adding image from bytes $fileName: $e');
          throw Exception(
            'Failed to create multipart file from bytes: $fileName. Error: $e',
          );
        }
      }
    }

    final endpoint = ApiEndpoints.pricingSubItemImages(
      projectId,
      version,
      itemId,
      subItemId,
    );
    print('Uploading ${formData.files.length} images to endpoint: $endpoint');
    print(
      'Parameters: projectId=$projectId, version=$version, itemId=$itemId, subItemId=$subItemId',
    );

    try {
      final response = await _apiClient.uploadFile(
        endpoint,
        formData: formData,
      );

      print('Upload response received with status: ${response.statusCode}');
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['data'] == null) {
        throw Exception('Invalid response format: missing data field');
      }

      return PricingSubItemModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error in uploadSubItemImages: $e');
      print('Endpoint used: $endpoint');

      // Provide more user-friendly error messages
      if (e.toString().contains('NotFoundException') ||
          e.toString().contains('NOT_FOUND')) {
        throw Exception(
          'لا يمكن رفع الصور. يرجى التحقق من أن:\n'
          '1. المشروع موجود\n'
          '2. إصدار التسعير في حالة "مسودة" (DRAFT)\n'
          '3. الفئة والفئة الفرعية موجودة في هذا الإصدار',
        );
      }
      rethrow;
    }
  }

  /// Delete an image from a pricing sub-item
  Future<PricingSubItemModel> deleteSubItemImage(
    String projectId,
    int version,
    String itemId,
    String subItemId,
    String imageUrl,
  ) async {
    final response = await _apiClient.delete(
      ApiEndpoints.deletePricingSubItemImage(
        projectId,
        version,
        itemId,
        subItemId,
      ),
      data: {'imageUrl': imageUrl},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingSubItemModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Add a pricing element
  Future<PricingElementModel> addPricingElement(
    String projectId,
    int version,
    String itemId,
    String subItemId, {
    required String name,
    String? description,
    required String costType, // TOTAL or UNIT_BASED
    double? totalCost,
    double? unitCost,
    double? quantity,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.pricingElements(projectId, version, itemId, subItemId),
      data: {
        'name': name,
        if (description != null) 'description': description,
        'costType': costType,
        if (totalCost != null) 'totalCost': totalCost,
        if (unitCost != null) 'unitCost': unitCost,
        if (quantity != null) 'quantity': quantity,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingElementModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Update a pricing item
  Future<PricingItemModel> updatePricingItem(
    String projectId,
    int version,
    String itemId, {
    String? name,
    String? description,
    double? profitMargin,
    int? order,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.pricingItem(projectId, version, itemId),
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (profitMargin != null) 'profitMargin': profitMargin,
        if (order != null) 'order': order,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingItemModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Delete a pricing item
  Future<void> deletePricingItem(
    String projectId,
    int version,
    String itemId,
  ) async {
    await _apiClient.delete(
      ApiEndpoints.pricingItem(projectId, version, itemId),
    );
  }

  /// Update a pricing element
  Future<PricingElementModel> updatePricingElement(
    String projectId,
    int version,
    String itemId,
    String subItemId,
    String elementId, {
    String? name,
    String? description,
    String? costType,
    double? totalCost,
    double? unitCost,
    double? quantity,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.pricingElement(
        projectId,
        version,
        itemId,
        subItemId,
        elementId,
      ),
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (costType != null) 'costType': costType,
        if (totalCost != null) 'totalCost': totalCost,
        if (unitCost != null) 'unitCost': unitCost,
        if (quantity != null) 'quantity': quantity,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingElementModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Delete a pricing element
  Future<void> deletePricingElement(
    String projectId,
    int version,
    String itemId,
    String subItemId,
    String elementId,
  ) async {
    await _apiClient.delete(
      ApiEndpoints.pricingElement(
        projectId,
        version,
        itemId,
        subItemId,
        elementId,
      ),
    );
  }

  /// Calculate profit for pricing version
  Future<PricingVersionModel> calculateProfit(
    String projectId,
    int version, {
    required List<Map<String, dynamic>>
    items, // [{itemId: string, profitMargin: number}]
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.calculateProfit(projectId, version),
      data: {'items': items, if (notes != null) 'notes': notes},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Submit pricing for approval
  Future<PricingVersionModel> submitForApproval(
    String projectId,
    int version, {
    String? comments,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.submitForApproval(projectId, version),
      data: {if (comments != null) 'comments': comments},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Approve pricing
  Future<PricingVersionModel> approvePricing(
    String projectId,
    int version, {
    String? comments,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.approvePricing(projectId, version),
      data: {if (comments != null) 'comments': comments},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Reject pricing
  Future<PricingVersionModel> rejectPricing(
    String projectId,
    int version, {
    String? comments,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.rejectPricing(projectId, version),
      data: {if (comments != null) 'comments': comments},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Return pricing from PENDING_APPROVAL or PROFIT_PENDING to DRAFT for editing
  Future<PricingVersionModel> returnToPricing(
    String projectId,
    int version, {
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.returnToPricing(projectId, version),
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Calculate profit for SubItems (when status is APPROVED)
  Future<PricingVersionModel> calculateProfitForSubItems(
    String projectId,
    int version, {
    required List<Map<String, dynamic>>
    items, // [{subItemId: string, profitMargin: number}]
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.calculateSubItemProfit(projectId, version),
      data: {'items': items, if (notes != null) 'notes': notes},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Confirm pricing (creates contract and moves project to EXECUTION)
  Future<PricingVersionModel> confirmPricing(
    String projectId,
    int version, {
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.confirmPricing(projectId, version),
      data: {if (notes != null) 'notes': notes},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingVersionModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Update sub-item profit margin
  Future<PricingSubItemModel> updateSubItemProfitMargin(
    String projectId,
    int version,
    String itemId,
    String subItemId,
    double profitMargin,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.updateSubItemProfitMargin(
        projectId,
        version,
        itemId,
        subItemId,
      ),
      data: {'profitMargin': profitMargin},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PricingSubItemModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  /// Export pricing PDF
  Future<Uint8List> exportPricingPdf(String projectId, int version) async {
    final response = await _apiClient.get(
      ApiEndpoints.exportPricingPdf(projectId, version),
      options: Options(responseType: ResponseType.bytes),
    );

    return response.data as Uint8List;
  }

  Future<void> deleteItem(String projectId, int version, String itemId) async {
    await _apiClient.delete(
      ApiEndpoints.deletePricingItem(projectId, version, itemId),
    );
  }

  Future<void> deleteSubItem(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) async {
    await _apiClient.delete(
      ApiEndpoints.deletePricingSubItem(projectId, version, itemId, subItemId),
    );
  }
}
