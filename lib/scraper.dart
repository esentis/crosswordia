import 'package:crosswordia/extensions/string_extensions.dart';
import 'package:crosswordia/services/models/word.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';

Logger kLog = Logger();
Dio dio = Dio();

/// Simple function to scrape the words from the website
/// https://www.greek-language.gr/greekLang/modern_greek/tools/lexica/triantafyllides/search.html?start=0&lq=&dq=
Future<void> scrape() async {
  final List<Word> allWords = [];
  int page = 0;
  do {
    try {
      // if (page > 46740) break;
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

        // if (description.contains('.')) {
        //   description = description.before('.')!;
        // }

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
    } on DioException catch (e) {
      kLog.e(e);
      break;
    }
    page += 10;
  } while (true);

  // allWords.forEach((element) {
  //   kLog.i(element.toStringShort());
  // });
}

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
