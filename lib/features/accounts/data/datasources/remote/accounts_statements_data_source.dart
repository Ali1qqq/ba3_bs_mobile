import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/compound_datasource_base.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';

import '../../../../../core/models/query_filter.dart';
import '../../../../bond/data/models/entry_bond_model.dart';

class AccountsStatementsDatasource extends CompoundDatasourceBase<EntryBondItems, AccountEntity> {
  AccountsStatementsDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.accountsStatements; // Collection name in Firestore

  @override
  Future<List<EntryBondItems>> fetchAll({required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final dataList = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
    );

    // Flatten and map data['items'] into a single list of EntryBondItems
    final entryBondItems = dataList.map((item) => EntryBondItems.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<List<EntryBondItems>> fetchWhere<V>({
    required AccountEntity itemTypeModel,
    required String field,
    required V value,
    DateFilter? dateFilter,
  }) async {
    final dataList = await compoundDatabaseService.fetchWhere(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: getRootDocumentId(itemTypeModel),
      subCollectionPath: getSubCollectionPath(itemTypeModel),
      field: field,
      value: value,
      dateFilter: dateFilter,
    );

    // Flatten and map data['items'] into a single list of EntryBondItems
    final entryBondItems = dataList.map((item) => EntryBondItems.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<EntryBondItems> fetchById({required String id, required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return EntryBondItems.fromJson(data);
  }

  @override
  Future<void> delete({required EntryBondItems item}) async {
    final account = item.itemList.first.account;

    final rootDocumentId = getRootDocumentId(account);
    final subcollectionPath = getSubCollectionPath(account);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: item.docId ??  item.id,
    );
  }

  @override
  Future<EntryBondItems> save({required EntryBondItems item}) async {
    final account = item.itemList.first.account;

    final rootDocumentId = getRootDocumentId(account);
    final subCollectionPath = getSubCollectionPath(account);

    final savedData = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.docId ?? item.id,
      data: {'items': item.itemList.map((item) => item.toJson()).toList()},
    );

    return EntryBondItems.fromJson(savedData);
  }

  @override
  Future<int> countDocuments({required AccountEntity itemTypeModel, QueryFilter? countQueryFilter}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final count = await compoundDatabaseService.countDocuments(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      countQueryFilter: countQueryFilter,
    );

    return count;
  }

  @override
  Future<Map<AccountEntity, List<EntryBondItems>>> fetchAllNested({required List<AccountEntity> itemTypes}) async {
    final billsByType = <AccountEntity, List<EntryBondItems>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final billTypeModel in itemTypes) {
      fetchTasks.add(
        fetchAll(itemTypeModel: billTypeModel).then((result) {
          billsByType[billTypeModel] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<Map<AccountEntity, List<EntryBondItems>>> saveAllNested(
      {required List<AccountEntity> itemTypes, required List<EntryBondItems> items}) async {
    final billsByType = <AccountEntity, List<EntryBondItems>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final accountEntity in itemTypes) {
      fetchTasks.add(
        saveAll(
            itemTypeModel: accountEntity,
            items: items
                .where(
                  (element) => element.itemList.first.account.id == accountEntity.id,
            )
                .toList())
            .then((result) {
          billsByType[accountEntity] = result;
        }),
      );
    }

    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<List<EntryBondItems>> saveAll({required List<EntryBondItems> items, required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final savedData = await compoundDatabaseService.saveAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) {
        return {
          ...item.toJson(),
          'docId': item.id,
        };
      }).toList(),
    );

    return savedData.map(EntryBondItems.fromJson).toList();
  }
}
