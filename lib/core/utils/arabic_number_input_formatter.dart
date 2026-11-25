import 'package:flutter/services.dart';

import 'arabic_number_transformer.dart';

/// Normalizes Arabic and Persian digits in committed text input.
/// Put this before formatters that restrict input to ASCII digits.
class ArabicNumberInputFormatter extends TextInputFormatter {
  const ArabicNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;

    final text = ArabicNumberTransformer.transform(newValue.text);
    return text == newValue.text ? newValue : newValue.copyWith(text: text);
  }
}
