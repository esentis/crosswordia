import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';

Logger kLog = Logger();
Dio dio = Dio();

// Source : https://www.researchgate.net/publication/220469197_Basic_Quantitative_Characteristics_of_the_Modern_Greek_Language_Using_the_Hellenic_National_Corpus
Map<String, num> letterFrequencies = {
  'Α': 0.11411,
  'Ο': 0.10331,
  'Ι': 0.09252,
  'Ε': 0.08586,
  'Τ': 0.07918,
  'Σ': 0.07830,
  'Ν': 0.06199,
  'Η': 0.05399,
  'Υ': 0.04416,
  'Ρ': 0.04286,
  'Π': 0.04014,
  'Κ': 0.03974,
  'Μ': 0.03358,
  'Λ': 0.02732,
  'Ω': 0.02147,
  'Δ': 0.01749,
  'Γ': 0.01727,
  'Χ': 0.01178,
  'Θ': 0.01120,
  'Φ': 0.00812,
  'Β': 0.00682,
  'Ξ': 0.00402,
  'Ζ': 0.00345,
  'Ψ': 0.00133,
};

int calculateWordScore(String word) {
  int score = 0;
  num calculateLetterScore(String letter) {
    if (letter.onlyLetters!.length != 1) {
      return 0.0;
    }
    return letterFrequencies[letter.toGreekUpperCase()] ?? 0.0;
  }

  for (var letter in word.split('')) {
    num letterScore = calculateLetterScore(letter);
    score += letterScore == 0 ? 0 : (1 / letterScore).round();
  }

  score += (word.length * 10);

  return score;
}

class Word {
  final String word;
  final String description;
  final num score;

  Word(this.word, this.description, this.score);

  @override
  String toString() {
    return 'Word{word: $word, description: $description, score: $score}';
  }

  String toStringShort() {
    return '$word, score: $score';
  }
}

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
            calculateWordScore(word),
          ));
        }
      });
    } on DioError catch (e) {
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
