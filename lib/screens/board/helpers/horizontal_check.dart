import 'package:crosswordia/core/extensions/map_extensions.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/services/models/word_placement_data.dart';
import 'package:string_extensions/string_extensions.dart';

/// Determines if a word can start horizontally from a given letter position.
bool canStartHorizontally(HorizontalPlacementData data) {
  // Checking if there is enough space to the left & right
  if (data.spaceFromLeft < data.distanceFromLeftOfLetter ||
      data.spaceFromRight < data.distanceFromRightOfLetter) {
    return false;
  }

  // This is the HORIZONTAL starting point of the word IF it can be placed
  final int actualHorizontalCol =
      data.actualHorizontalStartingLocationIfAvailable.after('.').toInt()!;

  bool hasActualConflicts = false;

  for (var k = 0; k < data.word.length; k++) {
    final int currentCol = actualHorizontalCol + k;

    // Check board boundaries
    if (currentCol > data.boardRows || currentCol < 1) {
      hasActualConflicts = true;
      break;
    }

    // Main location to check
    final String locationToCheck = '${data.rowInt}.$currentCol';

    // Boundary locations
    final String beforeStartWordLetterLocation =
        '${data.rowInt}.${actualHorizontalCol - 1}';
    final String afterEndWordLetterLocation =
        '${data.rowInt}.${actualHorizontalCol + data.word.length}';

    // Adjacent locations
    final String topLocationToCheck = '${data.rowInt - 1}.$currentCol';
    final String bottomLocationToCheck = '${data.rowInt + 1}.$currentCol';

    final bool hasConflicts = () {
      // Get the letter at the current location we're checking
      final letterOfCheckingLocationMap = data.letterPositions.whereValue(
        (value) => value.contains(locationToCheck),
        orElse: () => {},
      );

      final String? checkingLocationLetter =
          letterOfCheckingLocationMap.isNotEmpty
              ? letterOfCheckingLocationMap.keys.first
              : null;

      // Check if current letter matches what should be placed
      final bool isCurrentLetterPartOfTheWord =
          data.word.charAt(k) == checkingLocationLetter;

      // Check boundary conflicts (before start and after end)
      final bool beforeStartHasConflicts = data.letterPositions
          .anyValue((value) => value.contains(beforeStartWordLetterLocation));

      final bool afterEndHasConflicts = data.letterPositions.anyValue(
        (v) => v.contains(afterEndWordLetterLocation),
      );

      // Current location conflict: there's a letter here that doesn't match
      // what we want to place, and it's not our intersection point
      final bool currentLocationHasConflict = data.letterPositions
              .anyValue((value) => value.contains(locationToCheck)) &&
          locationToCheck != data.location &&
          !isCurrentLetterPartOfTheWord;

      // Top/Bottom conflicts: there are letters adjacent that would create
      // invalid crossings (unless it's a valid intersection)
      final bool topLocationHasConflict = data.letterPositions.anyValue(
            (v) => v.contains(topLocationToCheck),
          ) &&
          checkingLocationLetter ==
              null; // Only conflict if current cell is empty

      final bool bottomLocationHasConflict = data.letterPositions.anyValue(
            (v) => v.contains(bottomLocationToCheck),
          ) &&
          checkingLocationLetter ==
              null; // Only conflict if current cell is empty

      // Debug logging for specific problematic cases
      if (data.word == 'ΚΑΙ' &&
          data.actualHorizontalStartingLocationIfAvailable == '7.1') {
        kLog.f('''
DEBUG HORIZONTAL CHECK for ${data.word}:
k: $k, currentCol: $currentCol
locationToCheck: $locationToCheck
checkingLocationLetter: $checkingLocationLetter
isCurrentLetterPartOfTheWord: $isCurrentLetterPartOfTheWord
intersection location: ${data.location}

Conflicts:
- currentLocationHasConflict: $currentLocationHasConflict
- topLocationHasConflict: $topLocationHasConflict
- bottomLocationHasConflict: $bottomLocationHasConflict
- beforeStartHasConflicts: $beforeStartHasConflicts
- afterEndHasConflicts: $afterEndHasConflicts

Space from left: ${data.spaceFromLeft}, Space from right: ${data.spaceFromRight}
Distance from left: ${data.distanceFromLeftOfLetter}, Distance from right: ${data.distanceFromRightOfLetter}

Letter positions: ${data.letterPositions}
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
