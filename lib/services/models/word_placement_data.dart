class WordPlacementData {
  final int distanceFromTopOfLetter;
  final int distanceFromBottomOfLetter;
  final int spaceFromTop;
  final int spaceFromBottom;
  final String actualVerticalStartingLocationIfAvailable;
  final String actualVerticalEndingLocationIfAvailable;
  final String word;
  final String col;
  final String location;
  final String actualVerticalBeforeStartingLocationIfAvailable;
  final String actualVerticalAfterEndingLocationIfAvailable;
  final int rowInt;
  final int colInt;
  final Map<String, List<String>> letterPositions;
  final String letter;
  final int letterIndex;
  final List<String> foundLocations;

  WordPlacementData({
    required this.distanceFromTopOfLetter,
    required this.distanceFromBottomOfLetter,
    required this.spaceFromTop,
    required this.spaceFromBottom,
    required this.actualVerticalStartingLocationIfAvailable,
    required this.actualVerticalEndingLocationIfAvailable,
    required this.word,
    required this.col,
    required this.location,
    required this.actualVerticalBeforeStartingLocationIfAvailable,
    required this.actualVerticalAfterEndingLocationIfAvailable,
    required this.rowInt,
    required this.colInt,
    required this.letterPositions,
    required this.letter,
    required this.letterIndex,
    required this.foundLocations,
  });
}
