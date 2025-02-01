/// Extension to group a list by a key selector
extension ListExtensions<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final Map<K, List<T>> groupedMap = {};
    for (final item in this) {
      final key = keySelector(item);
      groupedMap.putIfAbsent(key, () => []).add(item);
    }
    return groupedMap;
  }

  /// Groups and merges list items based on a key
  List<T> mergeBy<K>(
    K Function(T) keySelector,
    T Function(T accumulated, T current) mergeFunction,
  ) {
    final Map<K, T> mergedMap = {};

    for (var item in this) {
      final key = keySelector(item);
      if (mergedMap.containsKey(key)) {
        mergedMap[key] = mergeFunction(mergedMap[key] as T, item);
      } else {
        mergedMap[key] = item;
      }
    }

    return mergedMap.values.toList();
  }

  /// Converts a list into a map using a key selector
  Map<K, T> toMap<K>(K Function(T) keySelector) {
    final Map<K, T> mapped = {};
    for (var item in this) {
      mapped[keySelector(item)] = item;
    }
    return mapped;
  }
}
