class ChangesModel {
  String? changeId;
  ChangeType? changeType;
  ChangeCollection? changeCollection;
  Map<String, dynamic>? change;

  ChangesModel({
    this.changeId,
    this.changeType,
    this.changeCollection,
    this.change,
  });

  // fromJson
  factory ChangesModel.fromJson(Map<String, dynamic> json) {
    return ChangesModel(
      changeId: json['docId'] ?? '',
      change: json['change'] ?? {},
      changeType: json['changeType'] != null ? ChangeType.values.byName(json['changeType']) : null,
      changeCollection:
          json['changeCollection'] != null ? ChangeCollection.values.byName(json['changeCollection']) : null,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'docId': changeId,
      'changeType': changeType?.name,
      'changeCollection': changeCollection?.name,
      'change': change,
    };
  }

  // copyWith
  ChangesModel copyWith({
    String? changeId,
    ChangeType? changeType,
    ChangeCollection? changeCollection,
    Map<String, dynamic>? change,
  }) {
    return ChangesModel(
      changeId: changeId ?? this.changeId,
      changeType: changeType ?? this.changeType,
      changeCollection: changeCollection ?? this.changeCollection,
      change: change ?? this.change,
    );
  }
}

enum ChangeCollection { bills, accounts, bonds, cheques, users, materials }

enum ChangeType { addOrUpdate, remove }
