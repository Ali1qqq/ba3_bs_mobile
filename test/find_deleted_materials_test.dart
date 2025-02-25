import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_items_extensions.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_details.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_items.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Find deleted materials
  group('findDeletedMaterials', () {
    test('returns empty map when no items are deleted (identical bills)', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });

    test('returns deleted items when some items are removed', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 1);
      expect(deletedItems.containsKey('item2'), isTrue);
    });

    test('returns all items when all items are deleted (current bill is empty)', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 2);
      expect(deletedItems.containsKey('item1'), isTrue);
      expect(deletedItems.containsKey('item2'), isTrue);
    });

    test('returns empty map when previous bill is empty (no items to delete)', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });

    test('returns empty map when previous bill has duplicates and one instance is removed', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          // One instance remains
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });

    test('returns only one deleted item when previous bill has duplicates and all instances are removed', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems.length, 1);
      expect(deletedItems.containsKey('item1'), isTrue);
      expect(deletedItems.containsKey('item2'), isFalse);
    });

    test('returns empty map when previous bill has duplicates and one instance of each item is removed', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 2, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          // One instance remains
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
          // One instance remains
        ]),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });

    test('returns empty map when previous and current bills are empty', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final deletedItems = findDeletedMaterials(previousBill: previousBill, currentBill: currentBill);

      expect(deletedItems, isEmpty);
    });
  });

  /// Tests for findBillItemChanges
  group('findBillItemChanges', () {
    test('returns an empty map when there are no changes (identical bills)', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = previousBill; // Identical bill

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated'], isEmpty);
    });

    test('returns deleted items when some items are removed from the bill', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted']?.length, 1);
      expect(itemChanges['deleted']?.any((item) => item.itemGuid == 'item2'), isTrue);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated'], isEmpty);
    });

    test('returns all items as deleted when the current bill is empty', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted']?.length, 2);
      expect(itemChanges['deleted']?.any((item) => item.itemGuid == 'item1'), isTrue);
      expect(itemChanges['deleted']?.any((item) => item.itemGuid == 'item2'), isTrue);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated'], isEmpty);
    });

    test('returns only added items when the previous bill is empty', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new']?.length, 1);
      expect(itemChanges['new']?.any((item) => item.itemGuid == 'item1'), isTrue);
      expect(itemChanges['updated'], isEmpty);
    });

    test('returns updated items when duplicate items are reduced in quantity', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 2, itemTotalPrice: '20'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 3, itemTotalPrice: '30'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 1, itemTotalPrice: '10'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated']?.length, 2);
      expect(itemChanges['updated']?.any((item) => item.itemGuid == 'item1' && item.itemQuantity == -1), isTrue);
      expect(itemChanges['updated']?.any((item) => item.itemGuid == 'item2' && item.itemQuantity == -2), isTrue);
    });

    test('returns an empty map when both previous and current bills are empty', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: []),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated'], isEmpty);
    });

    test('does not detect an update if only the item name or price changes', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Old Name', itemQuantity: 5, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'New Name', itemQuantity: 5, itemTotalPrice: '20'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated'], isEmpty); // No update detected since quantity is the same
    });

    test('detects an item as updated when its quantity increases', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 2, itemTotalPrice: '20'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 5, itemTotalPrice: '50'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated']?.length, 1);
      expect(itemChanges['updated']?.any((item) => item.itemGuid == 'item1' && item.itemQuantity == 3), isTrue);
    });

    test('detects an item as updated when its quantity decreases', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 8, itemTotalPrice: '80'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 4, itemTotalPrice: '40'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty);
      expect(itemChanges['new'], isEmpty);
      expect(itemChanges['updated']?.length, 1);
      expect(itemChanges['updated']?.any((item) => item.itemGuid == 'item1' && item.itemQuantity == -4), isTrue);
    });

    test('detects an item as deleted and newly added when it is removed and re-added with different quantity', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 5, itemTotalPrice: '50'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 10, itemTotalPrice: '100'),
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted'], isEmpty); // The item was removed first
      expect(itemChanges['new'], isEmpty); // Then it was re-added as a new item
      expect(itemChanges['updated'], isNotEmpty);
      expect(itemChanges['updated']?.length, 1);
      expect(itemChanges['updated']?.any((item) => item.itemGuid == 'item1' && item.itemQuantity == 5), isTrue);
    });

    test('detects multiple additions, deletions, and updates in one operation', () {
      final previousBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 2, itemTotalPrice: '20'),
          BillItem(itemGuid: 'item2', itemName: 'Item 2', itemQuantity: 3, itemTotalPrice: '30'),
          BillItem(itemGuid: 'item3', itemName: 'Item 3', itemQuantity: 1, itemTotalPrice: '10'),
        ]),
      );

      final currentBill = BillModel(
        billTypeModel: BillTypeModel(),
        billDetails: BillDetails(),
        status: Status.approved,
        items: BillItems(itemList: [
          BillItem(itemGuid: 'item1', itemName: 'Item 1', itemQuantity: 5, itemTotalPrice: '50'), // Quantity increased
          BillItem(itemGuid: 'item4', itemName: 'Item 4', itemQuantity: 2, itemTotalPrice: '20'), // New item
        ]),
      );

      final itemChanges = findBillItemChanges(
        previousItems: previousBill.items.itemList,
        currentItems: currentBill.items.itemList,
      );

      expect(itemChanges['deleted']?.length, 2);
      expect(itemChanges['deleted']?.any((item) => item.itemGuid == 'item2'), isTrue);
      expect(itemChanges['deleted']?.any((item) => item.itemGuid == 'item3'), isTrue);

      expect(itemChanges['new']?.length, 1);
      expect(itemChanges['new']?.any((item) => item.itemGuid == 'item4' && item.itemQuantity == 2), isTrue);

      expect(itemChanges['updated']?.length, 1);
      expect(itemChanges['updated']?.any((item) => item.itemGuid == 'item1' && item.itemQuantity == 3), isTrue);
    });
  });
}

Map<String, List<BillItem>> findDeletedMaterials({required BillModel previousBill, required BillModel currentBill}) {
  final previousGroupedItems = previousBill.items.itemList.groupBy((item) => item.itemGuid);
  final currentGroupedItems = currentBill.items.itemList.groupBy((item) => item.itemGuid);

  return Map.fromEntries(
    previousGroupedItems.entries.where(
      (entry) => !currentGroupedItems.containsKey(entry.key),
    ),
  );
}

Map<String, List<BillItem>> findBillItemChanges({
  required List<BillItem> previousItems,
  required List<BillItem> currentItems,
}) {
  // Merge repeated items in the previous list.
  final mergedPrevious = previousItems.merge();

  // Merge repeated items in the current list.
  final mergedCurrent = currentItems.merge();

  // Use extension methods to determine differences between the merged lists.
  final newItems = mergedCurrent.subtract(mergedPrevious, (item) => item.itemGuid);
  final deletedItems = mergedPrevious.subtract(mergedCurrent, (item) => item.itemGuid);

  // Find updated items among common items.
  // Identify updated items with adjusted quantities.
  final updatedItems = mergedCurrent.quantityDiff(
    mergedPrevious,
    (item) => item.itemGuid, // Key selector
    (item) => item.itemQuantity, // Quantity selector
    (item, difference) => item.copyWith(itemQuantity: difference), // Update quantity
  );

  return {
    'new': newItems,
    'deleted': deletedItems,
    'updated': updatedItems,
  };
}
