import 'package:equatable/equatable.dart';
import '../../data/models/pricing_version_model.dart';

/// Base state for pricing management
sealed class PricingState extends Equatable {
  const PricingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PricingInitial extends PricingState {
  const PricingInitial();
}

/// Loading state
class PricingLoading extends PricingState {
  const PricingLoading();
}

/// Loaded state with pricing data
class PricingLoaded extends PricingState {
  final PricingVersionModel pricingVersion;
  final String? projectName;
  final Map<String, bool> itemExpandedStates;
  final Map<String, Map<String, bool>> subItemExpandedStates;
  final Map<String, double> subItemProfitMargins;

  const PricingLoaded({
    required this.pricingVersion,
    this.projectName,
    required this.itemExpandedStates,
    required this.subItemExpandedStates,
    required this.subItemProfitMargins,
  });

  @override
  List<Object?> get props => [
        pricingVersion,
        projectName,
        itemExpandedStates,
        subItemExpandedStates,
        subItemProfitMargins,
      ];

  /// Create a copy with updated fields
  PricingLoaded copyWith({
    PricingVersionModel? pricingVersion,
    String? projectName,
    Map<String, bool>? itemExpandedStates,
    Map<String, Map<String, bool>>? subItemExpandedStates,
    Map<String, double>? subItemProfitMargins,
  }) {
    return PricingLoaded(
      pricingVersion: pricingVersion ?? this.pricingVersion,
      projectName: projectName ?? this.projectName,
      itemExpandedStates: itemExpandedStates ?? this.itemExpandedStates,
      subItemExpandedStates:
          subItemExpandedStates ?? this.subItemExpandedStates,
      subItemProfitMargins: subItemProfitMargins ?? this.subItemProfitMargins,
    );
  }

  /// Get status text in Arabic
  String getStatusText() {
    switch (pricingVersion.status) {
      case 'DRAFT':
        return 'مسودة';
      case 'PENDING_SIGNATURE':
        return 'في انتظار التوقيع';
      case 'PENDING_APPROVAL':
        return 'في انتظار الموافقة';
      case 'APPROVED':
        return 'موافق عليه';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return 'قيد التسعير';
    }
  }

  /// Get total count of all elements
  int getTotalElementsCount() {
    if (pricingVersion.items == null) return 0;

    int totalCount = 0;
    for (var item in pricingVersion.items!) {
      if (item.subItems != null) {
        for (var subItem in item.subItems!) {
          if (subItem.elements != null) {
            totalCount += subItem.elements!.length;
          }
        }
      }
    }
    return totalCount;
  }
}

/// Error state
class PricingError extends PricingState {
  final String message;

  const PricingError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Processing state (for async operations like export, confirm, etc.)
class PricingProcessing extends PricingState {
  final String operation;
  final PricingLoaded previousState;

  const PricingProcessing({
    required this.operation,
    required this.previousState,
  });

  @override
  List<Object?> get props => [operation, previousState];
}
