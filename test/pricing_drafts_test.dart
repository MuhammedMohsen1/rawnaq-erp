import 'package:flutter_test/flutter_test.dart';
import 'package:rawnaq/features/pricing/domain/entities/pricing_item.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_item_card_local_element.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_drafts.dart';

void main() {
  const first = (itemId: '1', subItemId: '1', field: 'description');
  const second = (itemId: '1', subItemId: '1', field: 'profitMargin');

  test('a new element draft cannot be read as an existing element edit', () {
    final drafts = PricingDrafts();
    addTearDown(drafts.dispose);
    const key = (itemId: '1', subItemId: '1', field: 'temp-1');
    final element = LocalElement(
      tempId: key.field,
      subItemId: key.subItemId,
      name: 'New element',
    );
    drafts.stage(key, element, () async {});

    expect(drafts.value<PricingItem>(key), isNull);
    expect(drafts.valuesFor<LocalElement>('1', '1'), [element]);
    expect(drafts.hasChanges, isTrue);
  });

  test('drafts write only on save and retry only failed changes', () async {
    final drafts = PricingDrafts();
    addTearDown(drafts.dispose);
    var writes = 0;
    var refreshes = 0;
    var shouldFail = true;
    Future<void> refresh() async => refreshes++;

    drafts.stage(first, 'new description', () async => writes++);
    drafts.stage(second, '20', () async {
      if (shouldFail) throw StateError('write failed');
      writes++;
    });

    expect(writes, 0);
    expect(drafts.hasChanges, isTrue);
    expect(await drafts.save(refresh), isNotNull);
    expect(writes, 1);
    expect(drafts.value<String>(first), isNull);
    expect(drafts.value<String>(second), '20');

    shouldFail = false;
    expect(await drafts.save(refresh), isNull);
    expect(writes, 2);
    expect(refreshes, 2);
    expect(drafts.hasChanges, isFalse);
  });

  test('invalid drafts prevent any write and remain editable', () async {
    final drafts = PricingDrafts();
    addTearDown(drafts.dispose);

    drafts.stage(
      first,
      'new description',
      () async => fail('Unexpected write'),
    );
    drafts.stage(second, '', null);

    expect(
      await drafts.save(() async => fail('Unexpected refresh')),
      isNotNull,
    );
    expect(drafts.hasChanges, isTrue);
    expect(drafts.value<String>(second), '');
  });
}
