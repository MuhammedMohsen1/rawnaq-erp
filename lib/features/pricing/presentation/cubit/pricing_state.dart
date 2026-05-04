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
  final String? clientName;
  final Map<String, bool> itemExpandedStates;
  final Map<String, Map<String, bool>> subItemExpandedStates;
  final Map<String, double> subItemProfitMargins;
  final double deductionAmount;
  final bool readOnly;

  const PricingLoaded({
    required this.pricingVersion,
    this.projectName,
    this.clientName,
    required this.itemExpandedStates,
    required this.subItemExpandedStates,
    required this.subItemProfitMargins,
    required this.deductionAmount,
    this.readOnly = false,
  });

  @override
  List<Object?> get props => [
    pricingVersion,
    projectName,
    clientName,
    itemExpandedStates,
    subItemExpandedStates,
    subItemProfitMargins,
    deductionAmount,
    readOnly,
  ];

  /// Create a copy with updated fields
  PricingLoaded copyWith({
    PricingVersionModel? pricingVersion,
    String? projectName,
    String? clientName,
    Map<String, bool>? itemExpandedStates,
    Map<String, Map<String, bool>>? subItemExpandedStates,
    Map<String, double>? subItemProfitMargins,
    double? deductionAmount,
    bool? readOnly,
  }) {
    return PricingLoaded(
      pricingVersion: pricingVersion ?? this.pricingVersion,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      itemExpandedStates: itemExpandedStates ?? this.itemExpandedStates,
      subItemExpandedStates:
          subItemExpandedStates ?? this.subItemExpandedStates,
      subItemProfitMargins: subItemProfitMargins ?? this.subItemProfitMargins,
      deductionAmount: deductionAmount ?? this.deductionAmount,
      readOnly: readOnly ?? this.readOnly,
    );
  }

  /// Get status text in Arabic
  String getStatusText() {
    switch (pricingVersion.status) {
      case 'DRAFT':
        return 'مسودة';
      case 'PENDING_SIGNATURE':
        return 'في انتظار التوقيع';
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

class PricingEmptyReadOnly extends PricingState {
  final String? projectName;
  final String? clientName;

  const PricingEmptyReadOnly({this.projectName, this.clientName});

  @override
  List<Object?> get props => [projectName, clientName];
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
