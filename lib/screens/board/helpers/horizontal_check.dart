import 'package:crosswordia/core/extensions/map_extensions.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:string_extensions/string_extensions.dart';

/// Determines if a word can start horizontally from a given letter position.
bool canStartHorizontally({
  required int distanceFromRightOfLetter,
  required int distanceFromLeftOfLetter,
  required int spaceFromLeft,
  required int spaceFromRight,
  required String word,
  required String col,
  required String location,
  required String actualHorizontalStartingLocationIfAvailable,
  required String actualHorizontalEndingLocationIfAvailable,
  required String actualVerticalBeforeStartingLocationIfAvailable,
  required String actualVerticalAfterEndingLocationIfAvailable,
  required int rowInt,
  required int colInt,
  required int letterIndex,
  required Map<String, List<String>> letterPositions,
  required List<String> foundLocations,
  required String letter,
}) {
  // Checking if there is enough space to the left & right
  if (spaceFromLeft < distanceFromLeftOfLetter ||
      spaceFromRight < distanceFromRightOfLetter) {
    return false;
  }

  // This is the HORIZONTAL starting point of the word IF it can be placed
  final int actualHorizontalCol =
      actualHorizontalStartingLocationIfAvailable.after('.').toInt()!;

  bool hasActualConflicts = false;

  for (var k = 0; k < word.length; k++) {
    final int currentCol = actualHorizontalCol + k;

    // Check board boundaries
    if (currentCol > 12 || currentCol < 1) {
      hasActualConflicts = true;
      break;
    }

    // Main location to check
    final String locationToCheck = '$rowInt.$currentCol';

    // Boundary locations
    final String beforeStartWordLetterLocation =
        '$rowInt.${actualHorizontalCol - 1}';
    final String afterEndWordLetterLocation =
        '$rowInt.${actualHorizontalCol + word.length}';

    // Adjacent locations
    final String topLocationToCheck = '${rowInt - 1}.$currentCol';
    final String bottomLocationToCheck = '${rowInt + 1}.$currentCol';

    final bool hasConflicts = () {
      // Get the letter at the current location we're checking
      final letterOfCheckingLocationMap = letterPositions.whereValue(
        (value) => value.contains(locationToCheck),
        orElse: () => {},
      );

      final String? checkingLocationLetter =
          letterOfCheckingLocationMap.isNotEmpty
              ? letterOfCheckingLocationMap.keys.first
              : null;

      // Check if current letter matches what should be placed
      final bool isCurrentLetterPartOfTheWord =
          word.charAt(k) == checkingLocationLetter;

      // Check boundary conflicts (before start and after end)
      final bool beforeStartHasConflicts = letterPositions
          .anyValue((value) => value.contains(beforeStartWordLetterLocation));

      final bool afterEndHasConflicts = letterPositions.anyValue(
        (v) => v.contains(afterEndWordLetterLocation),
      );

      // Current location conflict: there's a letter here that doesn't match
      // what we want to place, and it's not our intersection point
      final bool currentLocationHasConflict = letterPositions
              .anyValue((value) => value.contains(locationToCheck)) &&
          locationToCheck != location &&
          !isCurrentLetterPartOfTheWord;

      // Top/Bottom conflicts: there are letters adjacent that would create
      // invalid crossings (unless it's a valid intersection)
      final bool topLocationHasConflict = letterPositions.anyValue(
            (v) => v.contains(topLocationToCheck),
          ) &&
          checkingLocationLetter ==
              null; // Only conflict if current cell is empty

      final bool bottomLocationHasConflict = letterPositions.anyValue(
            (v) => v.contains(bottomLocationToCheck),
          ) &&
          checkingLocationLetter ==
              null; // Only conflict if current cell is empty

      // Debug logging for specific problematic cases
      if (word == 'ΚΑΙ' &&
          actualHorizontalStartingLocationIfAvailable == '7.1') {
        kLog.f('''
DEBUG HORIZONTAL CHECK for $word:
k: $k, currentCol: $currentCol
locationToCheck: $locationToCheck
checkingLocationLetter: $checkingLocationLetter
isCurrentLetterPartOfTheWord: $isCurrentLetterPartOfTheWord
intersection location: $location

Conflicts:
- currentLocationHasConflict: $currentLocationHasConflict
- topLocationHasConflict: $topLocationHasConflict
- bottomLocationHasConflict: $bottomLocationHasConflict
- beforeStartHasConflicts: $beforeStartHasConflicts
- afterEndHasConflicts: $afterEndHasConflicts

Space from left: $spaceFromLeft, Space from right: $spaceFromRight
Distance from left: $distanceFromLeftOfLetter, Distance from right: $distanceFromRightOfLetter

Letter positions: $letterPositions
        ''');
      }

      return currentLocationHasConflict ||
          topLocationHasConflict ||
          bottomLocationHasConflict ||
          beforeStartHasConflicts ||
          afterEndHasConflicts;
    }();

    hasActualConflicts = hasConflicts;
    if (hasActualConflicts) break;
  }

  return !hasActualConflicts;
}
