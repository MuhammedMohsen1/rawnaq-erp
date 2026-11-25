/// Converts Arabic-Indic and Eastern Arabic-Indic digits to ASCII digits.
class ArabicNumberTransformer {
  static final _digits = RegExp(r'[٠-٩۰-۹]');

  static String? transformNullable(String? input) =>
      input == null ? null : transform(input);

  static String transform(String input) {
    return input.replaceAllMapped(_digits, (match) {
      final digit = match[0]!.codeUnitAt(0);
      final zero = digit >= 0x06F0 ? 0x06F0 : 0x0660;
      return String.fromCharCode(0x30 + digit - zero);
    });
  }
}
