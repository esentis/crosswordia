import 'package:crosswordia/core/extensions/map_extensions.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/services/models/word_placement_data.dart';
import 'package:string_extensions/string_extensions.dart';

bool canStartVertically(VerticalPlacementData data) {
  // This is the VERTICAL starting point of the word IF it can be placed
  final int actualVerticalRow =
      data.actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

  // Checking if there is enough space to the bottom & top
  if (data.spaceFromTop < data.distanceFromTopOfLetter ||
      data.spaceFromBottom < data.distanceFromBottomOfLetter ||
      actualVerticalRow < 1) {
    return false;
  }

  bool hasActualConflicts = false;

  // Iterating through the word to check if there are any conflicts
  for (var k = 0; k < data.word.length; k++) {
    final int currentRow = actualVerticalRow + k;

    // If we are at the end of the board, we break
    if (currentRow > data.boardRows || currentRow < 1) {
      hasActualConflicts = true;
      break;
    }

    // Main location to check
    final String locationToCheck = '$currentRow.${data.colInt}';

    // Boundary locations
    final String beforeStartWordLetterLocation =
        '${actualVerticalRow - 1}.${data.colInt}';
    final String afterEndWordLetterLocation =
        '${actualVerticalRow + data.word.length}.${data.colInt}';

    // Adjacent locations
    final String leftLocationToCheck = '$currentRow.${data.colInt - 1}';
    final String rightLocationToCheck = '$currentRow.${data.colInt + 1}';

    final hasConflicts = () {
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

      // Left/Right conflicts: there are letters adjacent that would create
      // invalid crossings (unless it's a valid intersection)
      final bool leftLocationHasConflict = data.letterPositions.anyValue(
            (v) => v.contains(leftLocationToCheck),
          ) &&
          checkingLocationLetter ==
              null; // Only conflict if current cell is empty

      final bool rightLocationHasConflict = data.letterPositions.anyValue(
            (v) => v.contains(rightLocationToCheck),
          ) &&
          checkingLocationLetter ==
              null; // Only conflict if current cell is empty

      // Debug logging for specific problematic cases
      if (data.word == 'ΖΕΑ' &&
          data.actualVerticalStartingLocationIfAvailable == '1.8') {
        kLog.f('''
DEBUG VERTICAL CHECK for ${data.word}:
k: $k, currentRow: $currentRow
locationToCheck: $locationToCheck
checkingLocationLetter: $checkingLocationLetter
isCurrentLetterPartOfTheWord: $isCurrentLetterPartOfTheWord
intersection location: ${data.location}

Conflicts:
- currentLocationHasConflict: $currentLocationHasConflict
- leftLocationHasConflict: $leftLocationHasConflict  
- rightLocationHasConflict: $rightLocationHasConflict
- beforeStartHasConflicts: $beforeStartHasConflicts
- afterEndHasConflicts: $afterEndHasConflicts

Letter positions: ${data.letterPositions}
        ''');
      }

      return currentLocationHasConflict ||
          leftLocationHasConflict ||
          rightLocationHasConflict ||
          beforeStartHasConflicts ||
          afterEndHasConflicts;
    }();

    hasActualConflicts = hasConflicts;
    if (hasActualConflicts) {
      break;
    }
  }

  return !hasActualConflicts;
}
