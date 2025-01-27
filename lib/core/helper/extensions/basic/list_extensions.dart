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
}
