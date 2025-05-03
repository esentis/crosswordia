import 'dart:io'; // Import for file operations

import 'package:crosswordia/extensions/string_extensions.dart';
import 'package:crosswordia/services/models/word.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';

Logger kLog = Logger();
Dio dio = Dio();

/// Simple function to scrape the words from the website
/// https://www.greek-language.gr/greekLang/modern_greek/tools/lexica/triantafyllides/search.html?start=0&lq=&dq=
/// and save them to a text file
Future<void> scrape() async {
  final List<Word> allWords = [];
  int page = 0;
  do {
    try {
      // You can stop scraping when you reach a certain page
      if (page > 1000) break;
      final res = await dio.get(
        'https://www.greek-language.gr/greekLang/modern_greek/tools/lexica/triantafyllides/search.html?start=$page&lq=&dq=',
      );

      (res.data as String).findPattern(pattern: "dl id").forEach((foundIndex) {
        final String word = (res.data as String)
            .substring(foundIndex, foundIndex + 100)
            .after('<dt><b>')
            .before('</b>')
            .stripHtml
            .split(' ')
            .first;

        final String description = (res.data as String)
            .substring(foundIndex, foundIndex + 500)
            .after('<b>:</b>')
            .before(':')
            .stripHtml;

        if (word.length > 2 && word.length < 8) {
          allWords.add(
            Word(
              word,
              description,
              word.calculateWordScore(),
            ),
          );
        }
      });

      // Log progress every 10 pages
      if (page % 100 == 0) {
        kLog.i(
            'Processed page $page, collected ${allWords.length} words so far');
      }
    } on DioException catch (e) {
      kLog.e(e);
      break;
    }
    page += 10;
  } while (true);

  // Save the words to a text file
  await saveWordsToFile(allWords);

  kLog.i('Scraping complete. Collected ${allWords.length} words in total.');
}

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
