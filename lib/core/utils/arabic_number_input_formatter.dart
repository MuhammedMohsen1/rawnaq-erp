import 'package:flutter/services.dart';
import 'arabic_number_transformer.dart';

/// TextInputFormatter that automatically transforms Arabic-Indic numerals to Western numerals
///
/// This formatter should be used with numeric input fields to allow users to type
/// Arabic numerals (٠-٩) which will automatically be converted to Western numerals (0-9).
///
/// Example usage:
/// ```dart
/// TextField(
///   inputFormatters: [
///     ArabicNumberInputFormatter(),
///     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
///   ],
///   keyboardType: TextInputType.number,
/// )
/// ```
class ArabicNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Transform Arabic numerals to English
    final transformed = ArabicNumberTransformer.transform(newValue.text);

    // If the text hasn't changed after transformation, return as-is
    if (transformed == newValue.text) {
      return newValue;
    }

    // Return new value with transformed text
    // Maintain cursor position at the end of the text
    return TextEditingValue(
      text: transformed,
      selection: TextSelection.collapsed(offset: transformed.length),
    );
  }
}
