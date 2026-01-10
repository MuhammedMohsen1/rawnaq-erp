/// Utility class for transforming Arabic-Indic numerals to Western numerals
class ArabicNumberTransformer {
  /// Mapping of Arabic-Indic digits (٠-٩) to Western digits (0-9)
  static const Map<String, String> _arabicToEnglish = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// Transforms a string containing Arabic-Indic numerals to Western numerals
  ///
  /// Example:
  /// ```dart
  /// ArabicNumberTransformer.transform('١٢٣'); // Returns '123'
  /// ArabicNumberTransformer.transform('١٢.٥'); // Returns '12.5'
  /// ArabicNumberTransformer.transform('abc'); // Returns 'abc'
  /// ```
  static String transform(String input) {
    if (input.isEmpty) return input;

    return input.split('').map((char) {
      return _arabicToEnglish[char] ?? char;
    }).join();
  }
}
