import 'package:rawnaq/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pricing_cubit.dart';
import '../cubit/pricing_state.dart';
import 'pricing_drafts.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class PricingSaveButton extends StatelessWidget {
  const PricingSaveButton({
    super.key,
    required this.projectId,
    required this.state,
  });

  final String projectId;
  final PricingLoaded state;

  @override
  Widget build(BuildContext context) {
    final drafts = context.read<PricingDrafts>();
    return ListenableBuilder(
      listenable: drafts,
      builder: (context, _) => FilledButton.icon(
        onPressed: drafts.hasChanges && !drafts.isSaving
            ? () => save(context, projectId, state)
            : null,
        icon: const Icon(Icons.save_outlined),
        label: Text(
          ArabicNumberTransformer.transform(
            drafts.isSaving ? 'جارٍ الحفظ…' : 'حفظ التعديلات',
          ),
        ),
      ),
    );
  }

  static Future<void> save(
    BuildContext context,
    String projectId,
    PricingLoaded state,
  ) async {
    final drafts = context.read<PricingDrafts>();
    if (!drafts.hasChanges || drafts.isSaving) return;

    FocusScope.of(context).unfocus();
    final cubit = context.read<PricingCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final error = await drafts.save(
      () => cubit.loadPricingData(
        projectId,
        readOnly: state.readOnly,
        version: state.pricingVersion.version,
        refreshProfitMargins: true,
      ),
    );
    if (messenger.mounted) {
      final message =
          error ??
          (cubit.state is PricingError
              ? 'تم حفظ التعديلات، وتعذّر تحديث عرض التسعير.'
              : 'تم حفظ التعديلات');
      messenger.showSnackBar(
        AppToast.build(
          tone: error != null || cubit.state is PricingError
              ? ToastTone.error
              : ToastTone.success,
          content: Text(ArabicNumberTransformer.transform(message)),
        ),
      );
    }
  }
}
