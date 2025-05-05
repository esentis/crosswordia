import 'dart:io';

import 'package:crosswordia/scraper.dart';
import 'package:crosswordia/services/models/word.dart';

/// Saves the collected words to a text file
Future<void> saveWordsToFile(List<Word> words) async {
  try {
    // Create file with timestamp to avoid overwriting previous files
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('greek_words_$timestamp.txt');

    // Create a StringBuffer for efficient string concatenation
    final buffer = StringBuffer();

    // Add header
    buffer.writeln('Greek Words Dictionary - ${DateTime.now()}');
    buffer.writeln('Word\tDescription\tScore');
    buffer.writeln('----------------------------------------');

    // Add each word with its details
    for (final word in words) {
      buffer.writeln('${word.word}\t${word.description}\t${word.score}');
    }

    // Write the buffer content to the file
    await file.writeAsString(buffer.toString());

    kLog.i('Successfully saved ${words.length} words to ${file.path}');
  } catch (e) {
    kLog.e('Error saving words to file: $e');
  }
}

// Function to save the grouped words to a text file, with both text and Map formats
Future<void> saveGroupedWordsToFile(
    Map<String, Set<String>> groupedWords, String filePath) async {
  kLog.f('Saving grouped words to: $filePath');

  try {
    final file = File(filePath);
    final buffer = StringBuffer();

    // Sort keys alphabetically for consistent output
    final sortedKeys = groupedWords.keys.toList()..sort();

    // // First format: Plain text
    // buffer.writeln('=== GROUPED WORDS (TEXT FORMAT) ===');
    // for (final key in sortedKeys) {
    //   final words = groupedWords[key]!.toList()..sort();
    //   buffer.writeln('"$key": "${words.join(', ')}"');
    // }

    // Second format: Flutter const Map
    buffer.writeln('\n\n=== FLUTTER CONST MAP FORMAT ===');
    buffer.writeln('const Map<String, List<String>> levels = {');

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final words = groupedWords[key]!.toList()..sort();

      // Format list of words as Dart string list
      buffer.write('  "$key": [');
      for (int j = 0; j < words.length; j++) {
        buffer.write('"${words[j]}"');
        if (j < words.length - 1) {
          buffer.write(', ');
        }
      }
      buffer.write(']');

      // Add comma for all but the last entry
      if (i < sortedKeys.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
    }

    buffer.writeln('};');

    await file.writeAsString(buffer.toString());
    kLog.f(
        'Successfully saved ${sortedKeys.length} groups to file in both formats');
  } catch (e) {
    kLog.f('Error saving to file: $e');
  }
}
