import 'package:crosswordia/constants/letter_frequencies.dart';
import 'package:string_extensions/string_extensions.dart';

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
