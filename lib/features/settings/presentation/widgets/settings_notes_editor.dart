import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/datasources/settings_api_datasource.dart';
import 'contract_terms_widgets.dart';

class PricingNotesEditor extends StatefulWidget {
  const PricingNotesEditor({super.key});

  @override
  State<PricingNotesEditor> createState() => _PricingNotesEditorState();
}

class _PricingNotesEditorState extends State<PricingNotesEditor> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final notes = await _settingsApi.getDefaultPricingNotes();
      if (!mounted) return;

      setState(() {
        _notesController.text = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل ملاحظات عرض السعر';
      });
    }
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _settingsApi.updateDefaultPricingNotes(
        _notesController.text.trim(),
      );
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _successMessage = 'تم حفظ ملاحظات عرض السعر بنجاح';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ ملاحظات عرض السعر بنجاح',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage = 'فشل حفظ ملاحظات عرض السعر: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ContractTermsLoading();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'كل سطر سيظهر كملاحظة منفصلة في PDF عرض السعر. يمكن تعديل هذه الملاحظات لاحقا داخل كل عرض سعر بدون تغيير الافتراضي.',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            minLines: 4,
            maxLines: 8,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'ملاحظات عرض السعر الافتراضية',
              hintText: 'اكتب كل ملاحظة في سطر منفصل',
              alignLabelWithHint: true,
              prefixIcon: const Icon(
                Icons.notes_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              hintStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            ContractTermsMessage(
              message: _errorMessage!,
              type: ContractTermsMessageType.error,
            ),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 10),
            ContractTermsMessage(
              message: _successMessage!,
              type: ContractTermsMessageType.success,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _saveNotes,
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
                _isSaving ? 'جار الحفظ...' : 'حفظ الملاحظات الافتراضية',
                textAlign: TextAlign.right,
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
