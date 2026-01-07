import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../features/settings/data/datasources/settings_api_datasource.dart';
import '../../../../features/contracts/data/datasources/contracts_api_datasource.dart';
import '../../../../core/error/exceptions.dart';

class ContractExportDialog extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ContractExportDialog({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  State<ContractExportDialog> createState() => _ContractExportDialogState();
}

class _ContractExportDialogState extends State<ContractExportDialog> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  final ContractsApiDataSource _contractsApi = ContractsApiDataSource();
  final TextEditingController _termsController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingTerms = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDefaultTerms();
  }

  Future<void> _loadDefaultTerms() async {
    try {
      final terms = await _settingsApi.getDefaultContractTerms();
      if (mounted) {
        setState(() {
          _termsController.text = terms;
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

  Future<void> _exportPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pdfBytes = await _contractsApi.exportContractPdf(
        widget.projectId,
        contractTerms: _termsController.text.trim().isNotEmpty
            ? _termsController.text.trim()
            : null,
      );

      // Save PDF file
      final fileName = 'contract-${widget.projectName}-${DateTime.now().toIso8601String().split('T')[0]}.pdf';
      
      if (mounted) {
        File savedFile;
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Desktop platforms - use saveFile dialog
          final String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'حفظ عقد PDF',
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
          
          if (outputFile == null) {
            // User cancelled
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          savedFile = File(outputFile);
          await savedFile.writeAsBytes(pdfBytes);
        } else {
          // Mobile platforms - save to downloads
          final directory = await getApplicationDocumentsDirectory();
          savedFile = File('${directory.path}/$fileName');
          await savedFile.writeAsBytes(pdfBytes);
        }
        
        // Open the file
        await OpenFile.open(savedFile.path);

        setState(() {
          _isLoading = false;
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
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      }
    }
  }

  @override
  void dispose() {
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stepper
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _currentStep == 0
                    ? () {
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    : null,
                onStepCancel: _currentStep == 1
                    ? () {
                        setState(() {
                          _currentStep = 0;
                        });
                      }
                    : null,
                steps: [
                  Step(
                    title: const Text('بنود العقد'),
                    content: _isLoadingTerms
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'يمكنك تعديل بنود العقد قبل التصدير:',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: TextField(
                                  controller: _termsController,
                                  maxLines: null,
                                  expands: true,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل بنود العقد هنا...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: const Text('تصدير PDF'),
                    content: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('جاري تصدير PDF...'),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'جاهز للتصدير. اضغط على زر التصدير لتنزيل ملف PDF.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 24),
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red[700]),
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
                                const SizedBox(height: 16),
                              ],
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _exportPdf,
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text('تصدير PDF'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                ],
              ),
            ),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                if (_currentStep == 0) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
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
}

