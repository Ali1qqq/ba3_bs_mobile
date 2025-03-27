/// Represents a model for managing a batch of changes, grouped by collections,
/// with metadata for each collection and the target entity responsible for applying these changes.
class ChangesModel {
  /// Identifier for the user or entity responsible for applying the changes.
  final String targetUserId;

  /// A map where the key represents a collection (e.g., `ChangeCollection.bills`),
  /// and the value is a list of `ChangeItem` objects, each describing an individual change.
  final Map<ChangeCollection, List<ChangeItem>> changeItems;

  /// Constructor to initialize a batch of changes with a target user and collection-wise changes.
  ChangesModel({
    required this.targetUserId,
    required this.changeItems,
  });

  /// Adds or updates a `ChangeItem` for a specific collection.
  ///
  /// - [collection]: The collection where changes occurred (e.g., `ChangeCollection.bills`).
  /// - [changeItem]: The `ChangeItem` to be added or updated.
  void addOrUpdateChange(ChangeCollection collection, ChangeItem changeItem) {
    final changes = changeItems[collection] ?? [];
    final existingIndex = changes.indexWhere(
      (item) => item.change['id'] == changeItem.change['id'],
    );

    if (existingIndex != -1) {
      changes[existingIndex] = changeItem; // Update the existing change item
    } else {
      changes.add(changeItem); // Add a new change item
    }

    changeItems[collection] = changes;
  }

  /// Removes all changes for a specific collection by its key.
  ///
  /// - [collection]: The collection to remove changes for (e.g., `ChangeCollection.bills`).
  void removeChangeByCollection(ChangeCollection collection) {
    changeItems.remove(collection);
  }

  /// Converts the `ChangesModel` into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'docId': targetUserId,
      'changeItems': changeItems.map((ChangeCollection key, List<ChangeItem> value) => MapEntry(
            key.name,
            value.map((item) => item.toJson()).toList(),
          )),
    };
  }

  /// Creates a `ChangesModel` instance from a JSON-compatible map.
  factory ChangesModel.fromJson(Map<String, dynamic> json) {
    return ChangesModel(
      targetUserId: json['docId'] as String,
      changeItems: (json['changeItems'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              ChangeCollection.values.byName(key),
              List<ChangeItem>.from(
                (value as List<dynamic>).map((item) => ChangeItem.fromJson(item)),
              ),
            ),
          ) ??
          {}, // Assign empty map if `changeItems` is null
    );
  }
}

/// Represents an individual change within a collection, including metadata and the change details.
class ChangeItem {
  /// Metadata describing the target and context of the change (e.g., target collection, type).
  final ChangeTarget target;

  /// The details of the change as a map of key-value pairs.
  /// Each map contains the specifics of an individual change.
  final Map<String, dynamic> change;

  /// Constructor to initialize a `ChangeItem` with metadata and the change details.
  ChangeItem({
    required this.target,
    required this.change,
  });

  /// Converts the `ChangeItem` into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'target': target.toJson(),
      'change': change,
    };
  }

  /// Creates a `ChangeItem` instance from a JSON-compatible map.
  factory ChangeItem.fromJson(Map<String, dynamic> json) {
    return ChangeItem(
      target: ChangeTarget.fromJson(json['target']),
      change: Map<String, dynamic>.from(json['change']),
    );
  }
}

/// Represents metadata for a change, including the collection and type of change.
class ChangeTarget {
  /// The collection where the change occurred (e.g., `ChangeCollection.bills`).
  final ChangeCollection targetCollection;

  /// The type of change that occurred (e.g., add, update, remove).
  final ChangeType changeType;

  /// Constructor to initialize the metadata for a change.
  ChangeTarget({
    required this.targetCollection,
    required this.changeType,
  });

  /// Converts the `ChangeTarget` into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'changeCollection': targetCollection.name,
      'changeType': changeType.name,
    };
  }

  /// Creates a `ChangeTarget` instance from a JSON-compatible map.
  factory ChangeTarget.fromJson(Map<String, dynamic> json) {
    return ChangeTarget(
      targetCollection: ChangeCollection.values.byName(json['changeCollection']),
      changeType: ChangeType.values.byName(json['changeType']),
    );
  }
}

/// Enum to represent the collections where changes can occur.
enum ChangeCollection { bills, accounts, bonds, cheques, users, materials }

/// Enum to represent the types of changes that can occur in a collection.
enum ChangeType { add, remove,update }
