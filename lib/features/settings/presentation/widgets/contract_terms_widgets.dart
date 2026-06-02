import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/settings_api_datasource.dart';

class ContractTermsEditor extends StatefulWidget {
  const ContractTermsEditor({super.key});

  @override
  State<ContractTermsEditor> createState() => _ContractTermsEditorState();
}

class _ContractTermsEditorState extends State<ContractTermsEditor> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  final List<_ContractTermControllers> _terms = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _expandedIndex = 0;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final terms = await _settingsApi.getDefaultContractTerms();

      if (!mounted) return;

      final nextTerms = terms.map<_ContractTermControllers>((term) {
        return _ContractTermControllers(
          title: term['title'] ?? '',
          description: term['description'] ?? '',
        );
      }).toList();

      if (nextTerms.isEmpty) {
        nextTerms.add(_ContractTermControllers());
      }

      _disposeTerms();

      setState(() {
        _terms
          ..clear()
          ..addAll(nextTerms);
        _expandedIndex = 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل بنود العقد';
      });
    }
  }

  void _addTerm() {
    setState(() {
      _terms.add(_ContractTermControllers());
      _expandedIndex = _terms.length - 1;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _removeTerm(int index) {
    if (_terms.length <= 1) return;

    setState(() {
      _terms[index].dispose();
      _terms.removeAt(index);

      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else if (_expandedIndex != null && _expandedIndex! > index) {
        _expandedIndex = _expandedIndex! - 1;
      }

      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _toggleTerm(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  String? _validateTerms() {
    for (var i = 0; i < _terms.length; i++) {
      final title = _terms[i].title.text.trim();
      final description = _terms[i].description.text.trim();

      if (title.isEmpty) {
        _expandedIndex = i;
        return 'جميع البنود يجب أن تحتوي على عنوان';
      }

      if (description.isEmpty) {
        _expandedIndex = i;
        return 'جميع البنود يجب أن تحتوي على وصف';
      }
    }

    return null;
  }

  Future<void> _saveTerms() async {
    final validationMessage = _validateTerms();

    if (validationMessage != null) {
      setState(() {
        _errorMessage = validationMessage;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final termsToSave = _terms.map((term) {
        return {
          'title': term.title.text.trim(),
          'description': term.description.text.trim(),
        };
      }).toList();

      await _settingsApi.updateDefaultContractTerms(termsToSave);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _successMessage = 'تم حفظ بنود العقد بنجاح';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ بنود العقد بنجاح',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;

        setState(() {
          _successMessage = null;
        });
      });
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'فشل حفظ بنود العقد';

      if (e is ServerException) {
        errorMessage = 'فشل حفظ بنود العقد: ${e.message}';
      } else if (e is ValidationException) {
        errorMessage = 'فشل حفظ بنود العقد: ${e.message}';
      } else {
        errorMessage = 'فشل حفظ بنود العقد: ${e.toString()}';
      }

      setState(() {
        _isSaving = false;
        _errorMessage = errorMessage;
      });
    }
  }

  void _disposeTerms() {
    for (final term in _terms) {
      term.dispose();
    }
  }

  @override
  void dispose() {
    _disposeTerms();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ContractTermsLoading();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'يمكنك تعديل بنود العقد الافتراضية التي ستظهر عند تصدير عقود PDF. اضغط على أي بند لفتحه وتعديله.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ContractTermsToolbar(count: _terms.length, onAdd: _addTerm),
          const SizedBox(height: 12),
          ...List.generate(_terms.length, (index) {
            final term = _terms[index];

            return ContractTermAccordionCard(
              index: index,
              isExpanded: _expandedIndex == index,
              canDelete: _terms.length > 1,
              titleController: term.title,
              descriptionController: term.description,
              onToggle: () => _toggleTerm(index),
              onDelete: () => _removeTerm(index),
              fieldDecoration: _fieldDecoration,
            );
          }),
          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            ContractTermsMessage(
              message: _errorMessage!,
              type: ContractTermsMessageType.error,
            ),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 4),
            ContractTermsMessage(
              message: _successMessage!,
              type: ContractTermsMessageType.success,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _saveTerms,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 19),
              label: Text(
                _isSaving ? 'جار الحفظ...' : 'حفظ جميع البنود',
                style: AppTextStyles.tableCellBold.copyWith(
                  color: AppColors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
                textStyle: AppTextStyles.tableCellBold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractTermControllers {
  final TextEditingController title;
  final TextEditingController description;

  _ContractTermControllers({String title = '', String description = ''})
    : title = TextEditingController(text: title),
      description = TextEditingController(text: description);

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

class ContractTermsLoading extends StatelessWidget {
  const ContractTermsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class ContractTermsToolbar extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;

  const ContractTermsToolbar({
    super.key,
    required this.count,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 420;

        final countChip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_list_numbered_rtl,
                color: AppColors.primary,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                'عدد البنود: $count',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

        final addButton = OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('إضافة بند'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.28)),
            textStyle: AppTextStyles.tableCellBold,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (isTight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [countChip, const SizedBox(height: 8), addButton],
          );
        }

        return Row(children: [countChip, const Spacer(), addButton]);
      },
    );
  }
}

class ContractTermAccordionCard extends StatelessWidget {
  final int index;
  final bool isExpanded;
  final bool canDelete;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final InputDecoration Function({
    required String label,
    required String hint,
    required IconData icon,
  })
  fieldDecoration;

  const ContractTermAccordionCard({
    super.key,
    required this.index,
    required this.isExpanded,
    required this.canDelete,
    required this.titleController,
    required this.descriptionController,
    required this.onToggle,
    required this.onDelete,
    required this.fieldDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final description = descriptionController.text.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppColors.primary.withValues(alpha: 0.035)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.32)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.tableCellBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: titleController,
                        builder: (context, value, _) {
                          final currentTitle = value.text.trim();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTitle.isEmpty
                                    ? 'بند ${index + 1}'
                                    : currentTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.tableCellBold.copyWith(
                                  color: currentTitle.isEmpty
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description.isEmpty
                                    ? 'اضغط لفتح وتعديل بيانات البند'
                                    : description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (canDelete)
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'حذف البند',
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 21,
                          color: Colors.red,
                        ),
                      ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.tableCellBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: fieldDecoration(
                      label: 'العنوان',
                      hint: 'مثال: أولا: التمهيد',
                      icon: Icons.title,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    minLines: 4,
                    maxLines: 7,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: fieldDecoration(
                      label: 'الوصف',
                      hint: 'أدخل نص البند هنا...',
                      icon: Icons.description_outlined,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}

enum ContractTermsMessageType { error, success }

class ContractTermsMessage extends StatelessWidget {
  final String message;
  final ContractTermsMessageType type;

  const ContractTermsMessage({
    super.key,
    required this.message,
    required this.type,
  });

  bool get _isError => type == ContractTermsMessageType.error;

  @override
  Widget build(BuildContext context) {
    final color = _isError ? Colors.red : Colors.green;
    final icon = _isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
