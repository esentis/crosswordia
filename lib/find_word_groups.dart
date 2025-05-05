import 'package:crosswordia/save_words_to_file.dart';
import 'package:crosswordia/scraper.dart';
import 'package:string_extensions/string_extensions.dart';

void filterWords(List<String> wordsToLook) async {
  kLog.f('Started filtering words with max key length of 7');
  final Map<String, Set<String>> groupedWords = {};
  final int totalWords = wordsToLook.length;

  // First pass: Group words by their sorted characters (limited to 7 chars)
  int processedCount = 0;
  for (final word in wordsToLook) {
    processedCount++;
    if (processedCount % 1000 == 0) {
      kLog.f('Processed $processedCount/$totalWords words (first pass)');
    }

    // Skip words that are too short or contain non-letter characters
    if (word.length < 3 || !containsOnlyLetters(word)) continue;

    final List<String> wordChars = word.toGreekUpperCase().split('')..sort();
    final String sortedChars = wordChars.join();

    // Only create groups for keys with length <= 7
    if (sortedChars.length <= 7) {
      groupedWords.putIfAbsent(sortedChars, () => <String>{});
      groupedWords[sortedChars]!.add(word);
    }
  }

  kLog.f('Created ${groupedWords.length} initial groups');

  // Second pass: For each word, find all groups it belongs to
  processedCount = 0;
  int groupCount = 0;
  for (final word in wordsToLook) {
    processedCount++;
    if (processedCount % 1000 == 0) {
      kLog.f('Processed $processedCount/$totalWords words (second pass)');
    }

    // Skip words that are too short or contain non-letter characters
    if (word.length < 3 || !containsOnlyLetters(word)) continue;

    final List<String> wordChars = word.toGreekUpperCase().split('')..sort();

    // Skip words that are too long for any group
    if (wordChars.length > 7) continue;

    groupCount = 0;
    for (final groupKey in groupedWords.keys) {
      groupCount++;
      if (groupCount % 5000 == 0) {
        kLog.f(
            '  - Checking word "$word" against group $groupCount/${groupedWords.length}');
      }

      // Skip if word is already in this group
      if (groupedWords[groupKey]!.contains(word)) continue;

      // Skip if word has more characters than the group key
      if (wordChars.length > groupKey.length) continue;

      // Check if word's characters are a subset of the group key's characters
      if (isSubset(wordChars, groupKey.split(''))) {
        groupedWords[groupKey]!.add(word);
      }
    }
  }

  kLog.f('Completed second pass, filtering groups with less than 4 words...');

  // Filter out groups with less than 4 words
  final Map<String, Set<String>> filteredGroups = {};
  int filteredCount = 0;
  int totalGroups = groupedWords.length;

  for (final entry in groupedWords.entries) {
    filteredCount++;
    if (filteredCount % 100 == 0) {
      kLog.f('Filtering progress: $filteredCount/$totalGroups');
    }

    if (entry.value.length >= 4) {
      filteredGroups[entry.key] = entry.value;
    }
  }

  kLog.f('Grouping complete');
  kLog.f('Total groups before filtering: ${groupedWords.length}');
  kLog.f('Total groups after filtering (4+ words): ${filteredGroups.length}');
  kLog.f('Saving to file...');

  // Save to file with both formats
  saveGroupedWordsToFile(filteredGroups, 'grouped_words_filtered_final.txt');
}

// Check if a word contains only letters (no hyphens or other characters)
bool containsOnlyLetters(String word) {
  // This regex pattern checks for characters that are not letters
  // For Greek, we need to ensure we check against Greek Unicode ranges
  return !word.contains(RegExp('[^α-ωΑ-Ωάέήίόύώΐΰϊϋ]'));
}

// Improved subset checking with frequency counting
bool isSubset(List<String> a, List<String> b) {
  // Count character frequencies in both lists
  final Map<String, int> freqA = {};
  final Map<String, int> freqB = {};

  for (final char in a) {
    freqA[char] = (freqA[char] ?? 0) + 1;
  }

  for (final char in b) {
    freqB[char] = (freqB[char] ?? 0) + 1;
  }

  // Check if each character in a has sufficient count in b
  for (final char in freqA.keys) {
    final countA = freqA[char]!;
    final countB = freqB[char] ?? 0;

    if (countA > countB) {
      return false; // Not enough of this character in b
    }
  }

  return true;
}
