import 'package:crosswordia/core/constants/greek_diacritics.dart';
import 'package:crosswordia/core/helpers/scraper.dart';

/// Finds all possible words that can be formed from the given characters.
///
/// This function takes a string of characters and searches through a dictionary
/// to find all valid words that can be formed using only the available characters.
/// Each character can only be used as many times as it appears in the input string.
///
/// The function normalizes both input characters and dictionary words by removing
/// Greek diacritics and converting to lowercase for accurate comparison.
///
/// Parameters:
/// - [characters]: The available characters to form words from
/// - [dict]: The dictionary list to search through
/// - [minWordLength]: Minimum length of words to consider (defaults to 3)
///
/// Returns:
/// A list of valid words that can be formed from the given characters.
/// Returns an empty list if no characters are provided.
///
/// Example:
/// ```dart
/// final words = findPossibleWords('αβγδε', greekDictionary, minWordLength: 2);
/// // Returns words like ['αβ', 'γδ', 'αγε'] if they exist in the dictionary
/// ```
Set<String> findPossibleWords(String characters, Iterable<String> dict,
    {int minWordLength = 3}) {
  if (characters.isEmpty) return {};

  final List<String> dictionary = dict
      .where((word) =>
          word.length >= minWordLength && word.length <= characters.length)
      .toList();

  final String normalizedChars =
      removeGreekDiacritics(characters.toLowerCase());

  final Map<String, int> inputCharFreq = {};
  for (int i = 0; i < normalizedChars.length; i++) {
    final String char = normalizedChars[i];
    inputCharFreq[char] = (inputCharFreq[char] ?? 0) + 1;
  }

  final Set<String> normalizedAdded = {}; // Track normalized forms
  final Set<String> validWords = {}; // Use Set directly

  for (final String originalWord in dictionary) {
    final String normalizedWord =
        removeGreekDiacritics(originalWord.toLowerCase());

    // Skip if we've already added this normalized form
    if (normalizedAdded.contains(normalizedWord)) continue;

    final Map<String, int> wordCharFreq = {};
    for (int i = 0; i < normalizedWord.length; i++) {
      final String char = normalizedWord[i];
      wordCharFreq[char] = (wordCharFreq[char] ?? 0) + 1;
    }

    bool canForm = true;
    wordCharFreq.forEach((char, count) {
      if (!inputCharFreq.containsKey(char) || inputCharFreq[char]! < count) {
        canForm = false;
      }
    });

    if (canForm) {
      validWords.add(originalWord);
      normalizedAdded.add(normalizedWord); // Mark as added
    }
  }

  kLog.f('Found ${validWords.length} valid words');
  kLog.f('Valid words: $validWords');
  return validWords;
}

// Improved Greek diacritic removal function
String removeGreekDiacritics(String text) {
  final Map<String, String> replacements = greekDiacritics;

  String result = text;
  replacements.forEach((key, value) {
    result = result.replaceAll(key, value);
  });

  return result;
}
