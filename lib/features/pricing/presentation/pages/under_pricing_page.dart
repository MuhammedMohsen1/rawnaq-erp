import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../data/datasources/pricing_api_datasource.dart';
import '../../data/models/pricing_version_model.dart';
import '../widgets/pricing_summary_sidebar.dart';
import '../widgets/pricing_item_card.dart';
import '../widgets/contract_export_dialog.dart';
import '../../../../features/contracts/data/datasources/contracts_api_datasource.dart';

class UnderPricingPage extends StatefulWidget {
  final String projectId;

  const UnderPricingPage({super.key, required this.projectId});

  @override
  State<UnderPricingPage> createState() => _UnderPricingPageState();
}

class _UnderPricingPageState extends State<UnderPricingPage> {
  final _apiDataSource = PricingApiDataSource();
  final _contractsApiDataSource = ContractsApiDataSource();
  PricingVersionModel? _pricingVersion;
  bool _isLoading = true;
  String? _errorMessage;
  String? _projectName;
  // Track expanded states for main items (itemId -> isExpanded)
  final Map<String, bool> _itemExpandedStates = {};
  // Track expanded states for sub-items (itemId -> {subItemId -> isExpanded})
  final Map<String, Map<String, bool>> _subItemExpandedStates = {};
  // Track profit margins entered in UI (subItemId -> profitMargin)
  final Map<String, double> _subItemProfitMargins = {};

  @override
  void initState() {
    super.initState();
    _loadPricingData();
  }

  Future<void> _loadPricingData() async {
    // Preserve existing expanded states before reloading
    final preservedItemStates = Map<String, bool>.from(_itemExpandedStates);
    final preservedSubItemStates = <String, Map<String, bool>>{};
    for (var entry in _subItemExpandedStates.entries) {
      preservedSubItemStates[entry.key] = Map<String, bool>.from(entry.value);
    }

    // Only show loading on initial load (when we don't have data yet)
    final isInitialLoad = _pricingVersion == null;
    setState(() {
      if (isInitialLoad) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      // Get all pricing versions
      final versions = await _apiDataSource.getPricingVersions(
        widget.projectId,
      );

      if (versions.isEmpty) {
        // Create a new pricing version if none exists
        _pricingVersion = await _apiDataSource.createPricingVersion(
          widget.projectId,
        );
      } else {
        // Get the latest version
        final latestVersion = versions.first;
        _pricingVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          latestVersion.version,
        );
        // Initialize profit margins from loaded data
        if (_pricingVersion?.items != null) {
          for (final item in _pricingVersion!.items!) {
            if (item.subItems != null) {
              for (final subItem in item.subItems!) {
                _subItemProfitMargins[subItem.id] = subItem.profitMargin;
              }
            }
          }
        }
      }

      // Restore preserved states and initialize new items/sub-items
      setState(() {
        _itemExpandedStates.clear();
        _subItemExpandedStates.clear();

        if (_pricingVersion?.items != null) {
          for (var item in _pricingVersion!.items!) {
            // Restore item expanded state or default to true
            _itemExpandedStates[item.id] = preservedItemStates[item.id] ?? true;

            // Restore sub-item expanded states
            if (item.subItems != null) {
              final subItemStates = <String, bool>{};
              final preservedSubStates = preservedSubItemStates[item.id] ?? {};

              for (var subItem in item.subItems!) {
                // Restore sub-item expanded state or default to false
                subItemStates[subItem.id] =
                    preservedSubStates[subItem.id] ?? false;
                // Initialize profit margin from model if not already set
                if (!_subItemProfitMargins.containsKey(subItem.id)) {
                  _subItemProfitMargins[subItem.id] = subItem.profitMargin;
                }
              }
              _subItemExpandedStates[item.id] = subItemStates;
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل بيانات التسعير: ${e.toString()}';
      });
    } finally {
      setState(() {
        if (isInitialLoad) {
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _addItem() async {
    if (_pricingVersion == null) return;

    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            hintText: 'أدخل اسم الفئة',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiDataSource.addPricingItem(
          widget.projectId,
          _pricingVersion!.version,
          name: result,
        );
        await _loadPricingData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إضافة الفئة بنجاح')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة الفئة: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _returnToPricing() async {
    if (_pricingVersion == null) return;

    // Check if pricing version is in PENDING_APPROVAL, APPROVED, or PENDING_SIGNATURE status
    if (_pricingVersion!.status != 'PENDING_APPROVAL' &&
        _pricingVersion!.status != 'APPROVED' &&
        _pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن إرجاع التسعير. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Check if user is authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      }
      return;
    }

    // Show confirmation dialog with optional reason
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرجاع التسعير للتعديل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هل أنت متأكد من إرجاع التسعير إلى حالة التعديل؟ سيتم إلغاء عملية المراجعة الحالية.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
                hintText: 'أدخل سبب الإرجاع',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('إرجاع'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiDataSource.returnToPricing(
        widget.projectId,
        _pricingVersion!.version,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : null,
      );

      await _loadPricingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرجاع التسعير بنجاح. يمكنك الآن التعديل'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'فشل إرجاع التسعير';
        if (e is ServerException) {
          errorMessage = 'فشل إرجاع التسعير: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل إرجاع التسعير: ${e.message}';
        } else {
          errorMessage = 'فشل إرجاع التسعير: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _acceptPricing() async {
    if (_pricingVersion == null) return;
    if (_pricingVersion!.status != 'PENDING_APPROVAL') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن قبول التسعير. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      }
      return;
    }
    final user = (authState as AuthAuthenticated).user;
    if (!user.isAdmin && !user.isManager) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ليس لديك صلاحية لقبول التسعير'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول التسعير'),
        content: const Text(
          'هل أنت متأكد من قبول هذا التسعير؟ سيتم اعتماد التسعير وستصبح الحالة "موافق عليه".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _apiDataSource.approvePricing(
        widget.projectId,
        _pricingVersion!.version,
      );
      await _loadPricingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قبول التسعير بنجاح'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'فشل قبول التسعير';
        if (e is ServerException) {
          errorMessage = 'فشل قبول التسعير: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل قبول التسعير: ${e.message}';
        } else {
          errorMessage = 'فشل قبول التسعير: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _makeProfit() async {
    if (_pricingVersion == null) return;
    if (_pricingVersion!.status != 'APPROVED') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن حساب الربح. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    if (_pricingVersion!.items == null || _pricingVersion!.items!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد عناصر لحساب الربح'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    try {
      // Collect SubItem profit margins from all items
      // Use updated profit margins from UI if available, otherwise use model values
      final subItems = <Map<String, dynamic>>[];
      for (final item in _pricingVersion!.items!) {
        if (item.subItems != null) {
          for (final subItem in item.subItems!) {
            // Use updated profit margin from UI state if available, otherwise use model value
            final profitMargin =
                _subItemProfitMargins[subItem.id] ?? subItem.profitMargin;
            subItems.add({
              'subItemId': subItem.id,
              'profitMargin': profitMargin,
            });
          }
        }
      }
      final updatedVersion = await _apiDataSource.calculateProfitForSubItems(
        widget.projectId,
        _pricingVersion!.version,
        items: subItems,
      );
      // Update local state with the response which includes updated totals
      setState(() {
        _pricingVersion = updatedVersion;
      });
      // Also reload to get full data with items
      await _loadPricingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حساب الربح بنجاح'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'فشل حساب الربح';
        if (e is ServerException) {
          errorMessage = 'فشل حساب الربح: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل حساب الربح: ${e.message}';
        } else {
          errorMessage = 'فشل حساب الربح: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _confirmPricing() async {
    if (_pricingVersion == null) return;
    if (_pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن تأكيد التسعير. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسعير وإنشاء العقد'),
        content: const Text(
          'هل أنت متأكد من تأكيد هذا التسعير؟ سيتم إنشاء العقد ونقل المشروع إلى مرحلة التنفيذ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _apiDataSource.confirmPricing(
        widget.projectId,
        _pricingVersion!.version,
      );
      await _loadPricingData();
      if (mounted) {
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
      if (mounted) {
        String errorMessage = 'فشل تأكيد التسعير';
        if (e is ServerException) {
          errorMessage = 'فشل تأكيد التسعير: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل تأكيد التسعير: ${e.message}';
        } else {
          errorMessage = 'فشل تأكيد التسعير: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _exportContractPdf() async {
    if (_pricingVersion == null) return;

    // Check if status is PENDING_SIGNATURE
    if (_pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن تصدير عقد PDF. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Show contract export dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContractExportDialog(
        projectId: widget.projectId,
        projectName: _projectName ?? 'project',
        totalAmount: _pricingVersion?.totalPrice ?? 0.0,
      ),
    );

    if (result == true && mounted) {
      // Dialog handles the export and shows success message
      // No need to do anything here
    }
  }

  Future<void> _confirmContract() async {
    if (_pricingVersion == null) return;

    // Check if status is PENDING_SIGNATURE
    if (_pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن تأكيد العقد. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد العقد ونقل المشروع للتنفيذ'),
        content: const Text(
          'هل أنت متأكد من تأكيد العقد؟ سيتم نقل المشروع إلى مرحلة التنفيذ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _contractsApiDataSource.confirmContract(widget.projectId);
      await _loadPricingData();

      if (mounted) {
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
      if (mounted) {
        String errorMessage = 'فشل تأكيد العقد';
        if (e is ServerException) {
          errorMessage = 'فشل تأكيد العقد: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل تأكيد العقد: ${e.message}';
        } else {
          errorMessage = 'فشل تأكيد العقد: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _returnContractToPricing() async {
    if (_pricingVersion == null) return;

    // Check if status is PENDING_SIGNATURE
    if (_pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن إرجاع العقد. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog with optional reason
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرجاع العقد للتسعير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من إرجاع العقد إلى مرحلة التسعير؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
                hintText: 'أدخل سبب الإرجاع',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('إرجاع'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _contractsApiDataSource.returnContractToPricing(
        widget.projectId,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : null,
      );

      await _loadPricingData();

      if (mounted) {
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
      if (mounted) {
        String errorMessage = 'فشل إرجاع العقد';
        if (e is ServerException) {
          errorMessage = 'فشل إرجاع العقد: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل إرجاع العقد: ${e.message}';
        } else {
          errorMessage = 'فشل إرجاع العقد: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _exportPricingPdf() async {
    if (_pricingVersion == null) return;
    // Allow export when status is APPROVED or PENDING_SIGNATURE
    if (_pricingVersion!.status != 'APPROVED' &&
        _pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن تصدير PDF. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    BuildContext? dialogContext;
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            dialogContext = context;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      // Download PDF
      final pdfBytes = await _apiDataSource.exportPricingPdf(
        widget.projectId,
        _pricingVersion!.version,
      );

      // Close loading dialog safely
      if (mounted && dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      // Create filename
      final projectName = _projectName ?? 'project';
      final fileName =
          'pricing-${projectName}-v${_pricingVersion!.version}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';

      File savedFile;

      // Use file picker to let user choose save location (works on desktop)
      // For mobile, we'll use a different approach
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Desktop platforms - use saveFile dialog
        final String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'حفظ ملف PDF',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile == null) {
          // User cancelled the save dialog
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إلغاء حفظ الملف'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        // Write PDF to the selected location
        savedFile = File(outputFile);
        await savedFile.writeAsBytes(pdfBytes);
      } else {
        // Mobile platforms (iOS, Android) - save to app documents directory
        // and share/open it
        final directory = await getApplicationDocumentsDirectory();
        savedFile = File('${directory.path}/$fileName');
        await savedFile.writeAsBytes(pdfBytes);

        // Open the file (will trigger share sheet on mobile)
        await OpenFile.open(savedFile.path);
      }

      // Show success message
      if (mounted) {
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
    } catch (e) {
      // Close loading dialog if still open (safely)
      if (mounted && dialogContext != null) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (_) {
          // Dialog already closed or context invalid - ignore
        }
      }

      if (mounted) {
        String errorMessage = 'فشل تصدير PDF';
        if (e is ServerException) {
          errorMessage = 'فشل تصدير PDF: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل تصدير PDF: ${e.message}';
        } else {
          errorMessage = 'فشل تصدير PDF: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updatePricingVersionNotes(String notes) async {
    if (_pricingVersion == null) return;

    try {
      await _apiDataSource.updatePricingVersionNotes(
        widget.projectId,
        _pricingVersion!.version,
        notes: notes.isEmpty ? null : notes,
      );
      // Reload pricing data to get updated notes
      await _loadPricingData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الملاحظات: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _exportPricingImages() async {
    if (_pricingVersion == null) return;
    // Allow export when status is APPROVED or PENDING_SIGNATURE
    if (_pricingVersion!.status != 'APPROVED' &&
        _pricingVersion!.status != 'PENDING_SIGNATURE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن تصدير الصور. الحالة الحالية: "${_getStatusText()}"',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    BuildContext? dialogContext;
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            dialogContext = context;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      // Download images
      final result = await _apiDataSource.exportPricingImages(
        widget.projectId,
        _pricingVersion!.version,
      );

      // Close loading dialog safely
      if (mounted && dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      final projectName = _projectName ?? 'project';
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Check if result is binary (single page) or JSON (multiple pages)
      if (result is Uint8List) {
        // Single page - save as PNG image
        final fileName =
            'pricing-${projectName}-v${_pricingVersion!.version}-$dateStr.png';

        File savedFile;

        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          // Desktop platforms - use saveFile dialog
          final String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'حفظ الصورة',
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['png'],
          );

          if (outputFile == null) {
            if (mounted) {
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
          await savedFile.writeAsBytes(result);
        } else {
          // Mobile platforms
          final directory = await getApplicationDocumentsDirectory();
          savedFile = File('${directory.path}/$fileName');
          await savedFile.writeAsBytes(result);
          await OpenFile.open(savedFile.path);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ الصورة بنجاح: ${savedFile.path}'),
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
      } else if (result is Map<String, dynamic>) {
        // Multiple pages - result contains pageCount and images array
        final images = result['images'] as List<dynamic>? ?? [];

        if (images.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لم يتم العثور على صور'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // Save each image as a separate file
        final savedFiles = <File>[];

        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          // Desktop - ask user to choose a directory
          final String? outputDir = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'اختر مجلد لحفظ الصور',
          );

          if (outputDir == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء حفظ الملفات'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            return;
          }

          // Save all images
          for (var i = 0; i < images.length; i++) {
            final imageData = images[i] as Map<String, dynamic>;
            final pageNumber = imageData['page'] as int? ?? (i + 1);
            final base64Data = imageData['data'] as String? ?? '';

            if (base64Data.isNotEmpty) {
              final imageBytes = base64Decode(base64Data);
              final fileName =
                  'pricing-${projectName}-v${_pricingVersion!.version}-$dateStr-page$pageNumber.png';
              final file = File('$outputDir/$fileName');
              await file.writeAsBytes(imageBytes);
              savedFiles.add(file);
            }
          }
        } else {
          // Mobile - save to app documents directory
          final directory = await getApplicationDocumentsDirectory();

          for (var i = 0; i < images.length; i++) {
            final imageData = images[i] as Map<String, dynamic>;
            final pageNumber = imageData['page'] as int? ?? (i + 1);
            final base64Data = imageData['data'] as String? ?? '';

            if (base64Data.isNotEmpty) {
              final imageBytes = base64Decode(base64Data);
              final fileName =
                  'pricing-${projectName}-v${_pricingVersion!.version}-$dateStr-page$pageNumber.png';
              final file = File('${directory.path}/$fileName');
              await file.writeAsBytes(imageBytes);
              savedFiles.add(file);
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ ${savedFiles.length} صورة بنجاح'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open (safely)
      if (mounted && dialogContext != null) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (_) {
          // Dialog already closed or context invalid - ignore
        }
      }

      if (mounted) {
        String errorMessage = 'فشل تصدير الصور';
        if (e is ServerException) {
          errorMessage = 'فشل تصدير الصور: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل تصدير الصور: ${e.message}';
        } else {
          errorMessage = 'فشل تصدير الصور: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _addSubItem(String itemId) async {
    if (_pricingVersion == null) return;

    // Check if pricing version is in DRAFT status
    if (_pricingVersion!.status != 'DRAFT') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن إضافة فئة فرعية. إصدار التسعير في حالة "${_getStatusText()}" وليس "مسودة".',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فئة فرعية جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة الفرعية',
            hintText: 'أدخل اسم الفئة الفرعية',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiDataSource.addPricingSubItem(
          widget.projectId,
          _pricingVersion!.version,
          itemId,
          name: result,
        );
        await _loadPricingData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الفئة الفرعية بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
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

  String _getStatusText() {
    if (_pricingVersion == null) return 'قيد التسعير';

    switch (_pricingVersion!.status) {
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

  Color _getStatusColor() {
    if (_pricingVersion == null) return AppColors.info;

    switch (_pricingVersion!.status) {
      case 'DRAFT':
        return AppColors.textMuted;
      case 'PENDING_SIGNATURE':
        return AppColors.warning;
      case 'PENDING_APPROVAL':
        return AppColors.warning;
      case 'APPROVED':
        return AppColors.statusCompleted;
      case 'REJECTED':
        return AppColors.statusDelayed;
      default:
        return AppColors.info;
    }
  }

  int _getTotalElementsCount() {
    if (_pricingVersion == null || _pricingVersion!.items == null) {
      return 0;
    }

    int totalCount = 0;
    for (var item in _pricingVersion!.items!) {
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

  String? _formatLastSaveTime(DateTime? dateTime) {
    if (dateTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If less than a minute ago, show "الآن" (Now)
    if (difference.inSeconds < 60) {
      return null; // Will show "الآن" in the UI
    }

    // If less than an hour ago, show minutes
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'منذ $minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}';
    }

    // If less than a day ago, show hours
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    }

    // If less than a week ago, show days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'منذ $days ${days == 1 ? 'يوم' : 'أيام'}';
    }

    // If less than a month ago, show weeks
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    }

    // Otherwise, show formatted date in Arabic format
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPricingData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle(),
          const SizedBox(height: 16),
          _buildItemsList(),
          const SizedBox(height: 24),
          _buildAddItemButton(),
          const SizedBox(height: 24),
          _buildSidebar(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildAddItemButton(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildSidebar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildAddItemButton(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildSidebar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.projects),
          child: Text(
            'المشاريع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          _projectName ?? 'المشروع',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          'التسعير',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                border: Border.all(color: _getStatusColor().withOpacity(0.2)),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'تسعير الجدران',
      style: AppTextStyles.h3.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _handleItemExpandedChanged(String itemId, bool isExpanded) {
    setState(() {
      _itemExpandedStates[itemId] = isExpanded;
    });
  }

  void _handleSubItemExpandedChanged(
    String itemId,
    Map<String, bool> subItemStates,
  ) {
    setState(() {
      _subItemExpandedStates[itemId] = Map<String, bool>.from(subItemStates);
    });
  }

  Widget _buildItemsList() {
    if (_pricingVersion == null ||
        _pricingVersion!.items == null ||
        _pricingVersion!.items!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.folder_outlined, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'لا توجد فئات بعد',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ابدأ بإضافة فئة جديدة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _pricingVersion!.items!.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Builder(
            builder: (context) {
              // Get user role information
              final authState = context.read<AuthBloc>().state;
              bool isAdminOrManager = false;
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                isAdminOrManager = user.isAdmin || user.isManager;
              }

              return PricingItemCard(
                key: ValueKey('pricing-item-${item.id}'),
                projectId: widget.projectId,
                version: _pricingVersion!.version,
                item: item,
                pricingStatus: _pricingVersion?.status,
                isAdminOrManager: isAdminOrManager,
                initialIsExpanded: _itemExpandedStates[item.id] ?? true,
                initialSubItemExpandedStates:
                    _subItemExpandedStates[item.id] ?? {},
                onExpandedChanged: (isExpanded) =>
                    _handleItemExpandedChanged(item.id, isExpanded),
                onSubItemExpandedChanged: (subItemStates) =>
                    _handleSubItemExpandedChanged(item.id, subItemStates),
                onItemDeleted: () => _loadPricingData(),
                onSubItemDeleted: (_) => _loadPricingData(),
                onItemChanged: (_) {
                  // Reload data but preserve widget state using keys
                  _loadPricingData();
                },
                onSubItemChanged: (updatedSubItem) {
                  // Store updated profit margin in parent state
                  setState(() {
                    _subItemProfitMargins[updatedSubItem.id] =
                        updatedSubItem.profitMargin;
                  });
                },
                onAddSubItem: () => _addSubItem(item.id),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddItemButton() {
    return Container(
      width: double.infinity,
      height: 152,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFF4B5563),
          strokeWidth: 2,
        ),
        child: InkWell(
          onTap: _addItem,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A313D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'إضافة فئة جديدة',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    // Check if we should show return to pricing button
    // Anyone can return a pricing version that is in PENDING_APPROVAL, APPROVED, or PENDING_SIGNATURE status
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    bool showReturnButton = false;
    if (isAuthenticated && _pricingVersion != null) {
      final currentStatus = _pricingVersion!.status.toUpperCase();
      showReturnButton =
          currentStatus == 'PENDING_APPROVAL' ||
          currentStatus == 'APPROVED' ||
          currentStatus == 'PENDING_SIGNATURE';
    }
    // Check if user is Admin or Manager
    bool isAdminOrManager = false;
    if (isAuthenticated) {
      final user = (authState as AuthAuthenticated).user;
      isAdminOrManager = user.isAdmin || user.isManager;
    }

    // Check if pricing status is PENDING_APPROVAL
    bool isPendingApproval = false;
    if (_pricingVersion != null) {
      final currentStatus = _pricingVersion!.status.toUpperCase();
      isPendingApproval = currentStatus == 'PENDING_APPROVAL';
    }

    // Check if pricing status is APPROVED
    bool isApproved = false;
    if (_pricingVersion != null) {
      final currentStatus = _pricingVersion!.status.toUpperCase();
      isApproved = currentStatus == 'APPROVED';
    }

    // Check if pricing status is PENDING_SIGNATURE
    bool isProfitPending = false;
    if (_pricingVersion != null) {
      final currentStatus = _pricingVersion!.status.toUpperCase();
      isProfitPending = currentStatus == 'PENDING_SIGNATURE';
    }

    // Ensure return to pricing button is always available for APPROVED or PENDING_SIGNATURE status
    final shouldShowReturnButton =
        showReturnButton || isApproved || isProfitPending;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: PricingSummarySidebar(
        grandTotal: _pricingVersion?.totalPrice ?? 0.0,
        totalCost: _pricingVersion?.totalCost,
        totalProfit: _pricingVersion?.totalProfit,
        totalElements: _getTotalElementsCount(),
        lastSaveTime: _formatLastSaveTime(_pricingVersion?.updatedAt),
        showReturnToPricing: shouldShowReturnButton,
        onReturnToPricing: shouldShowReturnButton ? _returnToPricing : null,
        isAdminOrManager: isAdminOrManager,
        isPendingApproval: isPendingApproval,
        onAcceptPricing: isAdminOrManager && isPendingApproval
            ? _acceptPricing
            : null,
        isApproved: isApproved,
        isProfitPending: isProfitPending,
        onMakeProfit: isAdminOrManager && isApproved ? _makeProfit : null,
        onConfirmPricing: isProfitPending ? _confirmPricing : null,
        onExportPdf: (isAdminOrManager && isApproved) || isProfitPending
            ? _exportPricingPdf
            : null,
        onExportContractPdf: isProfitPending ? _exportContractPdf : null,
        onConfirmContract: isProfitPending ? _confirmContract : null,
        onReturnContractToPricing: isProfitPending
            ? _returnContractToPricing
            : null,
        onExportImages: (isAdminOrManager && isApproved) || isProfitPending
            ? _exportPricingImages
            : null,
        pricingVersionNotes: _pricingVersion?.notes,
        onUpdateNotes: isAdminOrManager ? _updatePricingVersionNotes : null,
        onSubmit: () async {
          if (_pricingVersion == null) return;

          try {
            // Check if we need to calculate profit first
            if (_pricingVersion!.status == 'DRAFT' &&
                _pricingVersion!.items != null &&
                _pricingVersion!.items!.isNotEmpty) {
              // Calculate profit for all items
              final items = _pricingVersion!.items!
                  .map(
                    (item) => {
                      'itemId': item.id,
                      'profitMargin': item.profitMargin,
                    },
                  )
                  .toList();

              await _apiDataSource.calculateProfit(
                widget.projectId,
                _pricingVersion!.version,
                items: items,
              );

              // Reload to get updated status
              await _loadPricingData();
            }

            // Submit for approval
            if (_pricingVersion!.status == 'PENDING_SIGNATURE') {
              await _apiDataSource.submitForApproval(
                widget.projectId,
                _pricingVersion!.version,
              );

              await _loadPricingData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال التسعير للمراجعة')),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى حساب الربح أولاً قبل الإرسال للمراجعة'),
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل إرسال التسعير: ${e.toString()}')),
              );
            }
          }
        },
        onSaveDraft: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة')));
        },
        isDraft: _pricingVersion?.status == 'DRAFT',
        isUnderPricing: _pricingVersion?.status == 'UNDER_PRICING',
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.radius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, paint, path);
  }

  void _drawDashedPath(Canvas canvas, Paint paint, Path path) {
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segmentLength = min(dashWidth, metric.length - distance);
        final segment = metric.extractPath(distance, distance + segmentLength);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
