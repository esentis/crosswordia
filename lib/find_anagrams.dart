List<List<String>> findAnagrams(List<String> words) {
  final Map<String, List<String>> anagrams = {};
  for (String word in words) {
    word = word.toLowerCase().replaceAll(
          RegExp('[^a-zA-Z]'),
          '',
        ); //Convert to lowercase and remove unwanted characters
    final List<int> charCodes = word.runes.toList(); //get the runes of the word
    charCodes.sort((a, b) => a.compareTo(b)); //sort the runes
    final String key = String.fromCharCodes(charCodes); //create the key
    if (!anagrams.containsKey(key)) {
      anagrams[key] = [word];
    } else {
      anagrams[key]!.add(word);
    }
  }
  return anagrams.values.where((list) => list.length > 1).toList();
}
