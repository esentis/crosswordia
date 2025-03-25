extension MapExpressions<K, V> on Map<K, V> {
  Map<K, V> where(
    bool Function(K key, V value) f, {
    Map<K, V> Function()? orElse,
  }) {
    final filteredEntries = entries.where((entry) => f(entry.key, entry.value));
    if (filteredEntries.isEmpty && orElse != null) {
      return orElse();
    }
    return Map<K, V>.fromEntries(filteredEntries);
  }

  Map<K, V> whereKey(bool Function(K key) f, [Map<K, V> Function()? orElse]) =>
      where((key, value) => f(key), orElse: orElse);
  Map<K, V> whereValue(
    bool Function(V value) f, {
    Map<K, V> Function()? orElse,
  }) =>
      where((key, value) => f(value), orElse: orElse);
  bool any(bool Function(K key, V value) f) =>
      entries.any((entry) => f(entry.key, entry.value));
  bool anyValue(bool Function(V value) f) => values.any(f);
  bool anyKey(bool Function(K key) f) => keys.any(f);
}
