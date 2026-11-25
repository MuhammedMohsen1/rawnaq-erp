import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:rawnaq/core/widgets/custom_text_field.dart';

void main() {
  const formatter = ArabicNumberInputFormatter();

  test('normalizes both digit sets while preserving the selection', () {
    const edit = TextEditingValue(
      text: 'مشروع ٠١٢٣٤٥٦٧٨٩ / ۰۱۲۳۴۵۶۷۸۹',
      selection: TextSelection(baseOffset: 7, extentOffset: 11),
    );
    final result = formatter.formatEditUpdate(TextEditingValue.empty, edit);

    expect(result.text, 'مشروع 0123456789 / 0123456789');
    expect(result.selection, edit.selection);
  });

  test('normalizes digits after the keyboard commits composing text', () {
    const composing = TextEditingValue(
      text: '١٢',
      composing: TextRange(start: 0, end: 2),
    );
    expect(
      formatter.formatEditUpdate(TextEditingValue.empty, composing),
      composing,
    );
    expect(
      formatter
          .formatEditUpdate(
            composing,
            composing.copyWith(composing: TextRange.empty),
          )
          .text,
      '12',
    );
  });

  testWidgets('shared text fields normalize input before their filters', (
    tester,
  ) async {
    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (text) => value = text,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '١٢۳');
    expect(value, '123');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '123',
    );
  });
}
