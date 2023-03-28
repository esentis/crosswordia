import 'package:logger/logger.dart';

Logger kLog = Logger();

List<List<String>> findAnagrams(List<String> words) {
  Map<String, List<String>> anagrams = {};
  for (String word in words) {
    word = word.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]'),
        ''); //Convert to lowercase and remove unwanted characters
    List<int> charCodes = word.runes.toList(); //get the runes of the word
    charCodes.sort((a, b) => a.compareTo(b)); //sort the runes
    String key = String.fromCharCodes(charCodes); //create the key
    if (!anagrams.containsKey(key)) {
      anagrams[key] = [word];
    } else {
      anagrams[key]!.add(word);
    }
  }
  return anagrams.values.where((list) => list.length > 1).toList();
}

extension MapExpressions<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K key, V value) f,
      {Map<K, V> Function()? orElse}) {
    var filteredEntries = entries.where((entry) => f(entry.key, entry.value));
    if (filteredEntries.isEmpty && orElse != null) {
      return orElse();
    }
    return Map<K, V>.fromEntries(filteredEntries);
  }

  Map<K, V> whereKey(bool Function(K key) f, [Map<K, V> Function()? orElse]) =>
      where((key, value) => f(key), orElse: orElse);
  Map<K, V> whereValue(bool Function(V value) f,
          {Map<K, V> Function()? orElse}) =>
      where((key, value) => f(value), orElse: orElse);
  bool any(bool Function(K key, V value) f) =>
      entries.any((entry) => f(entry.key, entry.value));
  bool anyValue(bool Function(V value) f) => values.any(f);
  bool anyKey(bool Function(K key) f) => keys.any(f);
}
