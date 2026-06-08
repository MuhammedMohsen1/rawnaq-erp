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
  final List<_ContractTermControllers> _designTerms = [];
  final List<_ContractTermControllers> _executionTerms = [];
  bool _isLoading = true;
  bool _isSaving = false;
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

      _replaceTerms(_designTerms, terms['designTerms'] ?? const []);
      _replaceTerms(_executionTerms, terms['executionTerms'] ?? const []);

      setState(() {
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

  void _replaceTerms(
    List<_ContractTermControllers> target,
    List<Map<String, String>> source,
  ) {
    for (final term in target) {
      term.dispose();
    }
    target
      ..clear()
      ..addAll(
        (source.isEmpty ? [{}] : source).map(
          (term) => _ContractTermControllers(
            title: term['title'] ?? '',
            description: term['description'] ?? '',
          ),
        ),
      );
  }

  void _addTerm(List<_ContractTermControllers> target) {
    setState(() {
      target.add(_ContractTermControllers());
      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _removeTerm(List<_ContractTermControllers> target, int index) {
    if (target.length <= 1) return;
    setState(() {
      target[index].dispose();
      target.removeAt(index);
      _errorMessage = null;
      _successMessage = null;
    });
  }

  String? _validateGroup(String label, List<_ContractTermControllers> terms) {
    for (final term in terms) {
      if (term.title.text.trim().isEmpty ||
          term.description.text.trim().isEmpty) {
        return 'جميع بنود $label يجب أن تحتوي على عنوان ووصف';
      }
    }
    return null;
  }

  Future<void> _saveTerms() async {
    final designValidation = _validateGroup('عقد التصميم', _designTerms);
    if (designValidation != null) {
      setState(() {
        _errorMessage = designValidation;
        _successMessage = null;
      });
      return;
    }

    final executionValidation = _validateGroup('عقد التنفيذ', _executionTerms);
    if (executionValidation != null) {
      setState(() {
        _errorMessage = executionValidation;
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
      await _settingsApi.updateDefaultContractTerms(
        designTerms: _serialize(_designTerms),
        executionTerms: _serialize(_executionTerms),
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _successMessage = 'تم حفظ بنود عقود التصميم والتنفيذ بنجاح';
      });
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'فشل حفظ بنود العقد';
      if (e is ServerException || e is ValidationException) {
        errorMessage = 'فشل حفظ بنود العقد: ${(e as dynamic).message}';
      }
      setState(() {
        _isSaving = false;
        _errorMessage = errorMessage;
      });
    }
  }

  List<Map<String, String>> _serialize(List<_ContractTermControllers> terms) {
    return terms
        .map(
          (term) => {
            'title': term.title.text.trim(),
            'description': term.description.text.trim(),
          },
        )
        .toList();
  }

  @override
  void dispose() {
    for (final term in [..._designTerms, ..._executionTerms]) {
      term.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'يمكنك إدارة البنود الافتراضية بشكل منفصل لعقد التصميم وعقد التنفيذ.',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _TermsSectionCard(
              title: 'بنود عقد التصميم',
              subtitle: 'تستخدم تلقائيا عند تصدير عقد تصميم',
              terms: _designTerms,
              onAdd: () => _addTerm(_designTerms),
              onRemove: (index) => _removeTerm(_designTerms, index),
            ),
            const SizedBox(height: 16),
            _TermsSectionCard(
              title: 'بنود عقد التنفيذ',
              subtitle: 'تستخدم تلقائيا عند تصدير عقد تنفيذ',
              terms: _executionTerms,
              onAdd: () => _addTerm(_executionTerms),
              onRemove: (index) => _removeTerm(_executionTerms, index),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(color: Colors.red[700]),
                ),
              ),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _successMessage!,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveTerms,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'جار الحفظ...' : 'حفظ جميع البنود'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSectionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<_ContractTermControllers> terms;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _TermsSectionCard({
    required this.title,
    required this.subtitle,
    required this.terms,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_TermsSectionCard> createState() => _TermsSectionCardState();
}

class _TermsSectionCardState extends State<_TermsSectionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.tableCellBold,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAdd,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة بند'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.terms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final term = entry.value;
                    return _TermAccordionCard(
                      key: ValueKey('${widget.title}-term-$index'),
                      index: index,
                      term: term,
                      canDelete: widget.terms.length > 1,
                      onRemove: () => widget.onRemove(index),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TermAccordionCard extends StatefulWidget {
  final int index;
  final _ContractTermControllers term;
  final bool canDelete;
  final VoidCallback onRemove;

  const _TermAccordionCard({
    super.key,
    required this.index,
    required this.term,
    required this.canDelete,
    required this.onRemove,
  });

  @override
  State<_TermAccordionCard> createState() => _TermAccordionCardState();
}

class _TermAccordionCardState extends State<_TermAccordionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.term.title.text.trim().isEmpty
                              ? 'بند ${widget.index + 1}'
                              : widget.term.title.text.trim(),
                          style: AppTextStyles.tableCellBold,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اضغط لعرض وتعديل العنوان والوصف',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  if (widget.canDelete) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'حذف البند',
                    ),
                  ],
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),

          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: widget.term.title,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: widget.term.description,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'الوصف',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
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
      child: Center(child: CircularProgressIndicator()),
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

  @override
  Widget build(BuildContext context) {
    final isError = type == ContractTermsMessageType.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red[300]! : Colors.green[300]!,
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(
          color: isError ? Colors.red[700] : Colors.green[700],
        ),
      ),
    );
  }
}
