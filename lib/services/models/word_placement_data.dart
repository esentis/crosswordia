abstract class WordPlacementData {
  final String word;
  final String col;
  final String location;
  final int rowInt;
  final int colInt;
  final Map<String, List<String>> letterPositions;
  final String letter;
  final int letterIndex;
  final int boardRows;
  final List<String> foundLocations;

  WordPlacementData({
    required this.word,
    required this.col,
    required this.location,
    required this.rowInt,
    required this.colInt,
    required this.letterPositions,
    required this.letter,
    required this.letterIndex,
    required this.foundLocations,
    required this.boardRows,
  });
}

class VerticalPlacementData extends WordPlacementData {
  final int distanceFromTopOfLetter;
  final int distanceFromBottomOfLetter;
  final int spaceFromTop;
  final int spaceFromBottom;
  final String actualVerticalStartingLocationIfAvailable;
  final String actualVerticalEndingLocationIfAvailable;
  final String actualVerticalBeforeStartingLocationIfAvailable;
  final String actualVerticalAfterEndingLocationIfAvailable;

  VerticalPlacementData({
    required this.distanceFromTopOfLetter,
    required this.distanceFromBottomOfLetter,
    required this.spaceFromTop,
    required this.spaceFromBottom,
    required this.actualVerticalStartingLocationIfAvailable,
    required this.actualVerticalEndingLocationIfAvailable,
    required this.actualVerticalBeforeStartingLocationIfAvailable,
    required this.actualVerticalAfterEndingLocationIfAvailable,
    required super.word,
    required super.col,
    required super.location,
    required super.rowInt,
    required super.colInt,
    required super.letterPositions,
    required super.letter,
    required super.letterIndex,
    required super.foundLocations,
    required super.boardRows,
  });
}

class HorizontalPlacementData extends WordPlacementData {
  final int distanceFromRightOfLetter;
  final int distanceFromLeftOfLetter;
  final int spaceFromLeft;
  final int spaceFromRight;
  final String actualHorizontalStartingLocationIfAvailable;
  final String actualHorizontalEndingLocationIfAvailable;
  final String actualVerticalBeforeStartingLocationIfAvailable;
  final String actualVerticalAfterEndingLocationIfAvailable;

  HorizontalPlacementData({
    required this.distanceFromRightOfLetter,
    required this.distanceFromLeftOfLetter,
    required this.spaceFromLeft,
    required this.spaceFromRight,
    required this.actualHorizontalStartingLocationIfAvailable,
    required this.actualHorizontalEndingLocationIfAvailable,
    required this.actualVerticalBeforeStartingLocationIfAvailable,
    required this.actualVerticalAfterEndingLocationIfAvailable,
    required super.word,
    required super.col,
    required super.location,
    required super.rowInt,
    required super.colInt,
    required super.letterPositions,
    required super.letter,
    required super.letterIndex,
    required super.foundLocations,
    required super.boardRows,
  });
}
