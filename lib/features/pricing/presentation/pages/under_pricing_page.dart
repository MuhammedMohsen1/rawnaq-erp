import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../contracts/data/datasources/contracts_api_datasource.dart';
import '../cubit/pricing_cubit.dart';
import '../cubit/pricing_state.dart';
import '../utils/pricing_status_utils.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/add_pricing_item_button.dart';
import '../widgets/contract_export_dialog.dart';
import '../widgets/pricing_confirmation_dialogs.dart';
import '../widgets/pricing_header.dart';
import '../widgets/pricing_items_list.dart';
import '../widgets/pricing_summary_sidebar.dart';

/// Under pricing page - refactored with Cubit and extracted widgets
class UnderPricingPage extends StatelessWidget {
  final String projectId;

  const UnderPricingPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PricingCubit>()..loadPricingData(projectId),
      child: _UnderPricingContent(projectId: projectId),
    );
  }
}

/// Internal content widget with access to Cubit
class _UnderPricingContent extends StatelessWidget {
  final String projectId;

  const _UnderPricingContent({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PricingCubit, PricingState>(
      listener: (context, state) {
        // Handle errors
        if (state is PricingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PricingLoading) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is PricingError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<PricingCubit>().loadPricingData(projectId),
          );
        }

        if (state is PricingLoaded) {
          return _LoadedContent(projectId: projectId, state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Loaded content view
class _LoadedContent extends StatelessWidget {
  final String projectId;
  final PricingLoaded state;

  const _LoadedContent({required this.projectId, required this.state});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _PricingLayout(projectId: projectId, padding: 16),
      tablet: _PricingLayout(projectId: projectId, padding: 24),
      desktop: _PricingLayout(projectId: projectId, padding: 32),
    );
  }
}

/// Pricing layout for different screen sizes
class _PricingLayout extends StatelessWidget {
  final String projectId;
  final double padding;

  const _PricingLayout({required this.projectId, required this.padding});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PricingCubit, PricingState>(
      builder: (context, state) {
        if (state is! PricingLoaded) return const SizedBox.shrink();

        final statusColor = PricingStatusUtils.getStatusColor(
          state.pricingVersion.status,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              PricingHeader(
                statusText: state.getStatusText(),
                statusColor: statusColor,
              ),
              const SizedBox(height: 24),

              // Items list
              PricingItemsList(
                projectId: projectId,
                version: state.pricingVersion.version,
                items: state.pricingVersion.items ?? [],
                pricingStatus: state.pricingVersion.status,
                itemExpandedStates: state.itemExpandedStates,
                subItemExpandedStates: state.subItemExpandedStates,
                subItemProfitMargins: state.subItemProfitMargins,
                onItemExpandedChanged: (itemId, isExpanded) {
                  context.read<PricingCubit>().toggleItemExpanded(itemId);
                },
                onSubItemExpandedChanged: (itemId, subItemStates) {
                  // Update all sub-item states for this item
                  for (var entry in subItemStates.entries) {
                    context.read<PricingCubit>().toggleSubItemExpanded(
                      itemId,
                      entry.key,
                    );
                  }
                },
                onDataChanged: () {
                  context.read<PricingCubit>().loadPricingData(projectId);
                },
                onSubItemProfitMarginChanged: (subItemId, profitMargin) {
                  context.read<PricingCubit>().updateSubItemProfitMargin(
                    subItemId,
                    profitMargin,
                  );
                },
                onAddSubItem: (itemId) => _handleAddSubItem(context, itemId),
              ),
              const SizedBox(height: 24),

              // Add item button
              AddPricingItemButton(onTap: () => _handleAddItem(context)),
              const SizedBox(height: 24),

              // Sidebar with summary and actions
              _buildSidebar(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, PricingLoaded state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    bool isAdminOrManager = false;
    if (isAuthenticated) {
      final user = (authState as AuthAuthenticated).user;
      isAdminOrManager = user.isAdmin || user.isManager;
    }

    final currentStatus = state.pricingVersion.status.toUpperCase();
    final showReturnButton =
        isAuthenticated &&
        (currentStatus == 'PENDING_APPROVAL' ||
            currentStatus == 'APPROVED' ||
            currentStatus == 'PENDING_SIGNATURE');

    final isPendingApproval = currentStatus == 'PENDING_APPROVAL';
    final isApproved = currentStatus == 'APPROVED';
    final isProfitPending = currentStatus == 'PENDING_SIGNATURE';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: PricingSummarySidebar(
        grandTotal: state.pricingVersion.totalPrice ?? 0.0,
        totalCost: state.pricingVersion.totalCost,
        totalProfit: state.pricingVersion.totalProfit,
        totalElements: state.getTotalElementsCount(),
        lastSaveTime: PricingStatusUtils.formatLastSaveTime(
          state.pricingVersion.updatedAt,
        ),
        showReturnToPricing: showReturnButton,
        onReturnToPricing: showReturnButton
            ? () => _handleReturnToPricing(context)
            : null,
        isAdminOrManager: isAdminOrManager,
        isPendingApproval: isPendingApproval,
        onAcceptPricing: isAdminOrManager && isPendingApproval
            ? () => _handleAcceptPricing(context)
            : null,
        isApproved: isApproved,
        isProfitPending: isProfitPending,
        onMakeProfit: isAdminOrManager && isApproved
            ? () => _handleMakeProfit(context)
            : null,
        onConfirmPricing: isProfitPending
            ? () => _handleConfirmPricing(context)
            : null,
        onExportPdf: (isAdminOrManager && isApproved)
            ? () => _handleExportPdf(context)
            : null,
        onExportContractPdf: isProfitPending
            ? () => _handleExportContractPdf(context)
            : null,
        onConfirmContract: isProfitPending
            ? () => _handleConfirmContract(context)
            : null,
        onReturnContractToPricing: isProfitPending
            ? () => _handleReturnContractToPricing(context)
            : null,
        onExportImages: (isAdminOrManager && isApproved)
            ? () => _handleExportImages(context)
            : null,
        pricingVersionNotes: state.pricingVersion.notes,
        onUpdateNotes: isAdminOrManager
            ? (notes) => _handleUpdateNotes(context, notes)
            : null,
        onSubmit: () => _handleSubmit(context),
        onSaveDraft: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة')));
        },
        isDraft: currentStatus == 'DRAFT',
        isUnderPricing: currentStatus == 'UNDER_PRICING',
        onBulkProfitMarginUpdate:
            isAdminOrManager && (isApproved || isProfitPending)
            ? (profitMargin) {
                context.read<PricingCubit>().updateAllSubItemProfitMargins(
                  projectId,
                  profitMargin,
                );
              }
            : null,
      ),
    );
  }

  // Action handlers

  Future<void> _handleAddItem(BuildContext context) async {
    final name = await AddItemDialog.showAddItemDialog(context);
    if (name != null && name.isNotEmpty) {
      try {
        await context.read<PricingCubit>().addItem(projectId, name);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إضافة الفئة بنجاح')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة الفئة: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _handleAddSubItem(BuildContext context, String itemId) async {
    final name = await AddItemDialog.showAddSubItemDialog(context);
    if (name != null && name.isNotEmpty) {
      try {
        await context.read<PricingCubit>().addSubItem(projectId, itemId, name);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الفئة الفرعية بنجاح')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إضافة الفئة الفرعية: ${e.toString()}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReturnToPricing(BuildContext context) async {
    final (confirmed, reason) =
        await PricingConfirmationDialogs.showReturnToPricingDialog(context);

    if (confirmed) {
      try {
        await context.read<PricingCubit>().returnToPricing(projectId, reason);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرجاع التسعير بنجاح. يمكنك الآن التعديل'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل إرجاع التسعير', e);
        }
      }
    }
  }

  Future<void> _handleAcceptPricing(BuildContext context) async {
    final confirmed = await PricingConfirmationDialogs.showAcceptPricingDialog(
      context,
    );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().approvePricing(projectId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم قبول التسعير بنجاح'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل قبول التسعير', e);
        }
      }
    }
  }

  Future<void> _handleMakeProfit(BuildContext context) async {
    try {
      await context.read<PricingCubit>().calculateProfitForSubItems(projectId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حساب الربح بنجاح'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'فشل حساب الربح', e);
      }
    }
  }

  Future<void> _handleConfirmPricing(BuildContext context) async {
    final confirmed = await PricingConfirmationDialogs.showConfirmPricingDialog(
      context,
    );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().confirmPricing(projectId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تأكيد التسعير وإنشاء العقد بنجاح. تم نقل المشروع إلى مرحلة التنفيذ.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل تأكيد التسعير', e);
        }
      }
    }
  }

  Future<void> _handleConfirmContract(BuildContext context) async {
    // Fetch the contract to get the payment schedule
    final contractsApi = ContractsApiDataSource();
    List<Map<String, dynamic>>? paymentSchedule;

    try {
      final contract = await contractsApi.getContract(projectId);
      if (contract != null && contract['paymentSchedule'] != null) {
        final scheduleData = contract['paymentSchedule'] as List?;
        if (scheduleData != null) {
          paymentSchedule = scheduleData
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    } catch (e) {
      // If we can't fetch the contract, continue without payment schedule
      // The dialog will show an error
    }

    if (!context.mounted) return;

    final confirmed =
        await PricingConfirmationDialogs.showConfirmContractDialog(
          context,
          paymentSchedule: paymentSchedule,
        );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().confirmContract(projectId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تأكيد العقد بنجاح. تم نقل المشروع إلى مرحلة التنفيذ.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل تأكيد العقد', e);
        }
      }
    }
  }

  Future<void> _handleReturnContractToPricing(BuildContext context) async {
    final (
      confirmed,
      reason,
    ) = await PricingConfirmationDialogs.showReturnContractToPricingDialog(
      context,
    );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().returnContractToPricing(
          projectId,
          reason,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إرجاع العقد بنجاح. تم نقل المشروع إلى مرحلة التسعير.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل إرجاع العقد', e);
        }
      }
    }
  }

  Future<void> _handleUpdateNotes(BuildContext context, String notes) async {
    try {
      await context.read<PricingCubit>().updatePricingVersionNotes(
        projectId,
        notes.isEmpty ? null : notes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الملاحظات: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    try {
      await context.read<PricingCubit>().submitForApproval(projectId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال التسعير للمراجعة')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال التسعير: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleExportPdf(BuildContext context) async {
    BuildContext? dialogContext;
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            dialogContext = ctx;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      final pdfBytes = await context.read<PricingCubit>().exportPricingPdf(
        projectId,
      );

      // Close loading
      if (context.mounted && dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      // Save file
      await _savePdfFile(context, pdfBytes, 'pricing');
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (context.mounted) {
        _showErrorMessage(context, 'فشل تصدير PDF', e);
      }
    }
  }

  Future<void> _handleExportContractPdf(BuildContext context) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContractExportDialog(
        projectId: projectId,
        projectName: state.projectName ?? 'project',
        totalAmount: state.pricingVersion.totalPrice ?? 0.0,
      ),
    );

    // Dialog handles export itself
  }

  Future<void> _handleExportImages(BuildContext context) async {
    BuildContext? dialogContext;
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            dialogContext = ctx;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      final result = await context.read<PricingCubit>().exportPricingImages(
        projectId,
      );

      // Close loading
      if (context.mounted && dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      // Handle result (can be Uint8List or Map)
      if (result is Uint8List) {
        await _saveImageFile(context, result, 'pricing-image');
      } else if (result is Map<String, dynamic>) {
        await _saveMultipleImages(context, result);
      }
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (context.mounted) {
        _showErrorMessage(context, 'فشل تصدير الصور', e);
      }
    }
  }

  // Helper methods for file operations

  Future<void> _savePdfFile(
    BuildContext context,
    List<int> pdfBytes,
    String baseName,
  ) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final projectName = state.projectName ?? 'project';
    final fileName =
        '$baseName-$projectName-v${state.pricingVersion.version}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';

    File savedFile;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ ملف PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputFile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء حفظ الملف'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      savedFile = File(outputFile);
      await savedFile.writeAsBytes(pdfBytes);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      savedFile = File('${directory.path}/$fileName');
      await savedFile.writeAsBytes(pdfBytes);
      await OpenFile.open(savedFile.path);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ PDF بنجاح: ${savedFile.path}'),
          duration: const Duration(seconds: 3),
          action: Platform.isWindows || Platform.isMacOS || Platform.isLinux
              ? SnackBarAction(
                  label: 'فتح',
                  onPressed: () async {
                    await OpenFile.open(savedFile.path);
                  },
                )
              : null,
        ),
      );
    }
  }

  Future<void> _saveImageFile(
    BuildContext context,
    Uint8List imageBytes,
    String baseName,
  ) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final projectName = state.projectName ?? 'project';
    final fileName =
        '$baseName-$projectName-v${state.pricingVersion.version}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.png';

    File savedFile;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ الصورة',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['png'],
      );

      if (outputFile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء حفظ الملف'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      savedFile = File(outputFile);
      await savedFile.writeAsBytes(imageBytes);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      savedFile = File('${directory.path}/$fileName');
      await savedFile.writeAsBytes(imageBytes);
      await OpenFile.open(savedFile.path);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الصورة بنجاح: ${savedFile.path}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveMultipleImages(
    BuildContext context,
    Map<String, dynamic> result,
  ) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final images = result['images'] as List<dynamic>? ?? [];
    if (images.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('لم يتم العثور على صور')));
      }
      return;
    }

    final projectName = state.projectName ?? 'project';
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedFiles = <File>[];

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final String? outputDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مجلد لحفظ الصور',
      );

      if (outputDir == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إلغاء حفظ الملفات')));
        }
        return;
      }

      for (var i = 0; i < images.length; i++) {
        final imageData = images[i] as Map<String, dynamic>;
        final pageNumber = imageData['page'] as int? ?? (i + 1);
        final base64Data = imageData['data'] as String? ?? '';

        if (base64Data.isNotEmpty) {
          final imageBytes = base64Decode(base64Data);
          final fileName =
              'pricing-$projectName-v${state.pricingVersion.version}-$dateStr-page$pageNumber.png';
          final file = File('$outputDir/$fileName');
          await file.writeAsBytes(imageBytes);
          savedFiles.add(file);
        }
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      for (var i = 0; i < images.length; i++) {
        final imageData = images[i] as Map<String, dynamic>;
        final pageNumber = imageData['page'] as int? ?? (i + 1);
        final base64Data = imageData['data'] as String? ?? '';

        if (base64Data.isNotEmpty) {
          final imageBytes = base64Decode(base64Data);
          final fileName =
              'pricing-$projectName-v${state.pricingVersion.version}-$dateStr-page$pageNumber.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(imageBytes);
          savedFiles.add(file);
        }
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ ${savedFiles.length} صورة بنجاح'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(BuildContext context, String prefix, Object error) {
    String errorMessage = prefix;
    if (error is ServerException) {
      errorMessage = '$prefix: ${error.message}';
    } else if (error is ValidationException) {
      errorMessage = '$prefix: ${error.message}';
    } else {
      errorMessage = '$prefix: ${error.toString()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
