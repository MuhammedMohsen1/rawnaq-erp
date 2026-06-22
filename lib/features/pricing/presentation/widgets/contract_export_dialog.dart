import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../features/settings/data/datasources/settings_api_datasource.dart';
import '../../../../features/contracts/data/datasources/contracts_api_datasource.dart';
import '../../../../features/projects/data/datasources/projects_api_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/widgets/dialog_keyboard_actions.dart';
import 'contract_export_step1_content.dart';
import 'contract_export_step2_content.dart';
import 'contract_export_step3_content.dart';
import 'contract_export_step4_content.dart';

class ContractExportDialog extends StatefulWidget {
  final String projectId;
  final String projectName;
  final double totalAmount;

  const ContractExportDialog({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.totalAmount,
  });

  @override
  State<ContractExportDialog> createState() => _ContractExportDialogState();
}

class _ContractExportDialogState extends State<ContractExportDialog> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  final ContractsApiDataSource _contractsApi = ContractsApiDataSource();
  final ProjectsApiDataSource _projectsApi = ProjectsApiDataSource();

  // Step 1: Civil ID
  final TextEditingController _civilIdController = TextEditingController();
  final TextEditingController _projectAddressController =
      TextEditingController();
  String? _existingCivilId;
  String? _existingProjectAddress;
  String? _clientName;
  String _projectType = 'EXECUTION';
  bool _isLoadingProject = true;

  // Step 2: Terms
  List<Map<String, TextEditingController>> _contractTerms = [];
  List<bool> _termsApproved = [];
  bool _isLoadingTerms = true;

  // Step 3: Payment Schedule
  late List<Map<String, dynamic>> _paymentPhases;
  List<Map<String, TextEditingController>> _paymentControllers = [];
  final TextEditingController _companySignerNameController =
      TextEditingController(text: 'محمود محسن');
  final TextEditingController _designNotesController = TextEditingController();
  final TextEditingController _executionNotesController =
      TextEditingController();
  final TextEditingController _executionDurationDaysController =
      TextEditingController();
  List<Map<String, TextEditingController>> _designScopeControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize payment phases with default values
    _paymentPhases = <Map<String, dynamic>>[
      <String, dynamic>{
        'phase': '',
        'percentage': 50.0,
        'amount': widget.totalAmount * 0.5,
        'notes': '',
      },
      <String, dynamic>{
        'phase': '',
        'percentage': 50.0,
        'amount': widget.totalAmount * 0.5,
        'notes': '',
      },
    ];
    _initializePaymentControllers();
    _loadProjectData();
  }

  void _initializePaymentControllers() {
    _paymentControllers = _paymentPhases.map((phase) {
      return {
        'phase': TextEditingController(text: phase['phase'] as String),
        'percentage': TextEditingController(
          text: (phase['percentage'] as num).toStringAsFixed(2),
        ),
        'amount': TextEditingController(
          text: ((phase['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(
            3,
          ),
        ),
        'notes': TextEditingController(text: phase['notes']?.toString() ?? ''),
      };
    }).toList();
  }

  @override
  void dispose() {
    _civilIdController.dispose();
    _projectAddressController.dispose();
    _companySignerNameController.dispose();
    _designNotesController.dispose();
    _executionNotesController.dispose();
    _executionDurationDaysController.dispose();
    for (var term in _contractTerms) {
      term['title']?.dispose();
      term['description']?.dispose();
    }
    for (var scope in _designScopeControllers) {
      scope['item']?.dispose();
      scope['description']?.dispose();
    }
    for (var payment in _paymentControllers) {
      payment['phase']?.dispose();
      payment['percentage']?.dispose();
      payment['amount']?.dispose();
      payment['notes']?.dispose();
    }
    super.dispose();
  }

  // General
  int _currentStep = 0;
  bool _isExporting = false;
  String? _errorMessage;

  Future<void> _loadProjectData() async {
    try {
      final defaults = await _contractsApi.getContractExportDefaults(
        widget.projectId,
      );
      final projectType =
          defaults['projectType'] as String? ??
          defaults['contractType'] as String? ??
          'EXECUTION';
      _replaceTerms(_asMapList(defaults['contractTerms']));
      _replacePaymentSchedule(_asMapList(defaults['paymentSchedule']));
      _replaceDesignScopeItems(_asMapList(defaults['designScopeItems']));
      if (mounted) {
        setState(() {
          _existingCivilId = defaults['civilId'] as String?;
          _existingProjectAddress = defaults['projectAddress'] as String?;
          _clientName = defaults['clientName'] as String?;
          _projectType = projectType;
          _civilIdController.text = _existingCivilId ?? '';
          _projectAddressController.text = _existingProjectAddress ?? '';
          _companySignerNameController.text =
              defaults['companySignerName'] as String? ?? 'محمود محسن';
          _designNotesController.text = _asStringList(
            defaults['designNotes'],
          ).join('\n');
          _executionNotesController.text = _asStringList(
            defaults['executionNotes'],
          ).join('\n');
          _executionDurationDaysController.text =
              (defaults['executionDurationDays'] as num?)?.toInt().toString() ??
              '';
          _ensureDefaultScopeRow(projectType);
          _isLoadingProject = false;
          _isLoadingTerms = false;
        });
      }
    } catch (e) {
      await _loadProjectDataFallback();
    }
  }

  Future<void> _loadProjectDataFallback() async {
    try {
      final project = await _projectsApi.getProjectById(widget.projectId);
      final projectType = project['type'] as String? ?? 'EXECUTION';
      _ensureDefaultScopeRow(projectType);
      await _loadDefaultTerms(projectType);
      if (mounted) {
        setState(() {
          _existingCivilId = project['clientCivilId'] as String?;
          _existingProjectAddress = project['projectAddress'] as String?;
          _clientName = project['clientName'] as String?;
          _projectType = projectType;
          _civilIdController.text = _existingCivilId ?? '';
          _projectAddressController.text = _existingProjectAddress ?? '';
          _isLoadingProject = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProject = false;
          _isLoadingTerms = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  void _replaceTerms(List<Map<String, dynamic>> terms) {
    for (final term in _contractTerms) {
      term['title']?.dispose();
      term['description']?.dispose();
    }
    _contractTerms = terms.map((term) {
      return {
        'title': TextEditingController(text: term['title']?.toString() ?? ''),
        'description': TextEditingController(
          text: term['description']?.toString() ?? '',
        ),
      };
    }).toList();
    _termsApproved = List.filled(_contractTerms.length, true);
  }

  void _replacePaymentSchedule(List<Map<String, dynamic>> phases) {
    for (final payment in _paymentControllers) {
      payment['phase']?.dispose();
      payment['percentage']?.dispose();
      payment['amount']?.dispose();
    }
    final List<Map<String, dynamic>> source = phases.isNotEmpty
        ? phases
        : <Map<String, dynamic>>[
            <String, dynamic>{
              'phase': '',
              'percentage': 50.0,
              'amount': widget.totalAmount * 0.5,
              'notes': '',
            },
            <String, dynamic>{
              'phase': '',
              'percentage': 50.0,
              'amount': widget.totalAmount * 0.5,
              'notes': '',
            },
          ];
    _paymentPhases = source.map<Map<String, dynamic>>((phase) {
      final percentage = (phase['percentage'] as num?)?.toDouble() ?? 0.0;
      final amount =
          (phase['amount'] as num?)?.toDouble() ??
          widget.totalAmount * (percentage / 100);
      return <String, dynamic>{
        'phase': phase['phase']?.toString() ?? '',
        'percentage': percentage,
        'amount': amount,
        'notes': phase['notes']?.toString() ?? '',
      };
    }).toList();
    _initializePaymentControllers();
  }

  void _replaceDesignScopeItems(List<Map<String, dynamic>> scopeItems) {
    for (final scope in _designScopeControllers) {
      scope['item']?.dispose();
      scope['description']?.dispose();
    }
    _designScopeControllers = scopeItems.map((scope) {
      return {
        'item': TextEditingController(text: scope['item']?.toString() ?? ''),
        'description': TextEditingController(
          text: scope['description']?.toString() ?? '',
        ),
      };
    }).toList();
  }

  Future<void> _loadDefaultTerms(String contractType) async {
    try {
      final terms = await _settingsApi.getDefaultContractTermsForType(
        contractType,
      );
      if (mounted) {
        setState(() {
          _contractTerms = terms.map((term) {
            return {
              'title': TextEditingController(text: term['title'] ?? ''),
              'description': TextEditingController(
                text: term['description'] ?? '',
              ),
            };
          }).toList();
          _termsApproved = List.filled(terms.length, true);
          _isLoadingTerms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTerms = false;
          _errorMessage = 'فشل تحميل بنود العقد الافتراضية';
        });
      }
    }
  }

  bool get _isDesignProject => _projectType == 'DESIGN';

  void _ensureDefaultScopeRow(String projectType) {
    if (projectType != 'DESIGN' || _designScopeControllers.isNotEmpty) {
      return;
    }
    _designScopeControllers = [
      {'item': TextEditingController(), 'description': TextEditingController()},
    ];
  }

  bool _validateStep1() {
    final civilId = _civilIdController.text.trim();
    if (civilId.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال الرقم المدني للعميل';
      });
      return false;
    }
    // Validate Kuwait Civil ID format (12 digits)
    if (civilId.length != 12 || !RegExp(r'^\d+$').hasMatch(civilId)) {
      setState(() {
        _errorMessage = 'الرقم المدني يجب أن يكون 12 رقم';
      });
      return false;
    }
    if (_isDesignProject) {
      final validScopeRows = _designScopeControllers.where((row) {
        return (row['item']?.text.trim().isNotEmpty ?? false) &&
            (row['description']?.text.trim().isNotEmpty ?? false);
      }).length;
      if (validScopeRows == 0) {
        setState(() {
          _errorMessage = 'الرجاء إدخال مساحة واحدة على الأقل لعقد التصميم';
        });
        return false;
      }
    }
    return true;
  }

  bool _validateStep2() {
    if (_contractTerms.isEmpty) {
      setState(() {
        _errorMessage = 'لا توجد بنود عقد للموافقة عليها';
      });
      return false;
    }
    if (!_termsApproved.every((approved) => approved)) {
      setState(() {
        _errorMessage = 'الرجاء الموافقة على جميع البنود';
      });
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (_paymentPhases.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إضافة دفعة واحدة على الأقل';
      });
      return false;
    }
    if (widget.totalAmount <= 0) {
      setState(() {
        _errorMessage = 'لا يمكن إنشاء جدول دفعات بدون قيمة عقد صحيحة';
      });
      return false;
    }
    final totalPercentage = _paymentPhases.fold<double>(
      0.0,
      (sum, phase) => sum + (phase['percentage'] as num).toDouble(),
    );
    if ((totalPercentage - 100.0).abs() > 0.01) {
      setState(() {
        _errorMessage =
            'مجموع النسب يجب أن يساوي 100%. المجموع الحالي: ${totalPercentage.toStringAsFixed(2)}%';
      });
      return false;
    }
    final hasInvalidAmount = _paymentPhases.any(
      (phase) => (phase['amount'] as num).toDouble() <= 0,
    );
    if (hasInvalidAmount) {
      setState(() {
        _errorMessage = 'كل دفعة يجب أن تكون أكبر من صفر';
      });
      return false;
    }
    return true;
  }

  void _addPaymentPhase() {
    setState(() {
      _paymentPhases.add(<String, dynamic>{
        'phase': '',
        'percentage': 0.0,
        'amount': 0.0,
        'notes': '',
      });
      _paymentControllers.add({
        'phase': TextEditingController(),
        'percentage': TextEditingController(text: '0.00'),
        'amount': TextEditingController(text: '0.000'),
        'notes': TextEditingController(),
      });
    });
  }

  void _removePaymentPhase(int index) {
    if (_paymentPhases.length > 1) {
      setState(() {
        _paymentControllers[index]['phase']?.dispose();
        _paymentControllers[index]['percentage']?.dispose();
        _paymentControllers[index]['amount']?.dispose();
        _paymentControllers[index]['notes']?.dispose();
        _paymentPhases.removeAt(index);
        _paymentControllers.removeAt(index);
      });
    }
  }

  void _addDesignScopeItem() {
    setState(() {
      _designScopeControllers.add({
        'item': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeDesignScopeItem(int index) {
    if (_designScopeControllers.length <= 1) {
      return;
    }
    setState(() {
      _designScopeControllers[index]['item']?.dispose();
      _designScopeControllers[index]['description']?.dispose();
      _designScopeControllers.removeAt(index);
    });
  }

  List<String> _splitNotes(TextEditingController controller) {
    return controller.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  void _onPercentageChanged(int index, double value) {
    setState(() {
      final percentage = value.clamp(0.0, 100.0);
      final amount = widget.totalAmount * (percentage / 100);

      _paymentPhases[index]['percentage'] = percentage;
      _paymentPhases[index]['amount'] = amount;
    });

    // Update the amount controller outside setState to avoid cursor reset
    final amountController = _paymentControllers[index]['amount'];
    if (amountController != null) {
      final newAmountText = (_paymentPhases[index]['amount'] as num)
          .toDouble()
          .toStringAsFixed(3);
      // Only update if different to avoid unnecessary updates
      if (amountController.text != newAmountText) {
        amountController.value = TextEditingValue(
          text: newAmountText,
          selection: TextSelection.collapsed(offset: newAmountText.length),
        );
      }
    }
  }

  void _onAmountChanged(int index, double value) {
    setState(() {
      final amount = value.clamp(0.0, widget.totalAmount);
      final percentage = widget.totalAmount > 0
          ? (amount / widget.totalAmount) * 100
          : 0.0;

      _paymentPhases[index]['amount'] = amount;
      _paymentPhases[index]['percentage'] = percentage;
    });

    // Update the percentage controller outside setState to avoid cursor reset
    final percentageController = _paymentControllers[index]['percentage'];
    if (percentageController != null) {
      final newPercentageText = (_paymentPhases[index]['percentage'] as num)
          .toDouble()
          .toStringAsFixed(2);
      // Only update if different to avoid unnecessary updates
      if (percentageController.text != newPercentageText) {
        percentageController.value = TextEditingValue(
          text: newPercentageText,
          selection: TextSelection.collapsed(offset: newPercentageText.length),
        );
      }
    }
  }

  Future<void> _exportPdf() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
    });

    try {
      // Prepare contract terms
      final contractTerms = _contractTerms.map((term) {
        return {
          'title': term['title']?.text.trim() ?? '',
          'description': term['description']?.text.trim() ?? '',
        };
      }).toList();

      // Prepare payment schedule (only send phase and percentage, amount will be calculated on backend)
      final paymentSchedule = _paymentPhases.map((phase) {
        return {
          'phase': phase['phase'] as String,
          'percentage': (phase['percentage'] as num).toDouble(),
          'notes': phase['notes']?.toString(),
        };
      }).toList();
      final designScopeItems = _designScopeControllers
          .map(
            (scope) => {
              'item': scope['item']?.text.trim() ?? '',
              'description': scope['description']?.text.trim() ?? '',
            },
          )
          .where(
            (scope) =>
                (scope['item']?.isNotEmpty ?? false) &&
                (scope['description']?.isNotEmpty ?? false),
          )
          .toList();
      final executionDurationDays = int.tryParse(
        _executionDurationDaysController.text.trim(),
      );

      final pdfBytes = await _contractsApi.exportContractPdf(
        widget.projectId,
        contractType: _projectType,
        civilId: _civilIdController.text.trim(),
        projectAddress: _projectAddressController.text.trim(),
        contractTerms: contractTerms,
        designScopeItems: _isDesignProject ? designScopeItems : null,
        designNotes: _isDesignProject
            ? _splitNotes(_designNotesController)
            : null,
        executionNotes: !_isDesignProject
            ? _splitNotes(_executionNotesController)
            : null,
        executionDurationDays: !_isDesignProject ? executionDurationDays : null,
        companySignerName: _companySignerNameController.text.trim(),
        paymentSchedule: paymentSchedule,
      );

      final filePrefix = _isDesignProject ? 'عقد تصميم' : 'عقد تنفيذ';
      final safeProjectName = widget.projectName
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final safeClientName = (_clientName ?? '')
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final fileName =
          '$filePrefix للسيد ${safeClientName.isEmpty ? 'العميل' : safeClientName} - ${safeProjectName.isEmpty ? 'المشروع' : safeProjectName}.pdf';

      if (mounted) {
        File savedFile;
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          final String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'حفظ عقد PDF',
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (outputFile == null) {
            setState(() {
              _isExporting = false;
            });
            return;
          }

          savedFile = File(outputFile);
          await savedFile.writeAsBytes(pdfBytes);
        } else {
          final directory = await getApplicationDocumentsDirectory();
          savedFile = File('${directory.path}/$fileName');
          await savedFile.writeAsBytes(pdfBytes);
        }

        await OpenFile.open(savedFile.path);

        setState(() {
          _isExporting = false;
        });

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تصدير عقد PDF بنجاح'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'فشل تصدير PDF';
        if (e is ServerException) {
          errorMessage = 'فشل تصدير PDF: ${e.message}';
        } else if (e is ValidationException) {
          errorMessage = 'فشل تصدير PDF: ${e.message}';
        } else {
          errorMessage = 'فشل تصدير PDF: ${e.toString()}';
        }
        setState(() {
          _isExporting = false;
          _errorMessage = errorMessage;
        });
      }
    }
  }

  void _goToNextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _validateStep1();
        break;
      case 1:
        isValid = _validateStep2();
        break;
      case 2:
        isValid = _validateStep3();
        break;
    }

    if (isValid) {
      setState(() {
        _errorMessage = null;
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    setState(() {
      _errorMessage = null;
      _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogKeyboardActions(
      enabled: !_isExporting,
      onSubmit: _currentStep < 3 ? _goToNextStep : _exportPdf,
      onClose: () => Navigator.of(context).pop(),
      child: Dialog(
        child: Container(
          width: 700,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تصدير عقد PDF',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stepper
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: _currentStep < 3 ? _goToNextStep : null,
                  onStepCancel: _currentStep > 0 ? _goToPreviousStep : null,
                  controlsBuilder: (context, details) {
                    return const SizedBox.shrink();
                  },
                  steps: [
                    // Step 1: Civil ID
                    Step(
                      title: const Text('الرقم المدني للعميل'),
                      content: ContractExportStep1Content(
                        isLoadingProject: _isLoadingProject,
                        projectType: _projectType,
                        civilIdController: _civilIdController,
                        projectAddressController: _projectAddressController,
                        companySignerNameController:
                            _companySignerNameController,
                        designScopeControllers: _designScopeControllers,
                        designNotesController: _designNotesController,
                        executionNotesController: _executionNotesController,
                        executionDurationDaysController:
                            _executionDurationDaysController,
                        onAddDesignScopeItem: _addDesignScopeItem,
                        onRemoveDesignScopeItem: _removeDesignScopeItem,
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    // Step 2: Terms Approval
                    Step(
                      title: const Text('الموافقة على البنود'),
                      content: ContractExportStep2Content(
                        isLoadingTerms: _isLoadingTerms,
                        contractTerms: _contractTerms,
                        termsApproved: _termsApproved,
                        onApproveAll: () {
                          setState(() {
                            _termsApproved = List.filled(
                              _contractTerms.length,
                              true,
                            );
                          });
                        },
                        onToggleApproved: (index) {
                          setState(() {
                            _termsApproved[index] = !_termsApproved[index];
                          });
                        },
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    // Step 3: Payment Schedule
                    Step(
                      title: const Text('جدول الدفعات'),
                      content: ContractExportStep3Content(
                        totalAmount: widget.totalAmount,
                        paymentPhases: _paymentPhases,
                        paymentControllers: _paymentControllers,
                        onAddPaymentPhase: _addPaymentPhase,
                        onRemovePaymentPhase: _removePaymentPhase,
                        onPercentageChanged: _onPercentageChanged,
                        onAmountChanged: _onAmountChanged,
                        onNotesChanged: (index, value) {
                          setState(() {
                            _paymentPhases[index]['notes'] = value;
                          });
                        },
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    // Step 4: Export
                    Step(
                      title: const Text('تصدير PDF'),
                      content: ContractExportStep4Content(
                        isExporting: _isExporting,
                        projectType: _projectType,
                        civilIdController: _civilIdController,
                        projectAddressController: _projectAddressController,
                        contractTermsCount: _contractTerms.length,
                        paymentPhasesCount: _paymentPhases.length,
                        designScopeCount: _designScopeControllers.where((row) {
                          return (row['item']?.text.trim().isNotEmpty ??
                                  false) &&
                              (row['description']?.text.trim().isNotEmpty ??
                                  false);
                        }).length,
                        onExportPdf: _exportPdf,
                      ),
                      isActive: _currentStep >= 3,
                      state: StepState.complete,
                    ),
                  ],
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isExporting ? null : _goToPreviousStep,
                      child: const Text('السابق'),
                    ),
                  ],
                  if (_currentStep < 3) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isExporting ? null : _goToNextStep,
                      child: const Text('التالي'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
