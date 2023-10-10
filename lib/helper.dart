import 'package:crosswordia/services/models/word.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';

Logger kLog = Logger();
Dio dio = Dio();

/// Simple function to scrape the words from the website
/// https://www.greek-language.gr/greekLang/modern_greek/tools/lexica/triantafyllides/search.html?start=0&lq=&dq=
void scrape() async {
  List<Word> allWords = [];
  int page = 0;
  do {
    try {
      // if (page > 46740) break;
      if (page > 1000) break;
      final res = await dio.get(
          'https://www.greek-language.gr/greekLang/modern_greek/tools/lexica/triantafyllides/search.html?start=$page&lq=&dq=');

      (res.data as String).findPattern(pattern: "dl id").forEach((foundIndex) {
        final String word = (res.data as String)
            .substring(foundIndex, foundIndex + 100)
            .after('<dt><b>')
            .before('</b>')!
            .stripHtml!
            .split(' ')
            .first;

        String description = (res.data as String)
            .substring(foundIndex, foundIndex + 500)
            .after('<b>:</b>')
            .before(':')!
            .stripHtml!;

        // if (description.contains('.')) {
        //   description = description.before('.')!;
        // }

        if (word.length > 2 && word.length < 8) {
          allWords.add(Word(
            word,
            description,
            word.calculateWordScore(),
          ));
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

const int mobileMaxWidth = 576;
const int tabletMaxWidth = 820;
const int desktopMaxWidth = 992;

extension ContextExtensions on BuildContext {
  bool get isMobile {
    return MediaQuery.sizeOf(this).width <= mobileMaxWidth;
  }

  bool get isTablet {
    return mobileMaxWidth < MediaQuery.sizeOf(this).width &&
        MediaQuery.sizeOf(this).width <= tabletMaxWidth;
  }

  bool get isDesktop {
    return tabletMaxWidth < MediaQuery.sizeOf(this).width &&
        MediaQuery.sizeOf(this).width <= desktopMaxWidth;
  }

  bool get isDesktopLarge {
    return desktopMaxWidth < MediaQuery.sizeOf(this).width;
  }
}
