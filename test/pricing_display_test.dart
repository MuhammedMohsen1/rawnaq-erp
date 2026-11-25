import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawnaq/core/theme/app_theme.dart';
import 'package:rawnaq/features/pricing/data/models/pricing_version_model.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_item_card_subitem_widgets.dart';

void main() {
  testWidgets('light sub-item has a visible check and LTR ASCII amounts', (
    tester,
  ) async {
    final subItem = PricingSubItemModel(
      id: 'subitem',
      pricingItemId: 'item',
      name: 'بند ١۲',
      isHidden: false,
      totalCost: 23,
      profitAmount: 6.9,
      order: 0,
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PricingSubItemHeader(
              index: 0,
              canReorderSubItems: false,
              isExpanded: false,
              subItem: subItem,
              hasSubItemImages: false,
              showFinancials: true,
              canViewFinancials: true,
              totalCost: 23,
              profitAmount: 6.9,
              onToggleExpanded: () {},
              onToggleVisibility: (_) {},
              onShowMenu: () {},
            ),
          ),
        ),
      ),
    );

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
    expect(checkbox.checkColor, Colors.white);
    expect(checkbox.activeColor!.computeLuminance(), lessThan(0.25));
    expect(find.text('بند 12'), findsOneWidget);
    for (final amount in ['23.00 KD', '6.90 KD']) {
      expect(
        tester.widget<Text>(find.text(amount)).textDirection,
        TextDirection.ltr,
      );
    }
    expect(find.byTooltip('صافي الربح'), findsOneWidget);
  });
}
