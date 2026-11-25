import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawnaq/core/constants/app_colors.dart';
import 'package:rawnaq/features/pricing/data/models/pricing_version_model.dart';
import 'package:rawnaq/features/pricing/domain/entities/pricing_item.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_item_card_subitem_body.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_item_card_subitem_widgets.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_item_card_visuals.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_keyboard_dismissal.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_summary_sidebar.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_summary_sidebar_support_widgets.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_table_row.dart';

void main() {
  for (final width in [320.0, 375.0, 430.0, 1100.0]) {
    for (final direction in TextDirection.values) {
      testWidgets('pricing layout at $width dp in ${direction.name}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final isMobile = width < 768;
        final title = direction == TextDirection.rtl
            ? 'بند تسعير التصميم الداخلي والتنفيذ مع وصف تفصيلي طويل للمشروع'
            : 'Interior design and execution pricing with a long project title';
        final subTitle = '$title Detail';
        final subItem = PricingSubItemModel(
          id: 'sub',
          pricingItemId: 'item',
          name: subTitle,
          isHidden: false,
          order: 0,
          createdAt: DateTime(2026),
        );
        final description = TextEditingController(text: subTitle);
        final focus = FocusNode();
        addTearDown(description.dispose);
        addTearDown(focus.dispose);
        const deduction = Key('deduction');
        const profit = Key('profit');

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(width == 320 ? 1.5 : 1),
                ),
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: width - (isMobile ? 64 : 0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PricingItemCardHeader(
                              itemName: title,
                              itemIsHidden: false,
                              onVisibilityChanged: (_) {},
                              onToggleExpanded: () {},
                              onMenuPressed: () {},
                              isExpanded: true,
                              canShowFinancials: true,
                              showFinancials: true,
                              canViewFinancials: true,
                              totalCost: 100,
                              profitAmount: 20,
                              pricingStatus: 'APPROVED',
                            ),
                            PricingSubItemHeader(
                              index: 0,
                              canReorderSubItems: false,
                              isExpanded: true,
                              subItem: subItem,
                              hasSubItemImages: width != 375,
                              showFinancials: true,
                              canViewFinancials: true,
                              totalCost: 100,
                              profitAmount: 20,
                              onToggleExpanded: () {},
                              onToggleVisibility: (_) {},
                              onShowMenu: () {},
                            ),
                            PricingSubItemBody(
                              subItem: subItem,
                              showFinancials: true,
                              hasImagesOrUploading: width != 375,
                              isUploadingImage: width != 375,
                              selectedImageIndex: const {},
                              deletingImages: const {},
                              uploadingImages: const {},
                              onPickImages: () {},
                              onPickImagesWithFilePicker: () {},
                              onDeleteCurrentImage: () {},
                              onCropCurrentImage: () {},
                              onShowFullScreenImage: () {},
                              elementRows: [
                                PricingTableRow(
                                  key: const ValueKey('element'),
                                  item: PricingItem(
                                    id: 'element',
                                    description: title,
                                    total: 100,
                                  ),
                                  onDelete: () {},
                                ),
                              ],
                              onReorderElements: (_, _) {},
                              onAddElement: () {},
                              descriptionController: description,
                              descriptionFocusNode: focus,
                            ),
                            const PricingSummaryControls(
                              children: [
                                SizedBox(key: deduction, height: 44),
                                SizedBox(key: profit, height: 44),
                              ],
                            ),
                            PricingSummaryExportActions(
                              isMobile: isMobile,
                              showReturnToPricing: false,
                              isAdminOrManager: true,
                              isApproved: false,
                              isProfitPending: false,
                              isUnderPricing: true,
                              isDraft: true,
                              onSubmit: () {},
                              onReturnToPricing: null,
                              onArchiveProject: null,
                              onConfirmPricing: null,
                              onExportPdf: null,
                              onExportImages: null,
                              onExportContractPdf: null,
                              onConfirmContract: null,
                              onReturnContractToPricing: null,
                              exportOptions: const PricingExportOptions(
                                showDeductionBreakdown: false,
                                showLineItemPrices: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        for (final heading in [title, subTitle]) {
          final match = find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == heading,
          );
          final text = tester.widget<Text>(match);
          expect(text.maxLines, isMobile ? isNull : 1);
          expect(tester.getSize(match).width, greaterThan(100));
        }
        if (isMobile) {
          final details = find.byWidgetPredicate(
            (widget) => widget is TextField && widget.controller == description,
          );
          final imageArea = width != 375
              ? find.byType(PricingSubItemImagesPanel)
              : find.byType(PricingSubItemAddImagesButton);
          expect(
            tester.getTopLeft(imageArea).dy,
            lessThan(tester.getTopLeft(details).dy),
          );
          expect(
            tester.getTopLeft(details).dy,
            lessThan(tester.getTopLeft(find.byType(PricingTableRow)).dy),
          );
        }
        if (isMobile) {
          final action = find.text('إرسال التسعير للتوقيع');
          expect(tester.widget<Text>(action).style!.fontSize, 16);
          final button = find.ancestor(
            of: action,
            matching: find.byType(ElevatedButton),
          );
          expect(tester.getSize(button).height, greaterThanOrEqualTo(52));
          expect(
            tester
                .widget<ElevatedButton>(button)
                .style!
                .backgroundColor!
                .resolve({}),
            const Color(0xFF135BEC),
          );
        }
        final deductionTop = tester.getTopLeft(find.byKey(deduction)).dy;
        final profitTop = tester.getTopLeft(find.byKey(profit)).dy;
        expect(
          profitTop,
          width == 320 ? greaterThan(deductionTop) : deductionTop,
        );
      });
    }
  }

  testWidgets('deduction checkbox has a white check on blue in light mode', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    bool? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PricingSummaryDeductionControl(
            isAdminOrManager: true,
            isMobile: true,
            deductionController: controller,
            deductionFocusNode: focus,
            showLineItemPricesInPdf: true,
            onShowLineItemPricesChanged: (value) => selected = value,
            onDeductionChanged: (_) {},
          ),
        ),
      ),
    );
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.activeColor, AppColors.light.buttonPrimary);
    expect(checkbox.checkColor, Colors.white);
    await tester.tap(find.byType(Checkbox));
    expect(selected, isFalse);
  });

  testWidgets('a touch outside dismisses focus without consuming the action', (
    tester,
  ) async {
    final first = FocusNode();
    final second = FocusNode();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          body: PricingKeyboardDismissal(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  TextField(focusNode: first),
                  TextField(focusNode: second),
                  TextButton(
                    onPressed: () => pressed = true,
                    child: const Text('Action'),
                  ),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'Unsaved');
    expect(first.hasFocus, isTrue);
    await tester.tap(
      find.byType(TextField).last,
      kind: PointerDeviceKind.touch,
    );
    await tester.pump();
    expect(second.hasFocus, isTrue);
    await tester.tap(find.text('Action'), kind: PointerDeviceKind.touch);
    await tester.pump();
    expect(second.hasFocus, isFalse);
    expect(pressed, isTrue);
    second.requestFocus();
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    expect(second.hasFocus, isFalse);
    expect(find.text('Unsaved'), findsOneWidget);
  });
}
