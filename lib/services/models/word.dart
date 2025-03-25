// Source : https://www.researchgate.net/publication/220469197_Basic_Quantitative_Characteristics_of_the_Modern_Greek_Language_Using_the_Hellenic_National_Corpus

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
