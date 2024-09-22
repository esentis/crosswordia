// Source : https://www.researchgate.net/publication/220469197_Basic_Quantitative_Characteristics_of_the_Modern_Greek_Language_Using_the_Hellenic_National_Corpus
import 'package:string_extensions/string_extensions.dart';

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

/// Extension on `String` to calculate the score of a word based on letter frequencies.
///
/// The `calculateWordScore` method computes the score of a word by summing up the
/// inverse of the frequency of each letter in the word. If a letter's frequency is
/// zero or the letter is not a valid single letter, it contributes zero to the score.
/// Additionally, the length of the word multiplied by 10 is added to the final score.
///
/// The method relies on the `letterFrequencies` map and the `toGreekUpperCase`
/// extension method to determine the frequency of each letter.
///
/// Returns:
/// - An integer representing the calculated score of the word.
extension WordExtensions on String {
  int calculateWordScore() {
    int score = 0;
    num getLetterFrequency(String letter) {
      if (letter.onlyLetters.length != 1) {
        return 0.0;
      }
      return letterFrequencies[letter.toGreekUpperCase()] ?? 0.0;
    }

    for (final letter in split('')) {
      final num letterFreq = getLetterFrequency(letter);
      score += letterFreq == 0 ? 0 : (1 / letterFreq).round();
    }

    return score += length * 10;
  }
}
