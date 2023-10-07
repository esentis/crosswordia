import 'package:crosswordia/helper.dart';
import 'package:string_extensions/string_extensions.dart';

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
    if (word == 'ΦΑΕ') {
      kLog.e('Looking for $letter in $location has conflict');
    }
    return false;
  }

  // This is the HORIZONTAL starting point of the word IF it can be placed
  final int actualHorizontalCol =
      actualHorizontalStartingLocationIfAvailable.after('.')!.toInt()!;

  int horizontalColIterator = actualHorizontalCol;

  int actualHorizontalRow =
      actualHorizontalStartingLocationIfAvailable.before('.')!.toInt()!;

  bool hasActualConflicts = false;

  for (var k = 0; k < word.length; k++) {
// colInt + k > 10 || (removed from check)
    if (distanceFromLeftOfLetter - colInt == 0 ||
        distanceFromLeftOfLetter + distanceFromRightOfLetter > word.length ||
        horizontalColIterator - 1 < 0) {
//       if (false) {
//         kLog.e('''
// Current letter $letter
// Checking at $location
// Current k $k
// Horizontal col iterator $horizontalColIterator
// Row int $rowInt
// Col int $colInt
// Distance from left of letter $distanceFromLeftOfLetter
// Distance from right of letter $distanceFromRightOfLetter
// Word length ${word.length}
// ''');
//       }
      hasActualConflicts = true;
      break;
    }

    // Main location to check
    String locationToCheck = '$rowInt.$horizontalColIterator';
    // Locations to check to the top and bottom
    String topLocationToCheck = '${rowInt - 1}.$horizontalColIterator';
    String topLeftLocationToCheck =
        '${rowInt - 1}.${horizontalColIterator - 1}';
    String topRightLocationToCheck =
        '${rowInt - 1}.${horizontalColIterator + 1}';

    String bottomLocationToCheck = '${rowInt + 1}.$horizontalColIterator';
    String bottomLeftLocationToCheck =
        '${rowInt + 1}.${horizontalColIterator - 1}';
    String bottomRightLocationToCheck =
        '${rowInt + 1}.${horizontalColIterator + 1}';

    String beforeStartWordLetterLocation =
        '$rowInt.${colInt - distanceFromLeftOfLetter - 1}';

    String afterEndWordLetterLocation =
        '$rowInt.${colInt - distanceFromLeftOfLetter + word.length}';

    final bool hasConflicts = () {
      final letterOfCheckingLocationMap = letterPositions
          .whereValue((value) => value.contains(locationToCheck), orElse: () {
        return {};
      });

      final String? checkingLocationLetter =
          letterOfCheckingLocationMap.isNotEmpty
              ? letterOfCheckingLocationMap.keys.first
              : null;
      final bool isCurrentLetterPartOfTheWord =
          word.charAt(k) == checkingLocationLetter;

      final bool beforeStartHasConflicts = letterPositions
          .anyValue((value) => value.contains(beforeStartWordLetterLocation));

      final bool afterEndHasConflicts = letterPositions.anyValue(
        (v) => v.contains(afterEndWordLetterLocation),
      );

      // final bool startingPointHasConflict = (letterPositions.anyValue(
      //         (v) => v.contains(actualHorizontalStartingLocationIfAvailable)) &&
      //     checkingLocationLetter != word.charAt(1));

      final bool currentLocationHasConflict = (letterPositions
              .anyValue((value) => value.contains(locationToCheck)) &&
          locationToCheck != location &&
          (locationToCheck == actualHorizontalEndingLocationIfAvailable
              ? checkingLocationLetter != word.charAt(word.length - 1)
              : checkingLocationLetter != word.charAt(letterIndex)));

      final bool topLeftLocationHasConflict = (letterPositions.anyValue(
            (v) => v.contains(topLeftLocationToCheck),
          ) &&
          locationToCheck != location &&
          beforeStartHasConflicts);

      final bool topRightLocationHasConflict = (letterPositions.anyValue(
            (v) => v.contains(topRightLocationToCheck),
          ) &&
          (letterPositions.anyValue(
            (v) => v.contains(topLocationToCheck),
          )));

      final bool topLocationConflictExtraCheck = !letterPositions.anyValue(
              (value) => value
                  .contains(actualHorizontalStartingLocationIfAvailable)) &&
          letterPositions.anyValue(
            (v) =>
                v.contains(topLocationToCheck) && locationToCheck != location,
          );

      final bool isRightTopOutOfReach =
          actualHorizontalCol < topRightLocationToCheck.after('.').toInt()!;

      final bool isLeftTopOutOfReach =
          actualHorizontalRow > topLeftLocationToCheck.after('.').toInt()!;

      final bool topLocationHasConflict = ((letterPositions
                      .anyValue((v) => v.contains(topLocationToCheck)) &&
                  locationToCheck != location &&
                  !isCurrentLetterPartOfTheWord) ||
              topLocationConflictExtraCheck && locationToCheck != location) ||
          // If the top right letter cant conflict with the word since it's right of the end. Thus we only check if it conflicts from top left
          (isRightTopOutOfReach
              ? topLeftLocationHasConflict
              : isLeftTopOutOfReach
                  ? topRightLocationHasConflict
                  : topLeftLocationHasConflict && topRightLocationHasConflict);

      final bool bottomLeftLocationHasConflict = (letterPositions.anyValue(
            (v) => v.contains(bottomLeftLocationToCheck),
          )) &&
          (letterPositions.anyValue(
            (v) => v.contains(bottomLocationToCheck),
          ));

      final bool isRightBottomOutOfReach =
          actualHorizontalRow < bottomRightLocationToCheck.after('.').toInt()!;

      final bool bottomRightLocationHasConflict = letterPositions.anyValue(
        (v) =>
            v.contains(bottomRightLocationToCheck) && !isRightBottomOutOfReach,
      );

      final bool isLeftBottomOutOfReach =
          actualHorizontalRow > bottomLeftLocationToCheck.after('.').toInt()!;

      final bool bottomLocationHasConflict = letterPositions.anyValue(
            (v) => v.contains(bottomLocationToCheck),
          ) &&
          checkingLocationLetter == null;

      if (word == 'ΚΑΙ' &&
          actualHorizontalStartingLocationIfAvailable == '7.1') {
        kLog.f('''
Letter $letter letterIndex $letterIndex
Iterating over letter ${word.charAt(k)}
word.charAt(k) != checkingLocationLetter ${word.charAt(k) != checkingLocationLetter}
Possible start $actualHorizontalStartingLocationIfAvailable
Possible end $actualHorizontalEndingLocationIfAvailable
Before start $beforeStartWordLetterLocation
After end $afterEndWordLetterLocation

locationToCheck $locationToCheck
locationToCheck letter $checkingLocationLetter
location $location
Intersection location $location


--- Conflicts ---
Is bottom right out of reach $isRightBottomOutOfReach
Is bottom left out of reach $isLeftBottomOutOfReach
Is top right out of reach $isRightTopOutOfReach
Is top left out of reach $isLeftTopOutOfReach

Bottom location $bottomLocationToCheck conflict $bottomLocationHasConflict
Bottom left location $bottomLeftLocationToCheck conflict $bottomLeftLocationHasConflict
Bottom right location $bottomRightLocationToCheck conflict $bottomRightLocationHasConflict

Top location $topLocationToCheck conflict $topLocationHasConflict
Top left location $topLeftLocationToCheck conflict $topLeftLocationHasConflict
Top right location $topRightLocationToCheck conflict $topRightLocationHasConflict
Top location extra check $topLocationConflictExtraCheck

Before start conflict $beforeStartHasConflicts
After end conflict $afterEndHasConflicts

Current location conflict $currentLocationHasConflict

Has actual conflicts ${currentLocationHasConflict || topLocationHasConflict || bottomLocationHasConflict || beforeStartHasConflicts || afterEndHasConflicts}

--- Conflicts ---
Space from left $spaceFromLeft
Space from right $spaceFromRight
Distance from left $distanceFromLeftOfLetter
Distance from right $distanceFromRightOfLetter

All letter positions: 
$letterPositions

Found locations
$foundLocations
''');
      }

      return currentLocationHasConflict ||
          topLocationHasConflict ||
          bottomLocationHasConflict ||
          beforeStartHasConflicts ||
          afterEndHasConflicts;
    }.call();
    hasActualConflicts = hasConflicts;
    if (hasActualConflicts) break;
    horizontalColIterator++;
  }

  return !hasActualConflicts;
}
