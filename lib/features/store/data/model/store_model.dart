class StoreModel {
  final String docId;
  final int storeCode;
  final String storeName;
  final String storeLatinName;
  // final String storeParentGuid;
  // final String storeAcc;
  // final String storeAddress;
  // final String storeKeeper;
  // final int storeBranchMask;
  // final int storeSecurity;

  StoreModel({
    required this.docId,
    required this.storeCode,
    required this.storeName,
    required this.storeLatinName,
    // required this.storeParentGuid,
    // required this.storeAcc,
    // required this.storeAddress,
    // required this.storeKeeper,
    // required this.storeBranchMask,
    // required this.storeSecurity,
  });


  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      docId: json['docId'] as String,
      storeCode: json['StoreCode'] as int,
      storeName: json['StoreName'] as String,
      storeLatinName: json['StoreLatinName'] as String,
      // storeParentGuid: json['StoreParentGuid'] as String,
      // storeAcc: json['StoreAcc'] as String,
      // storeAddress: json['StoreAddress'] as String,
      // storeKeeper: json['StoreKeeper'] as String,
      // storeBranchMask: json['StoreBranchMask'] as int,
      // storeSecurity: json['StoreSecurity'] as int,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'StoreCode': storeCode,
      'StoreName': storeName,
      'StoreLatinName': storeLatinName,
      // 'StoreParentGuid': storeParentGuid,
      // 'StoreAcc': storeAcc,
      // 'StoreAddress': storeAddress,
      // 'StoreKeeper': storeKeeper,
      // 'StoreBranchMask': storeBranchMask,
      // 'StoreSecurity': storeSecurity,
    };
  }


  StoreModel copyWith({
    String? docId,
    int? storeCode,
    String? storeName,
    String? storeLatinName,
    // String? storeParentGuid,
    // String? storeAcc,
    // String? storeAddress,
    // String? storeKeeper,
    // int? storeBranchMask,
    // int? storeSecurity,
  }) {
    return StoreModel(
      docId: docId ?? this.docId,
      storeCode: storeCode ?? this.storeCode,
      storeName: storeName ?? this.storeName,
      storeLatinName: storeLatinName ?? this.storeLatinName,
      // storeParentGuid: storeParentGuid ?? this.storeParentGuid,
      // storeAcc: storeAcc ?? this.storeAcc,
      // storeAddress: storeAddress ?? this.storeAddress,
      // storeKeeper: storeKeeper ?? this.storeKeeper,
      // storeBranchMask: storeBranchMask ?? this.storeBranchMask,
      // storeSecurity: storeSecurity ?? this.storeSecurity,
    );
  }
}
