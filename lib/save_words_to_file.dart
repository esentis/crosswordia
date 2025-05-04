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
