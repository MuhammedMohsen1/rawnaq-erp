import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../features/settings/data/datasources/settings_api_datasource.dart';
import '../../../../features/contracts/data/datasources/contracts_api_datasource.dart';
import '../../../../features/projects/data/datasources/projects_api_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_colors.dart';

class ContractExportDialog extends StatefulWidget {
  final String projectId;
  final String projectName;
  final double totalAmount;

  const ContractExportDialog({
    Key? key,
    required this.projectId,
    required this.projectName,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<ContractExportDialog> createState() => _ContractExportDialogState();
}

class _ContractExportDialogState extends State<ContractExportDialog> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  final ContractsApiDataSource _contractsApi = ContractsApiDataSource();
  final ProjectsApiDataSource _projectsApi = ProjectsApiDataSource();

  // Step 1: Civil ID
  final TextEditingController _civilIdController = TextEditingController();
  final TextEditingController _projectAddressController = TextEditingController();
  String? _existingCivilId;
  String? _existingProjectAddress;
  bool _isLoadingProject = true;

  // Step 2: Terms
  List<Map<String, TextEditingController>> _contractTerms = [];
  List<bool> _termsApproved = [];
  bool _isLoadingTerms = true;

  // Step 3: Payment Schedule
  late List<Map<String, dynamic>> _paymentPhases;

  @override
  void initState() {
    super.initState();
    // Initialize payment phases with default values
    _paymentPhases = [
      {
        'phase': 'دفعة أولى',
        'percentage': 50.0,
        'amount': widget.totalAmount * 0.5,
      },
      {
        'phase': 'دفعة ثانية',
        'percentage': 50.0,
        'amount': widget.totalAmount * 0.5,
      },
    ];
    _loadProjectData();
    _loadDefaultTerms();
  }

  // General
  int _currentStep = 0;
  bool _isExporting = false;
  String? _errorMessage;


  Future<void> _loadProjectData() async {
    try {
      final project = await _projectsApi.getProjectById(widget.projectId);
      if (mounted) {
        setState(() {
          _existingCivilId = project['clientCivilId'] as String?;
          _existingProjectAddress = project['projectAddress'] as String?;
          _civilIdController.text = _existingCivilId ?? '';
          _projectAddressController.text = _existingProjectAddress ?? '';
          _isLoadingProject = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProject = false;
        });
      }
    }
  }

  Future<void> _loadDefaultTerms() async {
    try {
      final terms = await _settingsApi.getDefaultContractTerms();
      if (mounted) {
        setState(() {
          _contractTerms = terms.map((term) {
            return {
              'title': TextEditingController(text: term['title'] ?? ''),
              'description': TextEditingController(text: term['description'] ?? ''),
            };
          }).toList();
          _termsApproved = List.filled(terms.length, false);
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
    return true;
  }

  void _addPaymentPhase() {
    setState(() {
      _paymentPhases.add({'phase': 'دفعة جديدة', 'percentage': 0.0});
      _updatePaymentAmounts();
    });
  }

  void _removePaymentPhase(int index) {
    if (_paymentPhases.length > 1) {
      setState(() {
        _paymentPhases.removeAt(index);
        _updatePaymentAmounts();
      });
    }
  }

  void _updatePaymentAmounts() {
    setState(() {
      for (var phase in _paymentPhases) {
        final percentage = (phase['percentage'] as num).toDouble();
        final amount = widget.totalAmount * (percentage / 100);
        phase['amount'] = amount;
      }
    });
  }

  void _onPercentageChanged(int index, double value) {
    setState(() {
      _paymentPhases[index]['percentage'] = value.clamp(0.0, 100.0);
      _updatePaymentAmounts();
    });
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
        };
      }).toList();

      final pdfBytes = await _contractsApi.exportContractPdf(
        widget.projectId,
        civilId: _civilIdController.text.trim(),
        projectAddress: _projectAddressController.text.trim(),
        contractTerms: contractTerms,
        paymentSchedule: paymentSchedule,
      );

      // Save PDF file
      final fileName =
          'contract-${widget.projectName}-${DateTime.now().toIso8601String().split('T')[0]}.pdf';

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

  @override
  void dispose() {
    _civilIdController.dispose();
    _projectAddressController.dispose();
    for (var term in _contractTerms) {
      term['title']?.dispose();
      term['description']?.dispose();
    }
    super.dispose();
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
    return Dialog(
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                    content: _buildStep1Content(),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  // Step 2: Terms Approval
                  Step(
                    title: const Text('الموافقة على البنود'),
                    content: _buildStep2Content(),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  // Step 3: Payment Schedule
                  Step(
                    title: const Text('جدول الدفعات'),
                    content: _buildStep3Content(),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  // Step 4: Export
                  Step(
                    title: const Text('تصدير PDF'),
                    content: _buildStep4Content(),
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
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
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
    );
  }

  Widget _buildStep1Content() {
    if (_isLoadingProject) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أدخل الرقم المدني للعميل وعنوان المشروع',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _civilIdController,
          decoration: InputDecoration(
            labelText: 'الرقم المدني للعميل (12 رقم)',
            hintText: '298040400214',
            prefixIcon: const Icon(Icons.badge, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 12,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _projectAddressController,
          decoration: InputDecoration(
            labelText: 'عنوان المشروع',
            hintText: 'مثال: قطعة 4 اليرموك - شارع 2 - جادة 2 - منزل 14',
            prefixIcon: const Icon(Icons.location_on, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputFocusBorder, width: 2),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          minLines: 3,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStep2Content() {
    if (_isLoadingTerms) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contractTerms.isEmpty) {
      return const Center(
        child: Text('لا توجد بنود عقد متاحة'),
      );
    }

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'يمكنك تعديل بنود العقد ثم الموافقة عليها:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _termsApproved = List.filled(_contractTerms.length, true);
                  });
                },
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('الموافقة على الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _contractTerms.length,
              itemBuilder: (context, index) {
                final term = _contractTerms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _termsApproved[index]
                        ? Colors.green[900]?.withOpacity(0.2)
                        : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _termsApproved[index]
                          ? Colors.green[300]!
                          : AppColors.border,
                      width: _termsApproved[index] ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _termsApproved[index],
                            onChanged: (value) {
                              setState(() {
                                _termsApproved[index] = value ?? false;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          Expanded(
                            child: Text(
                              'بند ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: term['title'],
                        decoration: InputDecoration(
                          labelText: 'العنوان',
                          hintText: 'مثال: أولا: التمهيد',
                          prefixIcon: const Icon(Icons.title, size: 20, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: term['description'],
                        maxLines: 6,
                        minLines: 4,
                        decoration: InputDecoration(
                          labelText: 'الوصف',
                          hintText: 'أدخل نص البند هنا...',
                          prefixIcon: const Icon(Icons.description, size: 20, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.inputFocusBorder,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Content() {
    final totalPercentage = _paymentPhases.fold<double>(
      0.0,
      (sum, phase) => sum + (phase['percentage'] as num).toDouble(),
    );

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إجمالي المبلغ: ${widget.totalAmount.toStringAsFixed(3)} د.ك',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addPaymentPhase,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة دفعة'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (totalPercentage - 100.0).abs() < 0.01
                ? Colors.green[50]
                : Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (totalPercentage - 100.0).abs() < 0.01
                  ? Colors.green[300]!
                  : Colors.orange[300]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                (totalPercentage - 100.0).abs() < 0.01
                    ? Icons.check_circle
                    : Icons.warning,
                color: (totalPercentage - 100.0).abs() < 0.01
                    ? Colors.green[700]
                    : Colors.orange[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                    (totalPercentage - 100.0).abs() < 0.01
                        ? 'المجموع: 100% ✓'
                        : 'المجموع: ${totalPercentage.toStringAsFixed(2)}% - المتبقي: ${(100.0 - totalPercentage).toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: (totalPercentage - 100.0).abs() < 0.01
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _paymentPhases.length,
            itemBuilder: (context, index) {
              final phase = _paymentPhases[index];
              final percentage = (phase['percentage'] as num).toDouble();
              final amount = phase['amount'] as double? ??
                  (widget.totalAmount * (percentage / 100));

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'دفعة ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_paymentPhases.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _removePaymentPhase(index),
                            tooltip: 'حذف الدفعة',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: TextEditingController(
                              text: phase['phase'] as String,
                            )..selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: (phase['phase'] as String).length,
                                ),
                              ),
                            onChanged: (value) {
                              setState(() {
                                _paymentPhases[index]['phase'] = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'اسم الدفعة',
                              hintText: 'مثال: دفعة أولى',
                              prefixIcon: const Icon(Icons.payment, size: 20, color: AppColors.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.inputFocusBorder,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: TextEditingController(
                              text: percentage.toStringAsFixed(2),
                            )..selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: percentage.toStringAsFixed(2).length,
                                ),
                              ),
                            onChanged: (value) {
                              final newValue = double.tryParse(value) ?? 0.0;
                              _onPercentageChanged(index, newValue);
                            },
                            decoration: InputDecoration(
                              labelText: 'النسبة',
                              suffixText: '%',
                              prefixIcon: const Icon(Icons.percent, size: 20, color: AppColors.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.inputFocusBorder,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ المحسوب:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${amount.toStringAsFixed(3)} د.ك',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Content() {
    if (_isExporting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تصدير PDF...'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مراجعة المعلومات قبل التصدير:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildReviewItem('الرقم المدني', _civilIdController.text),
        _buildReviewItem('عنوان المشروع', _projectAddressController.text),
        _buildReviewItem('عدد البنود', '${_contractTerms.length} بند'),
        _buildReviewItem(
          'عدد الدفعات',
          '${_paymentPhases.length} دفعة',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('تصدير PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textDirection: value.contains(RegExp(r'[ء-ي]'))
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}
