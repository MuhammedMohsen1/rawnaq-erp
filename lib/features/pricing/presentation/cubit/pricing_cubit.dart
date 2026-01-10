import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/pricing_api_datasource.dart';
import '../../data/models/pricing_version_model.dart';
import '../../../contracts/data/datasources/contracts_api_datasource.dart';
import 'pricing_state.dart';

/// Cubit for managing pricing state
class PricingCubit extends Cubit<PricingState> {
  final PricingApiDataSource pricingApiDataSource;
  final ContractsApiDataSource contractsApiDataSource;

  PricingCubit({
    required this.pricingApiDataSource,
    required this.contractsApiDataSource,
  }) : super(const PricingInitial());

  /// Load pricing data for a project
  Future<void> loadPricingData(String projectId) async {
    // Preserve existing state if reloading
    Map<String, bool> preservedItemStates = {};
    Map<String, Map<String, bool>> preservedSubItemStates = {};
    Map<String, double> preservedProfitMargins = {};

    final currentState = state;
    if (currentState is PricingLoaded) {
      preservedItemStates = Map.from(currentState.itemExpandedStates);
      preservedSubItemStates = {};
      for (var entry in currentState.subItemExpandedStates.entries) {
        preservedSubItemStates[entry.key] = Map.from(entry.value);
      }
      preservedProfitMargins = Map.from(currentState.subItemProfitMargins);
    }

    // Only show loading on initial load
    final isInitialLoad = currentState is! PricingLoaded;
    if (isInitialLoad) {
      emit(const PricingLoading());
    }

    try {
      // Get all pricing versions
      final versions = await pricingApiDataSource.getPricingVersions(projectId);

      PricingVersionModel pricingVersion;

      if (versions.isEmpty) {
        // Create a new pricing version if none exists
        pricingVersion =
            await pricingApiDataSource.createPricingVersion(projectId);
      } else {
        // Get the latest version
        final latestVersion = versions.first;
        pricingVersion = await pricingApiDataSource.getPricingVersion(
          projectId,
          latestVersion.version,
        );
      }

      // Initialize/restore expanded states and profit margins
      final itemExpandedStates = <String, bool>{};
      final subItemExpandedStates = <String, Map<String, bool>>{};
      final subItemProfitMargins = <String, double>{};

      if (pricingVersion.items != null) {
        for (var item in pricingVersion.items!) {
          // Restore or initialize item expanded state
          itemExpandedStates[item.id] = preservedItemStates[item.id] ?? true;

          // Handle sub-items
          if (item.subItems != null) {
            final subItemStates = <String, bool>{};
            final preservedSubStates = preservedSubItemStates[item.id] ?? {};

            for (var subItem in item.subItems!) {
              // Restore or initialize sub-item expanded state
              subItemStates[subItem.id] =
                  preservedSubStates[subItem.id] ?? false;

              // Restore or initialize profit margin
              subItemProfitMargins[subItem.id] =
                  preservedProfitMargins[subItem.id] ?? subItem.profitMargin;
            }

            subItemExpandedStates[item.id] = subItemStates;
          }
        }
      }

      emit(PricingLoaded(
        pricingVersion: pricingVersion,
        projectName: null, // Can be set later if needed
        itemExpandedStates: itemExpandedStates,
        subItemExpandedStates: subItemExpandedStates,
        subItemProfitMargins: subItemProfitMargins,
      ));
    } catch (e) {
      emit(PricingError(message: 'فشل تحميل بيانات التسعير: ${e.toString()}'));
    }
  }

  /// Toggle item expanded state
  void toggleItemExpanded(String itemId) {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    final newStates = Map<String, bool>.from(currentState.itemExpandedStates);
    newStates[itemId] = !(newStates[itemId] ?? true);

    emit(currentState.copyWith(itemExpandedStates: newStates));
  }

  /// Toggle sub-item expanded state
  void toggleSubItemExpanded(String itemId, String subItemId) {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    final newSubItemStates =
        Map<String, Map<String, bool>>.from(currentState.subItemExpandedStates);
    final itemSubStates = Map<String, bool>.from(newSubItemStates[itemId] ?? {});
    itemSubStates[subItemId] = !(itemSubStates[subItemId] ?? false);
    newSubItemStates[itemId] = itemSubStates;

    emit(currentState.copyWith(subItemExpandedStates: newSubItemStates));
  }

  /// Update sub-item profit margin
  void updateSubItemProfitMargin(String subItemId, double profitMargin) {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    final newProfitMargins =
        Map<String, double>.from(currentState.subItemProfitMargins);
    newProfitMargins[subItemId] = profitMargin;

    emit(currentState.copyWith(subItemProfitMargins: newProfitMargins));
  }

  /// Add a new pricing item
  Future<void> addItem(String projectId, String name) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    try {
      await pricingApiDataSource.addPricingItem(
        projectId,
        currentState.pricingVersion.version,
        name: name,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a new sub-item
  Future<void> addSubItem(
    String projectId,
    String itemId,
    String name,
  ) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    // Check if in DRAFT status
    if (currentState.pricingVersion.status != 'DRAFT') {
      throw Exception(
        'لا يمكن إضافة فئة فرعية. إصدار التسعير في حالة "${currentState.getStatusText()}" وليس "مسودة".',
      );
    }

    try {
      await pricingApiDataSource.addPricingSubItem(
        projectId,
        currentState.pricingVersion.version,
        itemId,
        name: name,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Return pricing to draft status
  Future<void> returnToPricing(String projectId, String? reason) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    // Check if status allows returning
    final status = currentState.pricingVersion.status;
    if (status != 'PENDING_APPROVAL' &&
        status != 'APPROVED' &&
        status != 'PENDING_SIGNATURE') {
      throw Exception(
        'لا يمكن إرجاع التسعير. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      await pricingApiDataSource.returnToPricing(
        projectId,
        currentState.pricingVersion.version,
        reason: reason,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Approve pricing
  Future<void> approvePricing(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    if (currentState.pricingVersion.status != 'PENDING_APPROVAL') {
      throw Exception(
        'لا يمكن قبول التسعير. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      await pricingApiDataSource.approvePricing(
        projectId,
        currentState.pricingVersion.version,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate profit for sub-items
  Future<void> calculateProfitForSubItems(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    if (currentState.pricingVersion.status != 'APPROVED') {
      throw Exception(
        'لا يمكن حساب الربح. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    if (currentState.pricingVersion.items == null ||
        currentState.pricingVersion.items!.isEmpty) {
      throw Exception('لا توجد عناصر لحساب الربح');
    }

    try {
      // Collect SubItem profit margins
      final subItems = <Map<String, dynamic>>[];
      for (final item in currentState.pricingVersion.items!) {
        if (item.subItems != null) {
          for (final subItem in item.subItems!) {
            final profitMargin = currentState.subItemProfitMargins[subItem.id] ??
                subItem.profitMargin;
            subItems.add({
              'subItemId': subItem.id,
              'profitMargin': profitMargin,
            });
          }
        }
      }

      await pricingApiDataSource.calculateProfitForSubItems(
        projectId,
        currentState.pricingVersion.version,
        items: subItems,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm pricing
  Future<void> confirmPricing(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    if (currentState.pricingVersion.status != 'PENDING_SIGNATURE') {
      throw Exception(
        'لا يمكن تأكيد التسعير. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      await pricingApiDataSource.confirmPricing(
        projectId,
        currentState.pricingVersion.version,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm contract
  Future<void> confirmContract(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    if (currentState.pricingVersion.status != 'PENDING_SIGNATURE') {
      throw Exception(
        'لا يمكن تأكيد العقد. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      await contractsApiDataSource.confirmContract(projectId);
      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Return contract to pricing
  Future<void> returnContractToPricing(
    String projectId,
    String? reason,
  ) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    if (currentState.pricingVersion.status != 'PENDING_SIGNATURE') {
      throw Exception(
        'لا يمكن إرجاع العقد. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      await contractsApiDataSource.returnContractToPricing(
        projectId,
        reason: reason,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update pricing version notes
  Future<void> updatePricingVersionNotes(
    String projectId,
    String? notes,
  ) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    try {
      await pricingApiDataSource.updatePricingVersionNotes(
        projectId,
        currentState.pricingVersion.version,
        notes: notes,
      );

      await loadPricingData(projectId);
    } catch (e) {
      rethrow;
    }
  }

  /// Submit pricing for approval
  Future<void> submitForApproval(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return;

    try {
      // Calculate profit first if in DRAFT status
      if (currentState.pricingVersion.status == 'DRAFT' &&
          currentState.pricingVersion.items != null &&
          currentState.pricingVersion.items!.isNotEmpty) {
        final items = currentState.pricingVersion.items!
            .map((item) => {
                  'itemId': item.id,
                  'profitMargin': item.profitMargin,
                })
            .toList();

        await pricingApiDataSource.calculateProfit(
          projectId,
          currentState.pricingVersion.version,
          items: items,
        );

        await loadPricingData(projectId);
      }

      // Submit for approval
      final updatedState = state;
      if (updatedState is PricingLoaded &&
          updatedState.pricingVersion.status == 'PENDING_SIGNATURE') {
        await pricingApiDataSource.submitForApproval(
          projectId,
          updatedState.pricingVersion.version,
        );

        await loadPricingData(projectId);
      } else {
        throw Exception('يرجى حساب الربح أولاً قبل الإرسال للمراجعة');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Export pricing as PDF
  Future<List<int>> exportPricingPdf(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return [];

    // Allow export when status is APPROVED or PENDING_SIGNATURE
    if (currentState.pricingVersion.status != 'APPROVED' &&
        currentState.pricingVersion.status != 'PENDING_SIGNATURE') {
      throw Exception(
        'لا يمكن تصدير PDF. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      return await pricingApiDataSource.exportPricingPdf(
        projectId,
        currentState.pricingVersion.version,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Export pricing as images
  Future<dynamic> exportPricingImages(String projectId) async {
    final currentState = state;
    if (currentState is! PricingLoaded) return null;

    // Allow export when status is APPROVED or PENDING_SIGNATURE
    if (currentState.pricingVersion.status != 'APPROVED' &&
        currentState.pricingVersion.status != 'PENDING_SIGNATURE') {
      throw Exception(
        'لا يمكن تصدير الصور. الحالة الحالية: "${currentState.getStatusText()}"',
      );
    }

    try {
      return await pricingApiDataSource.exportPricingImages(
        projectId,
        currentState.pricingVersion.version,
      );
    } catch (e) {
      rethrow;
    }
  }
}
