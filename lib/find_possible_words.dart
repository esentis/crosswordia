import 'package:crosswordia/scraper.dart';

List<String> findPossibleWords(String characters, List<String> dict,
    {int minWordLength = 3}) {
  if (characters.isEmpty) return [];
  // Filter dictionary by length before normalization to save processing
  final List<String> dictionary = dict
      .where((word) =>
          word.length >= minWordLength && word.length <= characters.length)
      .toList();
  // Normalize the input characters - remove diacritics and convert to lowercase
  final String normalizedChars =
      removeGreekDiacritics(characters.toLowerCase());

  // Create a frequency map of the normalized input characters
  final Map<String, int> inputCharFreq = {};
  for (int i = 0; i < normalizedChars.length; i++) {
    final String char = normalizedChars[i];
    inputCharFreq[char] = (inputCharFreq[char] ?? 0) + 1;
  }

  final List<String> validWords = [];

  // Check each word in the dictionary
  for (final String originalWord in dictionary) {
    // Normalize the dictionary word for comparison
    final String normalizedWord =
        removeGreekDiacritics(originalWord.toLowerCase());

    // Create frequency map for the normalized word
    final Map<String, int> wordCharFreq = {};
    for (int i = 0; i < normalizedWord.length; i++) {
      final String char = normalizedWord[i];
      wordCharFreq[char] = (wordCharFreq[char] ?? 0) + 1;
    }

    // Check if we can form this word with our available characters
    bool canForm = true;
    wordCharFreq.forEach((char, count) {
      if (!inputCharFreq.containsKey(char) || inputCharFreq[char]! < count) {
        canForm = false;
      }
    });

    if (canForm) {
      validWords.add(originalWord); // Add the original word with diacritics
    }
  }
  // At the end of the function, before returning
  validWords.sort((a, b) => a.length != b.length
      ? b.length.compareTo(a.length) // Sort by length (longest first)
      : a.compareTo(b)); // Then alphabetically
  kLog.f('Found ${validWords.length} valid words');
  kLog.f('Valid words: ${validWords.toSet()}');
  return validWords;
}

// Improved Greek diacritic removal function
String removeGreekDiacritics(String text) {
  final Map<String, String> replacements = {
    'ά': 'α',
    'έ': 'ε',
    'ή': 'η',
    'ί': 'ι',
    'ό': 'ο',
    'ύ': 'υ',
    'ώ': 'ω',
    'Ά': 'Α',
    'Έ': 'Ε',
    'Ή': 'Η',
    'Ί': 'Ι',
    'Ό': 'Ο',
    'Ύ': 'Υ',
    'Ώ': 'Ω',
    'ϊ': 'ι',
    'ϋ': 'υ',
    'ΐ': 'ι',
    'ΰ': 'υ',
    'Ϊ': 'Ι',
    'Ϋ': 'Υ',
    'ς': 'σ'
  };

  String result = text;
  replacements.forEach((key, value) {
    result = result.replaceAll(key, value);
  });

  return result;
}
